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
        downloadManager.addDownload(downloadLinks)
    }
}

