//
//  DownloadTask.swift
//  OperationQueue
//
//  Created by Sreejesh Krishnan on 11/09/22.
//

import Foundation

protocol DownloadTaskDelegate: AnyObject {
    func fileReceived(fileLocation: URL)
}

class DownloadTask: NSObject {
    
    var totalDownloaded: Float = 0 {
        didSet {
            self.handleDownloadedProgressPercent?(totalDownloaded)
        }
    }
    typealias progressClosure = ((Float) -> Void)
    var handleDownloadedProgressPercent: progressClosure!
    
    // MARK: - Properties
    private var configuration: URLSessionConfiguration
    
    weak var delegate: DownloadTaskDelegate?
    
    let operationQue = OperationQueue()
    lazy var session: URLSession = {
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: operationQue)
        
        return session
    }()
    
    // MARK: - Initialization
    override init() {
        self.configuration = URLSessionConfiguration.default
        
        super.init()
    }
    
    func download(url: URL, progress: ((Float) -> Void)?) {
        /// bind progress closure to View
        self.handleDownloadedProgressPercent = progress
        
        let task = session.downloadTask(with: url)
        task.resume()
    }
}

extension DownloadTask: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        self.totalDownloaded = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        print("downloaded")
        delegate?.fileReceived(fileLocation: location)
    }
}

