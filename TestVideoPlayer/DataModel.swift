//
//  APIConnectionModel.swift
//  TestVideoPlayer
//
//  Created by Yurii on 5/17/16.
//  Copyright © 2016 Home. All rights reserved.
//

import UIKit
class VideoItem: NSObject {
    var image:String?
    var title:String?
    var url:NSURL!
    init?(json:[String:AnyObject]) {
        guard let url = json["videoLowURL"] as? String else {
            return nil
        }
        self.url = NSURL(string: url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!
        self.image = json["thumbnailUrl"] as? String
        self.title = json["username"] as? String
        super.init()
    }
}
class DataModel: NSObject {
    private var baseUrl:String
    private var page: Int = 1
    private var totalCount: Int?
    private var isLoading:Bool = false
    private(set) var data:[VideoItem] = []
    private var connection:ApiConnectionObject = ApiConnectionObject()
    private(set) var loadedNewItems:Bool = false
    init(baseUrl:String) {
        self.baseUrl = baseUrl
        super.init()
    }
    func loadData(callback:(error:NSError?)->Void) {
        self.loadedNewItems = false
        guard self.isLoading == false && self.totalCount != self.data.count else {
            return callback(error: nil)
        }
        self.isLoading = true
        weak var weakSelf = self
        self.connection.sendApiRequest(self.baseUrl, params: ["page":"\(self.page)"]) { (status, data) in
            guard status == true, let d = data as? [String:AnyObject], let slf = weakSelf else {
                return callback(error: NSError.createFromString("Something went wrong"))
            }
            guard d["success"] as? Bool == true else {
                return callback(error: NSError.createFromString("Something went wrong"))
            }
            slf.totalCount = d["data"]?["count"] as? Int
            slf.page += 1
            slf.isLoading = false
            guard let records = d["data"]?["records"] as? [[String:AnyObject]] else {
                return callback(error: nil)
            }
            var array:[VideoItem] = []
            for record in records {
                guard let videoItem = VideoItem(json: record) else {
                    continue
                }
                array.append(videoItem)
            }
            if array.count > 0 {
                slf.loadedNewItems = true
                slf.data.appendContentsOf(array)
            }
            callback(error: nil)
        }
    }
    func reloadData() {
        self.page = 1
        self.totalCount = nil
        self.isLoading = false
        self.data.removeAll()
    }
}
