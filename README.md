# Download multiple files with progress view

## Overview
Download multiple files with progress view.

Change maxOperationCount to make download serially or concurrently .

```
DownloadManager.maxOperationCount = 1  // download files one by one.

DownloadManager.maxOperationCount = 3  // download files concurrently(max to 3)
```

## Tips

1. Add urls to download queue then the download will start.

```
public var downloadLinks = [
    "https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_5MG.mp3",
    "http://ipv4.download.thinkbroadband.com/50MB.zip",
    "https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_2MG.mp3",
    "http://ipv4.download.thinkbroadband.com/20MB.zip",
    "https://file-examples-com.github.io/uploads/2017/02/zip_10MB.zip",
]

downloadLinks.forEach{ link in
    if let url = URL(string: link) {
        downloadManager.addDownload(url)
    }
}
```

2.  Implement `DownloadProcessProtocol` to track download progress.

```
/// Share downloding progress with outside
func downloadingProgress(_ percent: Float, fileName: String)

/// Get called when download complete
func downloadSucceeded(_ fileName: String)

/// Get called when error occured while download.
func downloadWithError(_ error: Error?, fileName: String)
```

3. Do something when all of the files have been download.
 After add download url links, add code block to  `addAllDownloadComplete`  

 ```
 downloadManager.addAllDownloadComplete({
    /// Do something here
 })
 
 ```
