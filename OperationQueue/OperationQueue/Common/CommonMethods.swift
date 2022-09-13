//
//  CommonMethods.swift
//  OperationQueue
//
//  Created by Sreejesh Krishnan on 14/09/22.
//

import Foundation

class CommonMethods {
    static func getIndexOf(_ item: String, images: [ImageRecord]) -> Int {
        let indexCalculated = images.map({ $0.url }).firstIndex(of: URL(string: item)) ?? 0
        return indexCalculated
    }
}

