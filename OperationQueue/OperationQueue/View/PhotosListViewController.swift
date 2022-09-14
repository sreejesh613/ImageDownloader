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
    
    //MARK: PROPERTIES
    var selectedSegment: SegmentControlState = .synchronous
    var imageDownloadVM: ImageDownloadViewModel!
    var queue : OperationQueue!
    
    //MARK: VIEW LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ViewDidLoad called")
        
        imageDownloadVM = ImageDownloadViewModel()
        imageDownloadVM?.delegate = self
        queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        initializeImageViews()
        initializeSegmentedControl()
        initializeProgressViews()
        initializeProgressLabels()
        storeImageUrls()
        addNotificationObserver()
    }
    
    //MARK: METHODS
    fileprivate func initializeImageViews() {
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
    
    fileprivate func initializeProgressLabels() {
        DispatchQueue.main.async {
            self.progressLabel1.text = "0%"
            self.progressLabel2.text = "0%"
            self.progressLabel3.text = "0%"
            self.progressLabel4.text = "0%"
        }
    }
    
    fileprivate func storeImageUrls() {
        imageDownloadVM?.storeImageUrls()
    }
    
    func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(allImagesDownloaded(_:)), name: Notification.Name(rawValue: "allImagesDownloaded"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func allImagesDownloaded(_ notification: Notification) {
        DispatchQueue.main.async {
            self.hideActivityIndicator()
            self.syncAsyncSegment.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func startTapped(_ sender: UIButton) {
        switch selectedSegment {
        case .synchronous:
            //Initiate synchronous download operation
            startSequentialDownload()
        case .asynchronous:
            //Initiate asynchronous download operation
            startAsyncDownload()
        }
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        self.initializeImageViews()
        self.initializeProgressViews()
        self.initializeProgressLabels()
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

//MARK: API HANDLING
extension PhotosListViewController: ImageDownloadViewModelDelegate {

    //Request
    //Sequential download
    fileprivate func startSequentialDownload() {
        self.showActivityIndicator()
        self.syncAsyncSegment.isUserInteractionEnabled = false
        imageDownloadVM.startSequentialDownload()
    }
    
    //Asynchronous download
    fileprivate func startAsyncDownload() {
        imageDownloadVM.startAsynchronousDownload()
    }
    
    //Async Download response
    func imageDownloaded(image: UIImage?, index: Int) {
        self.setImage(image: image, index: index)
        
        progressReceived(for: index, progress: 100)
    }
    
    func didFailToDownload(with error: Error) {
        self.showAlert(title: "Error", message: error.localizedDescription, actionTitles: ["OK"], actions: [nil])
    }
    
    func progressReceived(for index: Int, progress: Float) {
        DispatchQueue.main.async {
            switch index {
            case 0:
                self.progressLabel1.text = "\(Int(progress))%"
                self.progressView1.progress = progress
            case 1:
                self.progressLabel2.text = "\(Int(progress))%"
                self.progressView2.progress = progress
            case 2:
                self.progressLabel3.text = "\(Int(progress))%"
                self.progressView3.progress = progress
            case 3:
                self.progressLabel4.text = "\(Int(progress))%"
                self.progressView4.progress = progress
            default:
                break
            }
        }
    }
    
    fileprivate func setImage(image: UIImage?, index: Int) {
        DispatchQueue.main.async {
            switch index {
            case 0:
                self.imageView1.image = image
            case 1:
                self.imageView2.image = image
            case 2:
                self.imageView3.image = image
            case 3:
                self.imageView4.image = image
            default:
                break
            }
        }
    }
    
}
