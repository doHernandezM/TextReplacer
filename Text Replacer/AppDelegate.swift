//
//  AppDelegate.swift
//  Text Replacer
//
//  Created by Dennis Hernandez on 11/3/17.
//  Copyright © 2017 Dennis Hernandez. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let replacer = TextReplacer(type: ReplacerType.Strings, keyCodes: [], strings: [TRString()])
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

