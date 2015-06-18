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
        self.lblMessage.setHidden(false)
        
//        let info = ["Active":"YES"]
//        WKInterfaceController.openParentApplication(info) {
//            (replyDictionary, error) -> Void in
//            
//            // Use response from parent app
//            if replyDictionary["Active"] as! String == "YES" {
//                self.lblMessage.setHidden(true)
//            }
//        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
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
        
        // Check for new track art changes
        self.wormhole.listenForMessageWithIdentifier("TrackImageURL") {
            (messageObject) -> Void in
            if let url: NSURL = messageObject as? NSURL {
                dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.value), 0)) {
                    var replace: String = url.absoluteString!.stringByReplacingOccurrencesOfString("-t300x300", withString: "-large", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    var actualURL: NSURL = NSURL(string: replace)!
                    var data: NSData = NSData(contentsOfURL: actualURL)!
                    self.image = UIImage(data: data)!
                    dispatch_async(dispatch_get_main_queue()) {
                        self.imgTrackArt.setImage(self.image)
                        self.imgTrackArt.setHidden(false)
                    }
                }
            }
        }
        
        // Check for track title change
        self.wormhole.listenForMessageWithIdentifier("TrackTitle") {
            (messageObject) -> Void in
            if let title: String = messageObject as? String {
                self.lblTrackTitle.setText(title)
                self.lblTrackTitle.setHidden(false)
                self.grpButtons.setHidden(false)
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
        //self.wormhole.passMessageObject("YES", identifier: "PlayNext")
    }
    
    @IBAction func doPlayPause() {
        //self.wormhole.passMessageObject("YES", identifier: "ChangePlayStatus")
    }
}
