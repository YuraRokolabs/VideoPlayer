//
//  PlayerView.swift
//  TestVideoPlayer
//
//  Created by Yurii on 5/17/16.
//  Copyright © 2016 Home. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerView: UIView {
    var playerDidFinishPlayCallback:(()->Void)?
    var url:NSURL? = nil {
        didSet {
            self.player.replaceCurrentItemWithPlayerItem(nil)
            guard let url = self.url else {
                return
            }
            let asset = AVURLAsset(URL: url)
            weak var weakSelf = self
            asset.loadValuesAsynchronouslyForKeys(["playable"]) {
                guard let slf = weakSelf else {
                    return
                }
                var error:NSError?
                guard asset.URL.absoluteString == slf.url?.absoluteString else {
                    return
                }
                if asset.statusOfValueForKey("playable", error: &error) == AVKeyValueStatus.Loaded {
                    slf.player.replaceCurrentItemWithPlayerItem(AVPlayerItem(asset: asset))
                    dispatch_async(dispatch_get_main_queue(), { 
                        self.player.play()
                    })
                }
            }
            
            
        }
    }
   
    private var player:AVPlayer
    private var avPlayerLayer:AVPlayerLayer
    
    required init?(coder aDecoder: NSCoder) {
        self.player = AVPlayer()
        self.avPlayerLayer = AVPlayerLayer(player: self.player)
        self.avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        super.init(coder: aDecoder)
        self.layer.addSublayer(self.avPlayerLayer)
        self.avPlayerLayer.frame = self.bounds
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerDidFinishPlay(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.avPlayerLayer.frame = self.bounds
    }
    
    func playerDidFinishPlay(notification:NSNotification) {
        if notification.object as? AVPlayerItem == self.player.currentItem, let callback = self.playerDidFinishPlayCallback {
            callback()
        }
    }
}
