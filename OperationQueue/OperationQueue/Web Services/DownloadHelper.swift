//
//  DownloadHelper.swift
//  OperationQueue
//
//  Created by Sreejesh Krishnan on 07/09/22.
//

import Foundation
import UIKit

enum PhotoState {
    case ready, downloading, downloaded, failed
}

class DownloadOperation : AsynchronousOperation {
    var task: URLSessionTask!
    
    init(session: URLSession, url: URL) {
        super.init()
        
        task = session.downloadTask(with: url) { temporaryURL, response, error in
            defer { self.finish() }
            
            guard
                let httpResponse = response as? HTTPURLResponse,
                200..<300 ~= httpResponse.statusCode
            else {
                // handle invalid return codes however you'd like
                return
            }
            
            guard let temporaryURL = temporaryURL, error == nil else {
                print(error ?? "Unknown error")
                return
            }
            
            do {
                let manager = FileManager.default
                let destinationURL = try manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    .appendingPathComponent(url.lastPathComponent)
                try? manager.removeItem(at: destinationURL)                   // remove the old one, if any
                try manager.moveItem(at: temporaryURL, to: destinationURL)    // move new one there
            } catch let moveError {
                print("\(moveError)")
            }
        }
    }
    
    override func cancel() {
        task.cancel()
        super.cancel()
    }
    
    override func main() {
        task.resume()
    }
    
}
