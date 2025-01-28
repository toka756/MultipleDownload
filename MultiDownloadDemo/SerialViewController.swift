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
            
        // Initialize DownloadManager with handlers
        
        // Update the progress UI
        let progressHandler: ProgressHandler = { progress, downloadLink in
            let progressDescription = String(format: "%0.1f%%", progress * 100)
            print("Progress: \(progressDescription) for file: \(downloadLink?.fileName ?? "Unknown")")
        }

        // Called when a single download task is complete
        let singleCompleteHandler: SingleTaskCompleteHandler = { downloadLink in
            print("Download finished for: \(downloadLink?.fileName ?? "Unknown file")")
        }

        // Called when all download tasks are complete
        let allCompleteHandler: AllTasksCompleteHandler = {
            print("All downloads are completed!")
        }

        // Called when background downloads are complete if download from background
        let backgroundCompletion: () -> Void = {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.backgroundSessionCompletionHandler?()
            }
            
            print("All tasks completed in background ")
        }

        // Initialize DownloadManager with external handlers
        let downloadManager = DownloadManager(
            progressHandler: progressHandler,
            singleCompleteHandler: singleCompleteHandler,
            allCompleteHandler: allCompleteHandler,
            backgroundCompletion: backgroundCompletion
        )

        let customFilePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let downloadLinks = [
            DownloadLink(link: "https://www.dropbox.com/s/6xlpner3s6q336f/file1.mp4?dl=1"),
            DownloadLink(link: "https://www.dropbox.com/s/73ymbx6icoiqus9/file2.mp4?dl=1", directory: customFilePath, fileName: "test.mp4"),
            DownloadLink(link: "https://www.dropbox.com/s/4pw4jwiju0eon6r/file3.mp4?dl=1")
        ]
        // Add download link and start download
        downloadManager.addDownload(downloadLinks)
    }
    
    @IBAction func resumeDownload(_ sender: Any) {
        // Resume any pending downloads using previously saved resume data.
        // This method is triggered when the user interacts with the UI (e.g., button press).
        downloadManager?.restorePendingDownloads()
    }
}

