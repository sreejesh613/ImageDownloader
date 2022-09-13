//
//  BaseViewController.swift
//  OperationQueue
//
//  Created by Sreejesh Krishnan on 07/09/22.
//

import UIKit

class BaseViewController: UIViewController {

    var activityView: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK: Common UI Activity Indicator Methods
    //Show
    func showActivityIndicator() {
        activityView = UIActivityIndicatorView(style: .large)
        activityView?.center = self.view.center
        self.view.addSubview(activityView!)
        activityView!.startAnimating()
    }
    
    //Hide
    func hideActivityIndicator() {
        if activityView != nil {
            activityView?.stopAnimating()
            activityView?.removeFromSuperview()
        }
    }
    
    // MARK: Common Alert View
    final func showAlert(title: String, message: String, actionTitles: [String], actions: [((UIAlertAction) -> Void)?]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for (index,title) in actionTitles.enumerated() {
            let alertActions = UIAlertAction(title: title, style: .default, handler: actions[index])
            alertController.addAction(alertActions)
        }
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
