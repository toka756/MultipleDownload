//
//  ViewController.swift
//  MultiDownloadDemo
//
//  Created by dujia on 2020/12/08.
//

import UIKit

class SerialViewController: UIViewController {
    
    fileprivate var downloadManager = DownloadManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadManager.processDelegate = self
        
    }

}

extension SerialViewController: DownloadProcessProtocol {
    
    func downloadingProgress(_ percent: Float) {
        
    }
    
    func downloadSucceeded() {
        
    }

    func downloadWithError(error: Error?) {
        
    }
}

