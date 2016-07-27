//
//  StatusMenuController.swift
//  KittenOtterChat
//
//  Created by Freddie Meyer on 7/27/16.
//  Copyright © 2016 Freddie Meyer. All rights reserved.
//

import Cocoa
import SocketIOClientSwift

class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    override func awakeFromNib() {
        let icon = NSImage(named: "statusIcon")
        //icon?.template = true // best for dark mode
        statusItem.image = icon
        statusItem.menu = statusMenu
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
}
