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
    
    fileprivate var downloadManager = DownloadManager()
    
    public var downloadLinks = [
        "https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_5MG.mp3",
        "http://ipv4.download.thinkbroadband.com/50MB.zip",
        "https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_2MG.mp3",
        "http://ipv4.download.thinkbroadband.com/20MB.zip",
        "https://file-examples-com.github.io/uploads/2017/02/zip_10MB.zip",
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DownloadManager.maxOperationCount = 1
        downloadManager.processDelegate = self
       
        downloadLinks.forEach{ link in
            if let url = URL(string: link) {
                downloadManager.addDownload(url)
            }
        }
        
        downloadManager.addAllDownloadComplete({
            DispatchQueue.main.async { [weak self] in
                /// Do something when all are downloaded
                guard let `self` = self else { return }
                self.descriptionLabel.text = "All of the download completed!"
            }
        })
    }
}

extension SerialDownloadController: DownloadProcessProtocol {
    
    func downloadingProgress(_ percent: Float, fileName: String) {
        
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            let text = String(format: "Downloading: %@, %0.2f%%", fileName ,percent * 100)
            self.descriptionLabel.text = text
            self.downloadProgressView.progress = percent
        }
    }
    
    func downloadSucceeded(_ fileName: String) {
        
    }

    func downloadWithError(_ error: Error?, fileName: String) {
        
    }
}

