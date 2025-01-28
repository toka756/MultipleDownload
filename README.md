# Download multiple files with progress view

## Overview
Download multiple files with progress view.
Just drap&drop `DownloadManager` folder to your xcode project. 
![](https://github.com/toka756/MultipleDownload/blob/mov/serialDownload.gif)

## Steps

### 1. Initialize the `DownloadManager`
Create an instance of `DownloadManager` and optionally provide handlers for progress updates, task completion, and all task completions. If no handlers are specified, default (empty) handlers will be used.

```swift
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

// If download from background this block will be called
// when background downloads are complete 
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
```

### 2.  Add URLs to the download queue to start download

```
let downloadLinks = [
    DownloadLink(link: "https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_5MG.mp3"),
    DownloadLink(link: "http://ipv4.download.thinkbroadband.com/50MB.zip"),
    DownloadLink(link: "https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_2MG.mp3"),
    DownloadLink(link: "http://ipv4.download.thinkbroadband.com/20MB.zip"),
    DownloadLink(link: "https://file-examples-com.github.io/uploads/2017/02/zip_10MB.zip")
]

// Add downloads to the manager
downloadManager.addDownload(downloadLinks)

```

### 3. Restore pending downloads
When resuming the app or recovering from interruptions (e.g., if the app is force-quit or crashes during downloads), restore any pending downloads using restorePendingDownloads(). This ensures that downloads can continue from where they left off, provided resumeData or any saved state exists.

```swift
// Restore any unfinished or pending downloads
downloadManager.restorePendingDownloads()

```
###　4. Tracking background URLSession
To track background downloads session, update your AppDelegate to handle background session events. This ensures that background tasks can notify the app when they are complete.

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    var backgroundSessionCompletionHandler: (() -> Void)?   
    
    // Add support for background downloads
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        backgroundSessionCompletionHandler = completionHandler
    }
}
```
This method is called when a background URLSession completes its tasks. You should store the completionHandler and call it after processing all background events, ensuring the app transitions correctly.

 
 ## Tip
 - When download file from `http` link, turn `ATS` on in `info.plist`
    - `App Transport Security Settins` -> `Allow Arbitrary Loads` -> `YES`

- Change maxOperationCount to make download serially or concurrently .
```
DownloadManager.maxOperationCount = 1  // download files one by one.

DownloadManager.maxOperationCount = 3  // download files concurrently(max to 3)
```
