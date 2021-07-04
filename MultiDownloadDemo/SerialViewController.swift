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
    
    private var downloadManager: DownloadManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let customFilePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        
        let downloadLinks = [
            DownloadLink(link: "https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_1920_18MG.mp4"),
            //DownloadLink(link: "https://sample-videos.com/img/Sample-jpg-image-30mb.jpg"),
            DownloadLink(link: "https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_1280_10MG.mp4", directory: customFilePath, fileName: "test.mp4"),
            //DownloadLink(link: "https://www.learningcontainer.com/wp-content/uploads/2019/09/sample-pdf-download-10-mb.pdf"),
            //DownloadLink(link: "https://sample-videos.com/img/Sample-jpg-image-20mb.jpg", directory: customFilePath, fileName: "test.jpg"),
            DownloadLink(link: "https://file-examples-com.github.io/uploads/2018/04/file_example_OGG_1920_13_3mg.ogg")
        ]
        
        downloadManager = DownloadManager(
            progressHandler: {[weak self] (progress, downloadLink) in
                    guard let weakSelf = self else { return }
                    
                    let progressDescription = String(format: "%0.1f%%", progress * 100)
                    weakSelf.descriptionLabel.text = "Downloading \(progressDescription): \(downloadLink?.fileName ?? "Unknown file")"
                    weakSelf.downloadProgressView.setProgress(progress, animated: false)
            },
            singleCompleteHandler: { [weak self] downloadLink in
                guard let weakSelf = self else { return }
                
                let text = weakSelf.progressTextView.text
                weakSelf.progressTextView.text =
                    text?.appending("Download complete: \(downloadLink?.fileName ?? "Unknown file") \n")
            },
            allCompleteHandler: {  [weak self]  in
                guard let weakSelf = self else { return }
                
                weakSelf.descriptionLabel.text = "All download complete!"
                
                let text = weakSelf.progressTextView.text
                weakSelf.progressTextView.text =
                    text?.appending("All download complete!!")
            }
        )
        
        downloadManager?.addDownload(downloadLinks)
        
    }
}

