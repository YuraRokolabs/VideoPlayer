//
//  Error+createFromString.swift
//  TestVideoPlayer
//
//  Created by Yurii on 5/17/16.
//  Copyright © 2016 Home. All rights reserved.
//

import UIKit

extension NSError {
    static func createFromString(string:String) -> NSError {
        let error = NSError(domain: "com.home.Home", code: 901, userInfo: [NSLocalizedDescriptionKey:string])
        return error
    }
}