//
//  PreferencesWindow.swift
//  KittenOtterChat
//
//  Created by Freddie Meyer on 7/27/16.
//  Copyright © 2016 Freddie Meyer. All rights reserved.
//

import Cocoa

protocol PreferencesWindowDelegate {
    func preferencesDidUpdate()
}

class PreferencesWindow: NSWindowController {
    @IBOutlet weak var animalInput: NSPopUpButton!
    
    var delegate: PreferencesWindowDelegate?
    
    override var windowNibName : String! {
        return "PreferencesWindow"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        self.window?.title = "Preferences"
        NSApp.activateIgnoringOtherApps(true)
        let defaults = NSUserDefaults.standardUserDefaults()
        if let animalVal = defaults.stringForKey("animal") {
            animalInput.stringValue = animalVal
        }
    }

    @IBAction func saveClicked(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(animalInput.stringValue, forKey: "animal")
        defaults.synchronize()
        delegate?.preferencesDidUpdate()
        self.window?.close()
    }
}
