//
//  DownloadManager.swift
//  MultiDownload
//
//  Created by KA TO on 2020/04/08.
//

import Foundation

enum DownloadError: Error {
    case packetFetchError(String) // Error occured while downloading
    case wrongOrder(String) // Add complete block with wrong order
}

/// Manager of asynchronous download `Operation` objects
@objcMembers class DownloadManager: NSObject {
    
    /// Dictionary of operations, keyed by the `taskIdentifier` of the `URLSessionTask`
    fileprivate var operations = [Int: DownloadOperation]()
    
    /// Downloading progress handler
    public var progressHandler: ((Int, Double) -> Void)?
    
    /// Download complete handler
    public var completeHandler: ((Int) -> Void)?
    
    /// Set  download count that can execute at the same time.
    /// Default is 1 to make a serial download.
    public var isSerial = true
    
    /// Serial NSOperationQueue for downloads
    private let queue: OperationQueue = {
        let _queue = OperationQueue()
        _queue.name = "download"
        return _queue
    }()
    
    /// Delegate-based NSURLSession for DownloadManager
    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "background")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    /// Add download links
    ///
    /// - parameter url: The file's download URL
    ///
    /// - returns: nil
    @objc func addDownload(_ urls: [String]) {
        
        var newOperations = [DownloadOperation]()
        
        urls.forEach { link in
            if let url = URL(string: link) {
                let operation = DownloadOperation(session: session, url: url)
                operations[operation.task.taskIdentifier] = operation
                newOperations.append(operation)
            }
        }
        
        queue.addOperations(newOperations, waitUntilFinished: isSerial)
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
        operations[downloadTask.taskIdentifier]?.trackDownloadByOperation(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let key = task.taskIdentifier
        operations[key]?.trackDownloadByOperation(session, task: task, didCompleteWithError: error)
        operations.removeValue(forKey: key)
    }
}
