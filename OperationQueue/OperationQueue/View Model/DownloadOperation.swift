
import Foundation
import UIKit

protocol DownloadOperationDelegate: AnyObject {
    func imageFileReceived(url: URL, index: Int)
    func progressReceived(progress: Float, index: Int)
}

class DownloadOperation : Operation {
    
    private var task : URLSessionDownloadTask!
    
    var session : URLSession!
    var index : Int?
    weak var delegate: DownloadOperationDelegate?
    
    enum OperationState : Int {
        case ready
        case executing
        case finished
    }
    
    // default state is ready (when the operation is created)
    private var state : OperationState = .ready {
        willSet {
            self.willChangeValue(forKey: "isExecuting")
            self.willChangeValue(forKey: "isFinished")
        }
        
        didSet {
            self.didChangeValue(forKey: "isExecuting")
            self.didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isReady: Bool { return state == .ready }
    override var isExecuting: Bool { return state == .executing }
    override var isFinished: Bool { return state == .finished }
    
    init(downloadTaskURL: URL?, index: Int?, completionHandler: ((URL?, URLResponse?, Error?, _ imageUrl: URL?) -> Void)?) {
        super.init()
        
        guard let downloadUrl = downloadTaskURL else { return }
        session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
       
        self.index = index
        let urlRequest = URLRequest(url: downloadUrl)
        task = session.downloadTask(with: urlRequest, completionHandler: { urlReceived, urlResponse, error in
            
            if let completionHandler = completionHandler {

                // localURL is the temporary URL the downloaded file is located
                completionHandler(urlReceived, urlResponse, error, self.task.response?.url)
            }
            
            self.state = .finished
            
        })
    }
    
    override func start() {

        if(self.isCancelled) {
            state = .finished
            return
        }
        
        // set the state to executing
        state = .executing
        
        print("downloading \(self.task.originalRequest?.url?.absoluteString ?? "")")
            
            // start the downloading
            self.task.resume()
    }
    
    override func cancel() {
        super.cancel()
        
        // cancel the downloading
        self.task.cancel()
    }
}

extension DownloadOperation: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let written = Float(totalBytesWritten) * 100
        let totalExpected = Float(totalBytesExpectedToWrite)
        let percentage = written/totalExpected
        
        self.delegate?.progressReceived(progress: percentage, index: self.index ?? 0)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        //Finished downloading
        print("Finished downloading to location: \(location)")
        
        self.delegate?.imageFileReceived(url: location, index: self.index ?? 0)
        
    }
    
    
}
