//
//  CommunicationHandler.swift
//  OperationQueue
//
//  Created by Sreejesh Krishnan on 07/09/22.
//

import Foundation
import UIKit

class CommunicationHandler {
    
    let photosListVC = PhotosListViewController()
    
    typealias downloadCompletion = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void
    
    func fetchPhotoDetails(url: URL) {
        
        //start activity indicator
        
        let operationQueue = OperationQueue()
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: operationQueue)
        
        let downloadTask = session.downloadTask(with: url)
        
        downloadTask.resume()
    }
}
