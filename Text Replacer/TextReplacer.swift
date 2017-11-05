//
//  AppDelegate.swift
//  Text Replacer
//
//  Created by Dennis Hernandez on 10/29/17.
//  Copyright © 2017 Dennis Hernandez. All rights reserved.
//


import Cocoa

enum ReplacerType : Int {
    case Both = 0, Strings, KeyCode
}
private var replace = ReplacerType.Strings
struct TRString : Codable {
    var key = "adn"
    var string = "and"
    init() {
        key = "yoru"
        string = "your"
    }
    init(newKey: String, newValue: String) {
        key = newKey
        string = newValue
    }
}
struct TRKeyCode : Codable {
    var key = 0
    var string = 1
    init() {
        key = 2
        string = 3
    }
    init(newKey: Int, newValue: Int) {
        key = newKey
        string = newValue
    }
}

private func acquirePrivileges() -> Bool {
    let accessEnabled = AXIsProcessTrustedWithOptions(
        [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary)
    if accessEnabled != true {
        print("Check System Preferences > Security + Privacy")
    }
    return accessEnabled == true
}

private var replacementStrings : [TRString] = [TRString(newKey: "definately",newValue: "definitely"), TRString(newKey: "recieve",newValue: "receive"),TRString()]
private var replacementKeyCodes : [TRKeyCode] = [TRKeyCode()]

private var oldString = ""
private var newString = ""



class TextReplacer: NSObject {
    
    private var timeInterval = 0.75

    override init() {
        super.init()
        setup()
    }
    
 init(type : ReplacerType, keyCodes : [TRKeyCode], strings : [TRString]) {
        super.init()
    replace = ReplacerType.Strings
        setup()
    }
    
    ///not sure if it's necessary
    func setup() {
        _ = acquirePrivileges()
        
        switch replace {
        case ReplacerType.Both:
            replaceKeyCode()
            replaceStrings()
        case ReplacerType.KeyCode:
            replaceKeyCode()
        case ReplacerType.Strings:
            replaceStrings()
        }
    }
    
    //////////Replaces Keycode(Int) for Keycode
    ////////////Uses Accesibility API - doesn't work in chrome
    func replaceKeyCode() {
        ////
        checkForKeyCodeReplacement()
    }
    
    func checkForKeyCodeReplacement(){
        func myCGEventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
            
            if [.keyDown , .keyUp].contains(type) {
                var keyCode = event.getIntegerValueField(.keyboardEventKeycode)
                print(keyCode)
                if keyCode == 0 {
                    keyCode = 6
                } else if keyCode == 6 {
                    keyCode = 0
                }
                event.setIntegerValueField(.keyboardEventKeycode, value: keyCode)
            }
            return Unmanaged.passRetained(event)
        }
        
        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)
        guard let eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                               place: .headInsertEventTap,
                                               options: .defaultTap,
                                               eventsOfInterest: CGEventMask(eventMask),
                                               callback: myCGEventCallback,
                                               userInfo: nil) else {
                                                print("failed to create event tap")
                                                exit(1)
        }
        
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        CFRunLoopRun()
    }
    
    //////////Replaces String for String
    ////////////Uses Accesibility API - doesn't work in chrome
    func replaceStrings() {
        ////
        let textReplacer1 = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(checkForTextReplacement), userInfo: nil, repeats: true)
        textReplacer1.fire()
    }
    @objc func checkForTextReplacement() {
        
        ///
        let systemWideElement: AXUIElement = AXUIElementCreateSystemWide()
        let element: AXUIElement? = getElementValue(element: systemWideElement, attribute: kAXFocusedUIElementAttribute)///grabs currently focused element
        if element == nil {return}
        if let elementText : AXValue = getElementValue(element: element!, attribute: kAXValueAttribute) {
            ///get the string, check to see if this has already been search, replaces
            newString = elementText as! String ///sometimes throw an issue with numbers
            
            ///future - if does not have string return
            if oldString == newString {return}  ///prevents continuous replacing
            for (_,replacement) in replacementStrings.enumerated() {
                newString = replaceString(searchKey: replacement.key, replacementKey: replacement.string, returnKey: newString)
            }
            
            ///replaces the value in element
            ///future - save selection/cursor state
            let error = AXUIElementSetAttributeValue(element!, kAXValueAttribute as CFString, newString as CFString)
            if error == AXError.success{oldString = newString}  ///prevents continuous replacing
            _ = AXUIElementPerformAction(element!, kAXConfirmAction as CFString)
            
        }
    }
    
    ///helper function, this is what actually replaces strings in a string
    func replaceString(searchKey: String, replacementKey: String, returnKey: String) -> String {
        return returnKey.replacingOccurrences(of: searchKey, with: replacementKey)
        
    }
    
    ///
    func hasString(searchString: String, returnKey: String) -> Bool {
        return returnKey.contains(searchString)
    }
    
}

///helper function, cleaner way to grab an elements value
private func getElementValue<T>(element: AXUIElement, attribute: String) -> T? {
    var atributePointer: AnyObject?
    if AXUIElementCopyAttributeValue(element, attribute as CFString, &atributePointer) != AXError.success {
        return nil
    }
    return atributePointer.map {
        $0 as! T
    }
}


