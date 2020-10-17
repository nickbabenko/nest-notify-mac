//
//  NotificationSender.swift
//  Nest Notify
//
//  Created by Nick Babenko on 16/10/2020.
//  Copyright © 2020 Nick Babenko. All rights reserved.
//

import Cocoa

class NotificationSender: NSObject {
    
    func send(image: NSImage) {
        let notification = NSUserNotification()
        notification.title = "Nest"
        notification.informativeText = "There is someone at the door"
        notification.contentImage = image
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }

}
