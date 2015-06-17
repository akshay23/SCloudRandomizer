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

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        let userInfo = ["Started":"Yes"];
        WKInterfaceController.openParentApplication(userInfo) {
            (replyInfo, error) -> Void in
            if let error = error {
                self.lblMessage.setHidden(false)
            } else {
                self.lblMessage.setHidden(true)
            }
        }
        
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
