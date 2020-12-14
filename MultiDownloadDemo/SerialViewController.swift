//
//  ViewController.swift
//  MultiDownloadDemo
//
//  Created by dujia on 2020/12/08.
//

import UIKit

class SerialDownloadController: UIViewController {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var downloadProgressView: UIProgressView!
    @IBOutlet weak var progressTextView: UITextView!
    
    fileprivate var downloadManager = DownloadManager()
    
    public var downloadLinks = [
        "http://ipv4.download.thinkbroadband.com/5MB.zip",
        "https://file-examples-com.github.io/uploads/2017/02/zip_10MB.zip",
        "http://ipv4.download.thinkbroadband.com/10MB.zip",
        "http://ipv4.download.thinkbroadband.com/20MB.zip"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DownloadManager.maxOperationCount = 1
        downloadManager.processDelegate = self
       
        downloadLinks.forEach { link in
            if let url = URL(string: link) {
                downloadManager.addDownload(url)
            }
        }
        
        do {
            /// Do something when all of the download is done
            let completionHandler = {
                DispatchQueue.main.async { [weak self] in
                    /// Do something when all are downloaded
                    guard let `self` = self else { return }
                    self.descriptionLabel.text = "All of the download completed!"
                }
            }
                
            /// Add complete  execut  block after every download task has been added
            try downloadManager.allDownloadDone(completionHandler: completionHandler)
        } catch DownloadError.wrongOrder(let message) {
            print(message)
        } catch {
            
        }
    }
}

extension SerialDownloadController: DownloadProcessProtocol {
    
    func downloadingProgress(_ percent: Float, fileName: String) {
        
        let text = String(format: "Downloading: %@, %0.2f%%", fileName ,percent * 100)
        self.descriptionLabel.text = text
        self.downloadProgressView.progress = percent
    }
    
    func downloadSucceeded(_ fileName: String) {
        self.progressTextView.text.append("\(fileName) has been download \n")
    }

    func downloadWithError(_ error: Error?, fileName: String) {
        self.progressTextView.text.append("Download \(fileName) failed: \(String(describing: (error != nil) ? error?.localizedDescription : "Unknown error")) \n")
    }
}

