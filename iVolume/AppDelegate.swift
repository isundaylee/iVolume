//
//  AppDelegate.swift
//  iVolume
//
//  Created by Jiahao Li on 10/13/17.
//  Copyright © 2017 Jiahao Li. All rights reserved.
//

import Cocoa
import CocoaMQTT

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var menu: NSMenu!
    @IBOutlet weak var toggleMenuItem: NSMenuItem!
    
    private var statusItem: NSStatusItem?
    
    private var mqtt: CocoaMQTT!
    
    fileprivate var isActive = true {
        didSet {
            self.toggleMenuItem.title = (self.isActive ? "Disable" : "Enable")
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        self.statusItem = NSStatusBar.system().statusItem(withLength: -1)
        
        self.statusItem!.title = "iVolume"
        self.statusItem!.length = 70
        self.statusItem!.highlightMode = true
        self.statusItem!.menu = self.menu
        
        let clientID = "iVolume-" + String(ProcessInfo().processIdentifier)
        self.mqtt = CocoaMQTT(clientID: clientID, host: "cloud.ljh.me", port: 1883)
        self.mqtt.delegate = self
        
        if (!self.mqtt.connect()) {
            self.isActive = false
            print("Failed to connect to MQTT server")
        }
    }
    
    @IBAction
    func onQuit(sender: NSMenuItem) {
        NSApplication.shared().terminate(sender);
    }
    
    @IBAction
    func onToggle(sender: NSMenuItem) {
        self.isActive = !self.isActive
    }
    
}

extension AppDelegate: CocoaMQTTDelegate {
    func mqttDidPing(_ mqtt: CocoaMQTT) {
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
    }

    func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        mqtt.subscribe("home/ivolume/value")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
    }

    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        let value = Float(message.string!)
        
        if (!self.isActive) {
            return
        }
        
        if value == nil {
            print("Invalid value reading received: " + message.string!)
            return
        }
        
        print("Changed volume to: \(value!)")
        NSSound.setSystemVolume(value!)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
    }
}
