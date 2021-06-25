//
//  DownloadManager.swift
//  MultiDownload
//
//  Created by KA TO on 2020/04/08.
//

import Foundation

typealias ProgressHandler = ((Progress) -> Void)
typealias CompleteHandler = (() -> Void)

/// Manager of asynchronous download `Operation` objects
@objcMembers class DownloadManager: NSObject {
    
    /// Dictionary of operations, keyed by the `taskIdentifier` of the `URLSessionTask`
    fileprivate var operations = [Int: DownloadOperation]()
    
    fileprivate var progress = Progress(totalUnitCount: 0)
    
    /// Downloading progress handler
    public var progressHandler: ProgressHandler
    
    /// All download complete handler
    public var completeHandler: CompleteHandler
    
    /// Set  download count that can execute at the same time.
    /// Default is 1 to make a serial download.
    public var maxOperationCount = 1
    
    /// Pesistent session id
    public var uuid = NSUUID().uuidString
    
    /// Serial NSOperationQueue for downloads
    private let queue: OperationQueue = {
        let _queue = OperationQueue()
        _queue.name = "downloadqueue"
        return _queue
    }()
    
    /// Delegate-based NSURLSession for DownloadManager
    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: uuid)
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    init(progressHandler: @escaping ProgressHandler, completeHandler: @escaping CompleteHandler) {
        self.progressHandler = progressHandler
        self.completeHandler = completeHandler
        
        super.init()
    }
    
    /// Add download links
    ///
    /// - parameter url: The file's download URL
    ///
    /// - returns: nil
    @objc func addDownload(_ urls: [DownloadLink]) {
        
        var newOperations = [DownloadOperation]()
        let completeOperation = BlockOperation(block: completeHandler)
        
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

    /// Cancel all queued operations
    func cancelAll() {
        queue.cancelAllOperations()
    }
}

// MARK: URLSessionDownloadDelegate methods

extension DownloadManager: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        operations[downloadTask.taskIdentifier]?.trackDownloadByOperation(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        progress.totalUnitCount = totalBytesExpectedToWrite
        progress.completedUnitCount = totalBytesWritten
        progressHandler(progress)
        
        //operations[downloadTask.taskIdentifier]?.trackDownloadByOperation(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let key = task.taskIdentifier
        operations[key]?.trackDownloadByOperation(session, task: task, didCompleteWithError: error)
        operations.removeValue(forKey: key)
    }
}
