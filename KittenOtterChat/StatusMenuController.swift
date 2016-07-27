//
//  StatusMenuController.swift
//  KittenOtterChat
//
//  Created by Freddie Meyer on 7/27/16.
//  Copyright © 2016 Freddie Meyer. All rights reserved.
//

import AVFoundation
import Cocoa
import SocketIOClientSwift

class StatusMenuController: NSObject, PreferencesWindowDelegate {
    @IBOutlet weak var statusMenu: NSMenu!
    var preferencesWindow: PreferencesWindow?

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)

    var socket : SocketIOClient?

    // defaults
    var defaults : NSUserDefaults?
    var animal : String?

    override func awakeFromNib() {
        let icon = NSImage(named: "statusIcon")
        //icon?.template = true // best for dark mode
        statusItem.image = icon
        statusItem.menu = statusMenu
        preferencesWindow = PreferencesWindow()

        initDefaults()

        var audioPlayer = AVAudioPlayer()
        
        socket = SocketIOClient(socketURL: NSURL(string: "https://kittenotterchat.herokuapp.com")!, options: [.Log(true), .ForcePolling(true)])
        
        socket?.on("connect") {data, ack in
            print("socket connected")
        }
        
        socket?.on("chat_msg_receive") {data, ack in
            let dataStrings = data[0] as? [String]
            let animal = dataStrings?[0]
            let sound = dataStrings?[1]
            if (animal == nil || sound == nil) {
                print("animal or sound is nil")
                return
            }
            let path = animal! + "_" + sound!
            let fileURLWithPath : String? = NSBundle.mainBundle().pathForResource(path, ofType: "m4a")
            if (fileURLWithPath == nil) {
                return
            }
            let soundURL = NSURL(fileURLWithPath: fileURLWithPath!)
            do {
                try audioPlayer = AVAudioPlayer(contentsOfURL: soundURL)
            } catch let error as NSError {
                print(error)
            }
            audioPlayer.play()
            self.showNotification(animal!, sound: sound!)
        }
        
        socket?.connect()
    }
    
    func initDefaults() {
        defaults = NSUserDefaults.standardUserDefaults()
        animal = defaults?.stringForKey("animal")
        if (animal == nil) {
            animal = "otter"
        }
    }
    
    func preferencesDidUpdate() {
        animal = defaults?.stringForKey("animal")
        if (animal == nil) {
            animal = "otter"
        }
    }
    
    func showNotification(animal : String, sound : String) {
        var modifierWord : String
        switch sound {
        case "attention":
            modifierWord = "demands"
        case "hungry", "reporting_for_duty", "sad", "talkative":
            modifierWord = "is"
        default:
            modifierWord = "says"
        }
        let soundPrint = sound.stringByReplacingOccurrencesOfString("_", withString: " ")
        let notification = NSUserNotification()
        notification.title = soundPrint.capitalizedString
        notification.informativeText = "\(animal.capitalizedString) \(modifierWord) \(soundPrint)!"
        notification.setValue(NSImage(named: "otter"), forKey: "_identityImage")
        notification.setValue(false, forKey: "_identityImageHasBorder")
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
    }

    @IBAction func affirmativeClicked(sender: AnyObject) {
        socket?.emit("chat_msg_send", ["otter", "affirmative"])
    }

    @IBAction func attentionClicked(sender: AnyObject) {
        socket?.emit("chat_msg_send", ["otter", "attention"])
    }

    @IBAction func humphClicked(sender: AnyObject) {
        socket?.emit("chat_msg_send", ["otter", "humph"])
    }

    @IBAction func hungryClicked(sender: AnyObject) {
        socket?.emit("chat_msg_send", ["otter", "hungry"])
    }

    @IBAction func reportingForDutyClicked(sender: AnyObject) {
        socket?.emit("chat_msg_send", ["otter", "reporting_for_duty"])
    }

    @IBAction func sadClicked(sender: AnyObject) {
        socket?.emit("chat_msg_send", ["otter", "sad"])
    }

    @IBAction func talkativeClicked(sender: AnyObject) {
        socket?.emit("chat_msg_send", ["otter", "talkative"])
    }

    @IBAction func preferencesClicked(sender: AnyObject) {
        preferencesWindow?.showWindow(nil)
    }

    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
}
