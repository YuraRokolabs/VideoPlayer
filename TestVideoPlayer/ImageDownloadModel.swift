//
//  ImageDownloadModel.swift
//  TestVideoPlayer
//
//  Created by Yurii on 5/17/16.
//  Copyright © 2016 Home. All rights reserved.
//

import UIKit

class ImageDownloadModel: NSObject {
    private static var imageCashe:[String:NSURL?] = [String:NSURL]()
    static let sharedInstance:ImageDownloadModel = ImageDownloadModel()
    func downloadImageWithoutError(url:String, callback:(file:NSURL?)->Void) {
        self.downloadImage(url) { (file, error) in
            if let f = file {
                guard let _ = NSData(contentsOfURL: f) else {
                    callback(file: nil)
                    return
                }
                return callback(file: file)
                
            }
            return callback(file: nil)
        }
    }
    func downloadImage(url:String, callback:(file:NSURL?, error:NSError?)->Void) {
        if let filePath = ImageDownloadModel.imageCashe[url] {
            callback(file: filePath, error: nil)
            return
        }
        NSURLSession.sharedSession().downloadTaskWithURL(NSURL(string: url)!, completionHandler: { (file, response, error) -> Void in
            callback(file: file, error: error)
            guard let path = file else {
                return
            }
            if let tempData = NSData(contentsOfURL: path) {
                let fileName:String = NSTemporaryDirectory()+String(format: "%f.png", NSDate().timeIntervalSince1970)
                if tempData.writeToFile(fileName, atomically: true) {
                    ImageDownloadModel.setCashe(url, fileUrl: NSURL(fileURLWithPath: fileName))
                }
            }
        }).resume()
    }
    static func setCashe(url:String, fileUrl:NSURL) {
        ImageDownloadModel.imageCashe[url] = fileUrl
    }
}
