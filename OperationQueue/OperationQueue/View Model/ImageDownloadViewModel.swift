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
            let imageRecord = ImageRecord(name: "image \(i)", url: URL(string: url.rawValue), index: i)
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
    
    var queue : OperationQueue!
    var downloadOP: DownloadOperation?
    
    weak var delegate: ImageDownloadViewModelDelegate?
    
    override init () {
        super.init()
        queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
    }
    
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
    
    func startSequentialDownload() {
        
        if images.count != 0 {
            
            //Finished downloading all images
            let completionOperation = BlockOperation {
                print("finished downloading all images")
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "allImagesDownloaded"), object: nil)
            }
            
            for image in images {
                
                let operation = DownloadOperation( downloadTaskURL: image.url, index: image.index, completionHandler: { (localURL, urlResponse, error, originalUrl)  in
                    
                    var index = 0
                    if let url = originalUrl {
                        let indexOfItem = CommonMethods.getIndexOf(url.absoluteString, images: self.images)
                        index = indexOfItem
                    }
                    
                    //File URL received
                    guard let fileUrl = localURL else {
                        return
                    }
                    let data = try! Data(contentsOf: fileUrl)
                    let imageDownloaded = UIImage(data: data)
                    
                    self.delegate?.imageDownloaded(image: imageDownloaded, index: index)
                })
                operation.delegate = self
                completionOperation.addDependency(operation)
                self.queue.addOperation(operation)
            }
            self.queue.addOperation(completionOperation)

        } else {
            return
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

//MARK: URLSESSION DOWNLOAD DELEGATES
extension ImageDownloadViewModel: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {

        let written = Float(totalBytesWritten) * 100
        let totalExpected = Float(totalBytesExpectedToWrite)
        let percentage = written/totalExpected
        
        //Calculate index of the item
        var indexOfItem = 0
        if let url = downloadTask.response?.url {
            indexOfItem = CommonMethods.getIndexOf(url.absoluteString, images: self.images) 
        }
        
        self.delegate?.progressReceived(for: indexOfItem, progress: percentage)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        //Finished downloading
        print("Finished downloading to location: \(location)")
        
        //Calculate index of the item
        var indexOfItem = 0
        if let url = downloadTask.response?.url {
            indexOfItem = CommonMethods.getIndexOf(url.absoluteString, images: self.images)
        }

        //File URL received
        let data = try! Data(contentsOf: location)
        let imageDownloaded = UIImage(data: data)
        
        self.delegate?.imageDownloaded(image: imageDownloaded, index: indexOfItem)
    }
}

extension ImageDownloadViewModel: DownloadOperationDelegate {
    
    func imageFileReceived(url: URL, index: Int) {
        print("Image file received: \(url), for index: \(index)")
    }
    
    func progressReceived(progress: Float, index: Int) {
        print("Progress received: \(progress), for index: \(index)")
    }
}
