//
//  HTTPConnectionModel.swift
//  TestVideoPlayer
//
//  Created by Yurii on 5/17/16.
//  Copyright © 2016 Home. All rights reserved.
//

import UIKit

class HTTPConnectionModel: NSObject {
    private var currentTask:NSURLSessionDataTask?
    let session = NSURLSession.sharedSession()
    private func paramsStringFromDictionary(params:[String:String]) -> String {
        var httpData:String = ""
        for (key, value) in params {
            httpData.appendContentsOf(key)
            httpData.appendContentsOf("=")
            httpData.appendContentsOf(value)
            httpData.appendContentsOf("&")
        }
        return httpData
    }
    func sendRequest(url:NSURL, params:[String:String]?, headers:[String:String]?, callback:(response:
        NSHTTPURLResponse?, data:NSData?, error:NSError?)->Void) {
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        if let httpHeaders = headers {
            for (key, value) in httpHeaders {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        if let p = params {
            request.URL = NSURL(string: url.absoluteString + "?" + self.paramsStringFromDictionary(p))
        }
        self.sendRequest(request, callback: callback)
    }
    func sendRequest(request:NSURLRequest, callback:(response:NSHTTPURLResponse?, data:NSData?, error:NSError?)->Void) {
        weak var weakSelf = self
        let task = self.session.dataTaskWithRequest(request) { (data, response, error) in
            callback(response: response as? NSHTTPURLResponse, data: data, error: error)
            if let slf = weakSelf {
                slf.currentTask = nil
            }
        }
        self.currentTask = task
        task.resume()
    }
    func cancelTask() {
        guard let task = self.currentTask else {
            return
        }
        task.cancel()
        self.currentTask = nil
    }
}
