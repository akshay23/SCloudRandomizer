//
//  InterfaceController.swift
//  Scloudy WatchKit Extension
//
//  Created by Akshay Bharath on 6/17/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

    @IBOutlet var lblMessage: WKInterfaceLabel!
    @IBOutlet var imgTrackArt: WKInterfaceImage!
    @IBOutlet var btnNext: WKInterfaceButton!
    @IBOutlet var btnPlay: WKInterfaceButton!
    @IBOutlet var lblTrackTitle: WKInterfaceLabel!
    @IBOutlet var grpButtons: WKInterfaceGroup!
    
    var wormhole: MMWormhole!
    var image: UIImage?
 
    private let downloadSession = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration())

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        self.wormhole = MMWormhole(applicationGroupIdentifier: "group.com.actionman.scloudy", optionalDirectory: "wormhole")
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        let info = ["Active":"YES"]
        WKInterfaceController.openParentApplication(info) {
            (replyDictionary, error) -> Void in
            if replyDictionary != nil && replyDictionary["Active"] as! String == "YES" {
                let refreshData = ["RefreshData": "YES"]
                WKInterfaceController.openParentApplication(refreshData) {
                    (replyDictionary, error) -> Void in
                    if ((error) != nil) {
                        println("Could not refresh track data")
                    }
                }
            } else {
                self.lblMessage.setHidden(false)
                self.grpButtons.setHidden(true)
                self.lblTrackTitle.setHidden(true)
                self.imgTrackArt.setHidden(true)
            }
        }
        
        // Show label if app not running
        self.wormhole.listenForMessageWithIdentifier("AppRunning") {
            (messageObject) -> Void in
            if let message: String = messageObject as? String {
                if message == "YES" {
                    self.lblMessage.setHidden(true)
                } else {
                    self.lblMessage.setHidden(false)
                    self.grpButtons.setHidden(true)
                    self.lblTrackTitle.setHidden(true)
                    self.imgTrackArt.setHidden(true)
                }
            }
        }
        
        // Show label if user not logged in
        self.wormhole.listenForMessageWithIdentifier("IsUserLoggedIn") {
            (messageObject) -> Void in
            if let message: String = messageObject as? String {
                if message == "YES" {
                    self.lblMessage.setHidden(true)
                } else {
                    self.lblMessage.setHidden(false)
                    self.grpButtons.setHidden(true)
                    self.lblTrackTitle.setHidden(true)
                    self.imgTrackArt.setHidden(true)
                }
            }
        }
        
        // Check for track title change
        self.wormhole.listenForMessageWithIdentifier("TrackTitle") {
            (messageObject) -> Void in
            if let title: String = messageObject as? String {
                self.lblTrackTitle.setText(title)
            }
        }
        
        // Check for new track art changes
        self.wormhole.listenForMessageWithIdentifier("TrackImageURL") {
            (messageObject) -> Void in
            if let url: NSURL = messageObject as? NSURL {
                dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.value), 0)) {
                    var replace: String = url.absoluteString!.stringByReplacingOccurrencesOfString("-t300x300", withString: "-large", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    var actualURL: NSURL! = NSURL(string: replace)!
                    if let checkURL = actualURL {
                      var data: NSData = NSData(contentsOfURL: checkURL)!
                      self.image = UIImage(data: data)!
                      dispatch_async(dispatch_get_main_queue()) {
                          self.imgTrackArt.setImage(self.image)
                          self.imgTrackArt.setHidden(false)
                          self.lblTrackTitle.setHidden(false)
                          self.grpButtons.setHidden(false)
                      }
                    }
                }
            }
        }
        
        // Check track play/pause status
        self.wormhole.listenForMessageWithIdentifier("IsTrackPlaying") {
            (messageObject) -> Void in
            if let isPlaying: String = messageObject as? String {
                if isPlaying == "YES" {
                    self.btnPlay.setTitle("Pause")
                } else {
                    self.btnPlay.setTitle("Play")
                }
            }
        }
        
        // Check track play/pause status
        self.wormhole.listenForMessageWithIdentifier("IsTrackReadyToPlay") {
            (messageObject) -> Void in
            if let isReady: String = messageObject as? String {
                if isReady == "YES" {
                    self.btnPlay.setEnabled(true)
                    self.btnNext.setEnabled(true)
                } else {
                    self.btnPlay.setEnabled(false)
                    self.btnNext.setEnabled(false)
                }
            }
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        self.wormhole.stopListeningForMessageWithIdentifier("AppRunning")
        self.wormhole.stopListeningForMessageWithIdentifier("IsUserLoggedIn")
        self.wormhole.stopListeningForMessageWithIdentifier("TrackImageURL")
        self.wormhole.stopListeningForMessageWithIdentifier("TrackTitle")
        self.wormhole.stopListeningForMessageWithIdentifier("IsTrackPlaying")
    }

    @IBAction func doPlayNext() {
        let info = ["NextTrack":"YES"]
        WKInterfaceController.openParentApplication(info) {
            (replyDictionary, error) -> Void in
            if replyDictionary != nil && replyDictionary["NextTrack"] as! String == "YES" {
                self.btnPlay.setEnabled(false)
                self.btnNext.setEnabled(false)
            } else {
                println("Could not get next track!")
            }
        }
    }
    
    @IBAction func doPlayPause() {
        let info = ["PlayPauseTrack":"YES"]
        WKInterfaceController.openParentApplication(info) {
            (replyDictionary, error) -> Void in
            if replyDictionary != nil && replyDictionary["PlayPauseTrack"] as! String == "YES" {
            } else {
                println("Could not get play/pause track!")
            }
        }
    }
}
