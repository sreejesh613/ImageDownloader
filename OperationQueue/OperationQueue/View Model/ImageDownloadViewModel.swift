//
//  ImageDownloadViewModel.swift
//  OperationQueue
//
//  Created by Sreejesh Krishnan on 07/09/22.
//

import Foundation

enum SegmentControlState: Int {
    case synchronous = 0
    case asynchronous
}

protocol ImageDownloadViewModelDelegate: AnyObject {
    func photosReceived(photos: [ImageRecord]?, _ error: Error?, _ errorMessage: String?)
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
    
    let commnHandler = CommunicationHandler()
    var images: [ImageRecord] = []
    
    weak var delegate: ImageDownloadViewModelDelegate?


    
    override init() {
        super.init()
    }
}

//MARK: ASYNCHRONOUS DOWNLOAD
extension ImageDownloadViewModel {
    func startAsynchronousDownload() {
        for image in images {
            guard let imageUrl = image.url else { return }
            commnHandler.fetchPhotoDetails(url: imageUrl)
        }
    }
}

//MARK: SEQUENTIAL DOWNLOAD
extension ImageDownloadViewModel {
    func startSequentialDownload(downloadTask: DownloadTask, session: URLSession) {
        let operationQueue = OperationQueue()
        operationQueue.name = "Download Queue"
        operationQueue.maxConcurrentOperationCount = 1
        
        for image in images {
            guard let url = image.url else { return }
            
            operationQueue.addOperation(DownloadOperation(session: session, url: url))

            downloadTask.download(url: url) { progress in
                print("Progress received: \(progress)")
            }
            
        }
    }
}




extension ImageDownloadViewModel {
    
    //Create Serial Queue
    func createSerialQueue(with imageDetails: [ImageRecord]) {
        let serialQueue = DispatchQueue(label: "Serial Queue")
        serialQueue.sync {
            
        }
    }
    
    //Create Asynchronous Queue
    func createAsyncQueue() {
        
    }
}
