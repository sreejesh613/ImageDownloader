//
//  PhotosListViewController.swift
//  OperationQueue
//
//  Created by Sreejesh Krishnan on 07/09/22.
//

import UIKit

class PhotosListViewController: BaseViewController {

    //MARK: IBOUTLETS
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    
    @IBOutlet weak var progressView1: UIProgressView!
    @IBOutlet weak var progressLabel1: UILabel!
    
    @IBOutlet weak var progressView2: UIProgressView!
    @IBOutlet weak var progressLabel2: UILabel!
    
    @IBOutlet weak var progressView3: UIProgressView!
    @IBOutlet weak var progressLabel3: UILabel!
    
    @IBOutlet weak var progressView4: UIProgressView!
    @IBOutlet weak var progressLabel4: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var syncAsyncSegment: UISegmentedControl!
    
    var selectedSegment: SegmentControlState = .synchronous
    
    var imageDownloadVM: ImageDownloadViewModel!
    
    var downloadTask: DownloadTask!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("ViewWillAppear called")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ViewDidLoad called")
        
        imageDownloadVM = ImageDownloadViewModel()
//        imageDownloadVM?.delegate = self
        initializeUI()
        initializeSegmentedControl()
        initializeProgressViews()
        storeImageUrls()
        
        downloadTask = DownloadTask()
    }
    
    fileprivate func initializeUI() {
        imageView1.image = UIImage(named: "NoData")
        imageView2.image = UIImage(named: "NoData")
        imageView3.image = UIImage(named: "NoData")
        imageView4.image = UIImage(named: "NoData")
    }
    
    fileprivate func initializeSegmentedControl() {
        syncAsyncSegment.selectedSegmentIndex = selectedSegment.rawValue
    }
    
    fileprivate func initializeProgressViews() {
        DispatchQueue.main.async {
            self.progressView1.progress = 0
            self.progressView2.progress = 0
            self.progressView3.progress = 0
            self.progressView4.progress = 0
        }
    }
    
    fileprivate func storeImageUrls() {
        imageDownloadVM?.storeImageUrls()
    }
    
//    func pause(){
//        self.downloadTask.cancel{resumeDataOrNil in
//            guard let resumeData = resumeDataOrNil else {
//                return
//            }
//            self.downloadData = resumeData
//            self.downloadTask = nil
//            self.isDownload = false
//
//            DispatchQueue.main.async {
//                self.startButton.setTitle("Resume", for: UIControl.State.normal)
//            }
//        }
//    }
    
    @IBAction func startTapped(_ sender: UIButton) {
        switch selectedSegment {
        case .synchronous:
            //Initiate synchronous download operation
            imageDownloadVM?.startSequentialDownload(downloadTask: self.downloadTask, session: downloadTask.session)
            
            
        case .asynchronous:
            //Initiate asynchronous download operation
            print("Initiate asynchronous download operations")
        }
        
//        if(!isDownload && downloadData == nil) {
//            let url = URL.init(string: self.url)
//            let request:URLRequest = URLRequest.init(url: url!)
//            self.downloadTask = self.urlSession.downloadTask(with: request)
//            self.downloadTask.resume()
//            isDownload = true;
//            progressLabel1.text = "0%"
//        }
    }
    

    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.selectedSegment = .synchronous
        case 1:
            self.selectedSegment = .asynchronous
        default:
            self.selectedSegment = .asynchronous
        }
        //Start download operation
    }
}



//Download operations
//extension PhotosListViewController {
//    func downloadImages() {
//        switch selectedSegment {
//        case .synchronous:
//            //Create a serial queue
//            imageDownloadVM?.createSerialQueue()
//
//        case .asynchronous:
//            //Create an asynchrous queue
//            imageDownloadVM?.createAsyncQueue()
//
//        default:
//            break
//        }
//    }
//}
//
////MARK: API HANDLING
//extension PhotosListViewController: ImageDownloadViewModelDelegate {
//
//    //Request
//    func fetchImages() {
//        imageDownloadVM
//    }
//
//    //Response
//    func photosReceived(photos: [ImageRecord]?, _ error: Error?, _ errorMessage: String?) {
//
//        guard let error = error else {
//            return
//        }
//        //Error received
//
//
//    }
//}



extension PhotosListViewController: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let percentOfDownload = totalBytesWritten/totalBytesExpectedToWrite
        //Pass percentage to view
        print("Percentage: \(percentOfDownload * 100)")
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        //Finished downloading
        print("Finished downloading to location: \(location)")
    }
}
