//
//  ViewController.swift
//  TestVideoPlayer
//
//  Created by Yurii on 5/17/16.
//  Copyright © 2016 Home. All rights reserved.
//

import UIKit
import QuartzCore
class RoundIndicator:UIView {
    var value:CGFloat = 0.0 {
        didSet {
            self.circleLayer.strokeEnd = self.value
        }
    }
    let circleLayer: CAShapeLayer = CAShapeLayer()
    
    func setupView() {
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: frame.size.width/2.0, startAngle: CGFloat( -1 * M_PI_2), endAngle: CGFloat(M_PI * 2.0 - M_PI_2), clockwise: true)
        self.circleLayer.path = circlePath.CGPath
        self.circleLayer.fillColor = UIColor.clearColor().CGColor
        self.circleLayer.strokeColor = UIColor.redColor().CGColor//self.backgroundColor!.CGColor
        self.backgroundColor = UIColor.clearColor()
        self.circleLayer.lineWidth = 2.0;
        self.circleLayer.strokeEnd = 0.0
        self.layer.addSublayer(circleLayer)
    }
}
class VideoCell:UITableViewCell {
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var indicatorView:RoundIndicator!
    private var imageDownloadModel:ImageDownloadModel = ImageDownloadModel()
    private var videoItem:VideoItem!
    override func layoutSubviews() {
        super.layoutSubviews()
        self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.width / 2.0
    }
    func setVideoItem(videoItem:VideoItem) {
        self.indicatorView.setupView()
        self.videoItem = videoItem
        self.profileImageView.image = nil
        self.titleLabel.text = videoItem.title
        if let url = videoItem.image {
            weak var weakSelf = self
            self.imageDownloadModel.downloadImageWithoutError(url, callback: { (file) in
                guard let path = file else {
                    return
                }
                guard let slf = weakSelf else {
                    return
                }
                if slf.videoItem.image == url {
                    guard let data = NSData(contentsOfURL: path) else {
                        return
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        slf.profileImageView.image = UIImage(data: data)
                    })
                }
                
            })
        }
        
    }
    override func setSelected(selected: Bool, animated: Bool) {
        if selected {
            self.indicatorView.hidden = false
            self.titleLabel.textColor = UIColor.blueColor()
        } else {
            self.indicatorView.hidden = true
            self.titleLabel.textColor = UIColor.blackColor()
        }
    }
}
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var tableview:UITableView!
    
    let videoItemsModel:DataModel = DataModel(baseUrl: "https://api.vineapp.com/timelines/tags/leagueoflegends ")
    private var selectedIndex:Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadData()
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(timerAction(_:)), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        weak var weakSelf = self
        self.playerView.playerDidFinishPlayCallback = {
            guard let slf = weakSelf else {
                return
            }
            slf.playNextTrack()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func timerAction(timer:NSTimer) {
        guard let index = self.selectedIndex else {
            return
        }
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        guard let cell = self.tableview.cellForRowAtIndexPath(indexPath) as? VideoCell else {
            return
        }
        var progress:Float64 = 0
        if self.playerView.getCurrentTime() > 0 {
            progress = self.playerView.getCurrentTime() / self.playerView.getDuration()
        }
        cell.indicatorView.value = CGFloat(progress)
    }
    func loadData() {
        weak var weakSelf = self
        self.videoItemsModel.loadData { (error) in
            guard error == nil else {
                return
            }
            guard let slf = weakSelf else {
                return
            }
            if slf.videoItemsModel.loadedNewItems {
                dispatch_async(dispatch_get_main_queue(), {
                    slf.tableview.reloadData()
                    if slf.selectedIndex == nil {
                        slf.selectItem(0)
                    }
                })
            }
        }
    }
    func reloadData() {
        self.videoItemsModel.reloadData()
        self.loadData()
    }
    func playNextTrack() {
        guard let selectedIndex = self.selectedIndex else {
            return self.selectItem(0)
        }
        self.selectItem(selectedIndex + 1)
    }
    func selectItem(index:Int) {
        var newSelectedIndex = index
        if newSelectedIndex >= self.videoItemsModel.data.count {
            newSelectedIndex = 0
        }
        guard self.selectedIndex != newSelectedIndex else {
            return
        }
        if self.selectedIndex != nil {
            self.tableview.deselectRowAtIndexPath(NSIndexPath(forRow:self.selectedIndex!, inSection: 0), animated: true)
        }
        self.tableview.selectRowAtIndexPath(NSIndexPath(forRow: newSelectedIndex, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
        self.selectedIndex = newSelectedIndex
        self.playerView.url = self.videoItemsModel.data[newSelectedIndex].url
    }
    //tableview
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.videoItemsModel.data.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VideoCell", forIndexPath: indexPath) as! VideoCell
        cell.setVideoItem(self.videoItemsModel.data[indexPath.row])
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 61
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectItem(indexPath.row)
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row > self.videoItemsModel.data.count - 5 {
            self.loadData()
        }
    }
}

