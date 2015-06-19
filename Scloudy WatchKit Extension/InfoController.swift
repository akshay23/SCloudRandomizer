//
//  InfoController.swift
//  Scloudy
//
//  Created by Akshay Bharath on 6/19/15.
//  Copyright (c) 2015 Akshay Bharath. All rights reserved.
//

import WatchKit
import Foundation


class InfoController: WKInterfaceController {

    @IBOutlet var lblDescription: WKInterfaceLabel!
    @IBOutlet var lblTrackArtist: WKInterfaceLabel!
    @IBOutlet var lblTrackTitle: WKInterfaceLabel!
    
    var wormhole: MMWormhole!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        self.wormhole = MMWormhole(applicationGroupIdentifier: "group.com.actionman.scloudy", optionalDirectory: "wormhole")

        // Check for track title change
        self.wormhole.listenForMessageWithIdentifier("TrackTitle") {
            (messageObject) -> Void in
            if let title: String = messageObject as? String {
                self.lblTrackTitle.setText(title)
            }
        }
        
        // Check for track artist change
        self.wormhole.listenForMessageWithIdentifier("TrackArtist") {
            (messageObject) -> Void in
            if let title: String = messageObject as? String {
                self.lblTrackArtist.setText(title)
            }
        }
        
        // Check for track title change
        self.wormhole.listenForMessageWithIdentifier("TrackDescription") {
            (messageObject) -> Void in
            if let title: String = messageObject as? String {
                self.lblDescription.setText(title)
            }
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        let refreshData = ["RefreshData": "YES"]
        WKInterfaceController.openParentApplication(refreshData) {
            (replyDictionary, error) -> Void in
            if ((error) != nil) {
                println("Could not refresh track data")
            }
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
