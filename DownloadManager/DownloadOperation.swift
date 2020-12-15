//
//  DownloadOperation.swift
//  MultiDownload
//
//  Created by KA TO on 2020/04/08.
//

import Foundation

class DownloadOperation : AsynchronousOperation {
    
    public var task: URLSessionTask!
    
    init(session: URLSession, url: URL) {
        task = session.downloadTask(with: url)
        
        super.init()
    }

    override func cancel() {
        task.cancel()
        super.cancel()
    }

    override func main() {
        task.resume()
    }
}

// MARK: Track the download progress from Download manager's urlsession

extension DownloadOperation {
    
    /// Download complete. Save file to document directory.
    func trackDownloadByOperation(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let manager = FileManager.default
            let destinationURL = try manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(downloadTask.originalRequest!.url!.lastPathComponent)
            if manager.fileExists(atPath:  destinationURL.path) {
                try manager.removeItem(at: destinationURL)
            }
            try manager.moveItem(at: location, to: destinationURL)
        }
        catch {
            print("\(error)")
        }
        
        completeOperation()
    }

    /// Downloading progress.
    func trackDownloadByOperation(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        //let progress = Double(totalBytesWritten)/Double(totalBytesExpectedToWrite)
        //print("\(downloadTask.originalRequest!.url!.absoluteString) \(progress)")
    }
    
    /// Download failed.
    func trackDownloadByOperation(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            print("\(String(describing: error))")
        }
        
        completeOperation()
    }
}

