//
//  DownloadLink.swift
//  MultiDownloadDemo
//
//  Created by dujia on 2021/06/25.
//

import UIKit

public class DownloadLink: NSObject {
    
    /// Download link
    private(set) public var link: URL?
    
    /// Directory for  saving download file.
    /// Default is `.documentDirectory` folder if not  set
    public var directory: URL?
    
    /// Download file's save name.
    /// Default is link's origin file name if not set
    public var fileName: String?
    
    public var destinyPath: URL {
        return self.directory!.appendingPathComponent(self.fileName!)
    }
    
    init(link: String, directory: URL? = nil, fileName: String = "") {
        
        self.link = URL(string: link) ?? nil
        
        if let saveDirectory = directory {
            self.directory = saveDirectory
        } else {
            self.directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        }
        
        if fileName.isEmpty {
            self.fileName = self.link?.lastPathComponent
        } else {
            self.fileName = fileName
        }
    }
}
