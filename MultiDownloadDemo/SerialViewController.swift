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
        "https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_1920_18MG.mp4",
        "https://sample-videos.com/img/Sample-jpg-image-30mb.jpg",
        "https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_1280_10MG.mp4",
        "https://www.learningcontainer.com/wp-content/uploads/2019/09/sample-pdf-download-10-mb.pdf",
        "https://sample-videos.com/img/Sample-jpg-image-20mb.jpg",
        "https://file-examples-com.github.io/uploads/2018/04/file_example_OGG_1920_13_3mg.ogg"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadProgressView.progress = 0.0
        
        DownloadManager.maxOperationCount = 1
        downloadManager.processDelegate = self
        
        let completion = BlockOperation {
            /// Do something here when all of the download is done
            self.descriptionLabel.text = "All of the download completed!"
        }
       
        downloadLinks.forEach { link in
            if let url = URL(string: link) {
                let downloadOperation = downloadManager.addDownload(url)
                completion.addDependency(downloadOperation)
            }
        }
        
        OperationQueue.main.addOperation(completion)
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
        self.progressTextView.text.append("Download \(fileName) failed: \(String(describing: (error != nil) ? error!.localizedDescription : "Unknown error")) \n")
    }
}

