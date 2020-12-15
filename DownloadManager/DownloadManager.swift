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

@objc protocol DownloadProcessProtocol {
    
    /// Share downloding progress with outside
    ///
    /// - parameter percent:  Download percentage of current file
    func downloadingProgress(_ percent: Float, fileName: String)
    
    /// Get called when download complete
    func downloadSucceeded(_ fileName: String)
    
    /// Get called when error occured while download.
    ///
    /// - parameter error: Download error occurred by URLSession's download task
    func downloadWithError(_ error: Error?, fileName: String)
    
}

/// Manager of asynchronous download `Operation` objects
@objcMembers class DownloadManager: NSObject {
    
    /// Dictionary of operations, keyed by the `taskIdentifier` of the `URLSessionTask`
    fileprivate var operations = [Int: DownloadOperation]()
    
    /// Set  download count that can execute at the same time.
    /// Default is 1 to make a serial download.
    public static var maxOperationCount = 1
    
    /// Serial NSOperationQueue for downloads
    private let queue: OperationQueue = {
        let _queue = OperationQueue()
        _queue.name = "download"
        _queue.maxConcurrentOperationCount = maxOperationCount
        return _queue
    }()
    
    /// Delegate-based NSURLSession for DownloadManager
    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    /// Track the download process
    var  processDelegate : DownloadProcessProtocol?
    
    /// Add download links
    ///
    /// - parameter url: The file's download URL
    ///
    /// - returns:  A downloadOperation of the operation that was queued
    @discardableResult
    @objc func addDownload(_ url: URL) -> DownloadOperation {
        let operation = DownloadOperation(session: session, url: url)
        operations[operation.task.taskIdentifier] = operation
        queue.addOperation(operation)
        return operation
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
        
        if let downloadUrl = downloadTask.originalRequest!.url {
            DispatchQueue.main.async { [self] in
                processDelegate?.downloadSucceeded(downloadUrl.lastPathComponent)
            }
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        operations[downloadTask.taskIdentifier]?.trackDownloadByOperation(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
        
        if let downloadUrl = downloadTask.originalRequest!.url {
            let percent = Double(totalBytesWritten)/Double(totalBytesExpectedToWrite)
            DispatchQueue.main.async { [self] in
                processDelegate?.downloadingProgress(Float(percent), fileName:  downloadUrl.lastPathComponent)
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let key = task.taskIdentifier
        operations[key]?.trackDownloadByOperation(session, task: task, didCompleteWithError: error)
        operations.removeValue(forKey: key)
        
        if let downloadUrl = task.originalRequest!.url, error != nil {
            DispatchQueue.main.async { [self] in
                processDelegate?.downloadWithError(error, fileName: downloadUrl.lastPathComponent)
            }
        }
    }
}
