//
//  ImageDownloadViewModel.swift
//  OperationQueue
//
//  Created by Sreejesh Krishnan on 07/09/22.
//

import Foundation
import UIKit

enum SegmentControlState: Int {
    case synchronous = 0
    case asynchronous
}

protocol ImageDownloadViewModelDelegate: AnyObject {
    func imageDownloaded(image: UIImage?, index: Int)
    func didFailToDownload(with error: Error)
    func progressReceived(for index: Int, progress: Float)
}

//MARK: STORE IMAGE URLS
extension ImageDownloadViewModel {
    func storeImageUrls() {
        var i = 1
        for url in ImageUrls.allCases {
            let imageRecord = ImageRecord(name: "image \(i)", url: URL(string: url.rawValue))
            i += 1
            self.images.append(imageRecord)
        }
    }
}

class ImageDownloadViewModel: NSObject {
    
    var images: [ImageRecord] = []
    var index = -1
    
    typealias downloadCompletion = ((_ urlReceived: URL?, _ error: Error?) -> Void)
    let photosListVC = PhotosListViewController()
    var downloadTask: URLSessionDownloadTask!
    
    weak var delegate: ImageDownloadViewModelDelegate?
    
    func fetchPhotoDetails(url: URL) {
        
        //start activity indicator
        let queue = OperationQueue()
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: queue)
        let urlRequest = URLRequest(url: url)
        downloadTask = session.downloadTask(with: urlRequest)
        
        downloadTask.resume()
    }
}

//MARK: SEQUENTIAL DOWNLOAD
extension ImageDownloadViewModel {
    
    func startSequentialDownload(downloadTask: DownloadTask, session: URLSession) {
        let operationQueue = OperationQueue()
        operationQueue.name = "Download Queue"
        operationQueue.maxConcurrentOperationCount = 4
        
        for i in 0..<images.count {
            guard let url = images[i].url else { return }
            
            operationQueue.addOperation(DownloadOperation(session: session, url: url))
            print(url)
//            downloadTask.download(url: url) { progress in
//                print("Progress received:\(i)-- \(progress)")
//                self.delegate?.progressReceived(for: i, progress: progress)
//            }
            
        }
    }
}

//MARK: ASYNCHRONOUS DOWNLOAD
extension ImageDownloadViewModel {
    func startAsynchronousDownload() {
        for index in 0..<images.count {
            guard let imageUrl = images[index].url else { return }
            self.fetchPhotoDetails(url: imageUrl)
        }
    }
}

extension ImageDownloadViewModel: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        //Pass percentage to view
        let written = Float(totalBytesWritten) * 100
        let totalExpected = Float(totalBytesExpectedToWrite)
        let percentage = written/totalExpected
        
        //Calculate index of the item
        var indexOfItem = 0
        if let url = downloadTask.response?.url {
            indexOfItem = self.getIndexOf(url.absoluteString)
        }
        
        self.delegate?.progressReceived(for: indexOfItem, progress: percentage)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        //Finished downloading
        print("Finished downloading to location: \(location)")
        
        //Calculate index of the item
        var indexOfItem = 0
        if let url = downloadTask.response?.url {
            indexOfItem = self.getIndexOf(url.absoluteString)
        }

        //File URL received
        let data = try! Data(contentsOf: location)
        let imageDownloaded = UIImage(data: data)
        
        self.delegate?.imageDownloaded(image: imageDownloaded, index: indexOfItem)
    }
}

//Extension to find index of the image url from the images array
extension ImageDownloadViewModel {
    func getIndexOf(_ item: String) -> Int {
        let indexCalculated = images.map({ $0.url }).firstIndex(of: URL(string: item)) ?? 0
        return indexCalculated
    }
    
}
