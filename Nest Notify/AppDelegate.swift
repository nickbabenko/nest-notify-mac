//
//  AppDelegate.swift
//  Nest Notify
//
//  Created by Nick Babenko on 16/10/2020.
//  Copyright © 2020 Nick Babenko. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    
    let messageListener = MessageListener()
    
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()
        
        // Create the popover
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 500)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover
        
        // Create the status item
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        
        if let button = self.statusBarItem.button {
            button.image = NSImage(named: "nest_logo")
            button.action = #selector(togglePopover(_:))
        }
        
        //scheduleTokenUpdate()
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
         if let button = self.statusBarItem.button {
              if self.popover.isShown {
                   self.popover.performClose(sender)
              } else {
                   self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
              }
         }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    private func scheduleTokenUpdate() {
        let activity = NSBackgroundActivityScheduler(identifier: "com.nickbabenko.Nest-Notify.tokenUpdate")
        activity.repeats = true
        activity.tolerance = 60 * 60
        activity.schedule() { (completion: @escaping NSBackgroundActivityScheduler.CompletionHandler) in
            TokenManager.shared.update {_ in
                completion(NSBackgroundActivityScheduler.Result.finished)
            }
        }
    }

}

