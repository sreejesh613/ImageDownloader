//
//  ImageRecord.swift
//  OperationQueue
//
//  Created by Sreejesh Krishnan on 10/09/22.
//

import Foundation
import UIKit

enum ImageUrls: String, CaseIterable {
    case imageUrl1 = "https://cdn.wallpapersafari.com/36/6/WCkZue.png"
    case imageUrl2 = "https://www.iliketowastemytime.com/sites/default/files/hamburg-germany-nicolas-kamp-hd-wallpaper_0.jpg"
    case imageUrl3 = "https://images.hdqwalls.com/download/drift-transformers-5-the-last-knight-qu-5120x2880.jpg"
    case imageUrl4 = "https://survarium.com/sites/default/files/calendars/survarium-wallpaper-calendar-february-2016-en-2560x1440.png"
}

class ImageRecord {
    let name: String
    let url: URL?
    var image = UIImage(named: "Placeholder")
    var index: Int?
    
    init(name: String, url: URL?, index: Int) {
        self.name = name
        self.url = url
        self.index = index
    }
}
