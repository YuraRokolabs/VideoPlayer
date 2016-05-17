//
//  ApiConnectionObject.swift
//  TestVideoPlayer
//
//  Created by Yurii on 5/17/16.
//  Copyright © 2016 Home. All rights reserved.
//

import UIKit
class ApiConnectionObject: HTTPConnectionModel {
    func sendApiRequest(requestUrl: String, params: [String:String], callback:(status:Bool, data:AnyObject?)->Void) {
        let url = NSURL(string:requestUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!
        weak var weakSelf = self

        self.sendRequest(url, params: params, headers: nil) { (response, data, error) in
            guard let slf = weakSelf else {
                return
            }
            let result = slf.parseResponse(response, data: data, error: error)
            callback(status: result.status, data: result.data)
        }
    }
    //private methods
    func parseResponse(response:NSHTTPURLResponse?, data:NSData?, error:NSError?) -> (status:Bool, data:AnyObject?) {
        guard self.errorHandler(error) == true else {
            return (false, error)
        }
        let responseHandlerResult = self.responseHandler(response, data: data)
        return (responseHandlerResult.status, responseHandlerResult.result)
    }
    func errorHandler(error:NSError?) -> Bool {
        guard let _ = error else {
            return true
        }
        return false
    }
    func parseData(data:NSData?) -> (json:AnyObject?, error:NSError?) {
        guard let d = data else {
            return (nil, nil)
        }
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(d, options: NSJSONReadingOptions.AllowFragments)
            return (json, nil)
        } catch let error as NSError {
            return (nil, error)
        }
    }
    
    func responseHandler(response:NSHTTPURLResponse?, data:NSData?) -> (status:Bool, result:AnyObject?) {
        guard let r = response else {
            return (false, nil)
        }
        switch r.statusCode {
        case 200:
            let pData = self.parseData(data)
            if let _ = pData.error {
                return (true, data)
            } else {
                return (true, pData.json)
            }
        default:
            return (false, nil)
        }
    }
}
