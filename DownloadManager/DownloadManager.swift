//
//  DownloadManager.swift
//  MultiDownload
//
//  Created by KA TO on 2020/04/08.
//

import Foundation
import UIKit

typealias ProgressHandler = ((Float, DownloadLink?) -> Void)
typealias SingleTaskCompleteHandler = ((DownloadLink?) -> Void)
typealias AllTasksCompleteHandler = (() -> Void)

/// Manager of asynchronous download `Operation` objects
@objcMembers class DownloadManager: NSObject {
    
    /// Dictionary of operations, keyed by the `taskIdentifier` of the `URLSessionTask`
    fileprivate var operations = [Int: DownloadOperation]()
    
    fileprivate var progress = Progress(totalUnitCount: 0)
    
    ///  Background handler
    public var backgroundSessionCompletionHandler: (() -> Void)?
    
    /// Downloading progress handler
    public var progressHandler: ProgressHandler
    
    /// One task complete handler
    public var singleTaskCompleteHandler: SingleTaskCompleteHandler
    
    /// All download complete handler
    public var allTasksCompleteHandler: AllTasksCompleteHandler
    
    /// Set  download count that can execute at the same time.
    /// Default is 1 to make a serial download.
    public var maxOperationCount = 1
    
    /// Pesistent session id
    public var sessionId = Bundle.main.bundleIdentifier ?? "multidownload_session"
    
    /// Serial NSOperationQueue for downloads
    private let queue: OperationQueue = {
        let _queue = OperationQueue()
        _queue.name = "downloadqueue"
        return _queue
    }()
    
    /// Delegate-based NSURLSession for DownloadManager
    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: sessionId)
        configuration.isDiscretionary = true
        configuration.sessionSendsLaunchEvents = true
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    init(progressHandler: @escaping ProgressHandler = { _, _ in },
         singleCompleteHandler: @escaping SingleTaskCompleteHandler = {_ in },
         allCompleteHandler: @escaping AllTasksCompleteHandler = { },
         backgroundCompletion: (() -> Void)? = nil) {
        self.progressHandler = progressHandler
        self.singleTaskCompleteHandler = singleCompleteHandler
        self.allTasksCompleteHandler = allCompleteHandler
        self.backgroundSessionCompletionHandler = backgroundCompletion
        
        super.init()
    }
    
    /// Add download links
    ///
    /// - parameter urls: The file's download URL
    ///
    /// - returns: void
    @objc func addDownload(_ urls: [DownloadLink]) {
        
        var newOperations = [DownloadOperation]()
        let completeOperation = BlockOperation(block: allTasksCompleteHandler)
        
        urls.forEach { link in
            if let _ = link.link {
                let operation = DownloadOperation(session: session, downloadLink: link)
                operations[operation.downloadTask.taskIdentifier] = operation
                completeOperation.addDependency(operation)
                newOperations.append(operation)
            }
        }
        
        queue.maxConcurrentOperationCount = maxOperationCount
        queue.addOperations(newOperations, waitUntilFinished: false)
        
        OperationQueue.main.addOperation(completeOperation)
    }
    
    func saveResumeData(_ resumeData: Data, for taskIdentifier: Int) {
        let key = "resumeData_\(taskIdentifier)"
        UserDefaults.standard.set(resumeData, forKey: key)
    }

    func loadResumeData(for taskIdentifier: Int) -> Data? {
        let key = "resumeData_\(taskIdentifier)"
        return UserDefaults.standard.data(forKey: key)
    }

    func clearResumeData(for taskIdentifier: Int) {
        let key = "resumeData_\(taskIdentifier)"
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    func resumeDownload(taskIdentifier: Int) {
        if let resumeData = loadResumeData(for: taskIdentifier) {
            let task = session.downloadTask(withResumeData: resumeData)
            task.resume()
            clearResumeData(for: taskIdentifier)
        }
    }
    
    func restorePendingDownloads() {
        session.getTasksWithCompletionHandler { [weak self] (_, _, downloadTasks) in
            guard let self = self else { return }
            downloadTasks.forEach { task in
                self.resumeDownload(taskIdentifier: task.taskIdentifier)
            }
        }
    }

    /// Cancel all queued operations
    func cancelAll() {
        queue.cancelAllOperations()
    }
}

// MARK: URLSessionDownloadDelegate methods

extension DownloadManager: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let _ = downloadTask.originalRequest!.url {
            DispatchQueue.main.async {
                self.singleTaskCompleteHandler(self.operations[downloadTask.taskIdentifier]?.downloadLink)
            }
        }
        
        operations[downloadTask.taskIdentifier]?.trackDownloadByOperation(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        if let _ = downloadTask.originalRequest!.url {
            DispatchQueue.main.async {
                let progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
                self.progressHandler(progress, self.operations[downloadTask.taskIdentifier]?.downloadLink)
            }
        }
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        if let backgroundCompletion = self.backgroundSessionCompletionHandler {
            DispatchQueue.main.async(execute: {
                backgroundCompletion()
            })
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let key = task.taskIdentifier
        
        if let error = error as NSError?, error.code == NSURLErrorCancelled {
            if let resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData] as? Data {
                saveResumeData(resumeData, for: key)
            }
        }
        operations[key]?.trackDownloadByOperation(session, task: task, didCompleteWithError: error)
        operations.removeValue(forKey: key)
    }
}
