//
//  AppDelegate.swift
//  Text Replacer
//
//  Created by Dennis Hernandez on 10/29/17.
//  Copyright © 2017 Dennis Hernandez. All rights reserved.
//


import Cocoa



func acquirePrivileges() -> Bool {
    
    let accessEnabled = AXIsProcessTrustedWithOptions(
        [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary)
    
    if accessEnabled != true {
        print("Check System Preferences > Security + Privacy")
    }
    return accessEnabled == true
}

struct Replacement : Codable {
    var key = "yoru"
    var string = "your"
    init() {
        key = "yoru"
        string = "your"
    }
    init(newKey: String, newValue: String) {
        key = newKey
        string = newValue
    }
}
var replacements : [Replacement] = [Replacement(newKey: "definately",newValue: "definitely"), Replacement(newKey: "recieve",newValue: "receive")]

var oldString = ""
var newString = ""



@NSApplicationMain class AppDelegate: NSObject, NSApplicationDelegate {
    
    ///not sure if it's necessary
    func applicationDidFinishLaunching(_ notification: Notification) {
        _ = acquirePrivileges()
        
        let textReplacer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(checkForTextReplacement), userInfo: nil, repeats: true)
        textReplacer.fire()
    }
    
    
    @objc func checkForTextReplacement() {
        //////////
        ////////////
        let systemWideElement: AXUIElement = AXUIElementCreateSystemWide()
        let element: AXUIElement? = getElementValue(element: systemWideElement, attribute: kAXFocusedUIElementAttribute)///grabs currently focused element
        
        if let elementText : AXValue = getElementValue(element: element!, attribute: kAXValueAttribute) {
            print(elementText, "\n\n---------------------------------------------")///this shows current element's value
            
            
            ///get the string, check to see if this has already been search, replaces
            newString = elementText as! String ///sometimes throw an issue with numbers
            ///future
            /* if does not have string return*/
            if oldString == newString {return}  ///prevents continuous replacing
            for (_,replacement) in replacements.enumerated() {
                newString = replaceString(searchKey: replacement.key, replacementKey: replacement.string, returnKey: newString)
            }
            
            ///replaces the value in element
            ///future
            ///save selection/cursor state
            let error = AXUIElementSetAttributeValue(element!, kAXValueAttribute as CFString, newString as CFString)
            if error == AXError.success{oldString = newString}  ///prevents continuous replacing
        }
    }
    
    
    ///helper function, this is what actually replaces strings in a string
    func replaceString(searchKey: String, replacementKey: String, returnKey: String) -> String {
        return returnKey.replacingOccurrences(of: searchKey, with: replacementKey)
        
    }
    
    ///future
    /*
    func hasString(searchString: String) -> Bool {
        return false
    }
    */
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
    
}

///helper function, cleaner way to grab an elements value
func getElementValue<T>(element: AXUIElement, attribute: String) -> T? {
    var atributePointer: AnyObject?
    if AXUIElementCopyAttributeValue(element, attribute as CFString, &atributePointer) != AXError.success {
        return nil
    }
    return atributePointer.map {
        $0 as! T
    }
}

