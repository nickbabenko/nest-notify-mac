//
//  MessageListener.swift
//  Nest Notify
//
//  Created by Nick Babenko on 16/10/2020.
//  Copyright © 2020 Nick Babenko. All rights reserved.
//

import Foundation
import CoreFoundation
import CocoaMQTT
import Alamofire
import Cocoa

let ChimeTopic = "google-nest/doorbell/chime"

class MessageListener: NSObject {
    
    let mqtt: CocoaMQTT
    
    override init() {
        mqtt = CocoaMQTT(clientID: "NestNotify-1.0", host: "192.168.0.59", port: 1883)

        super.init()
        
        mqtt.keepAlive = 60
        mqtt.autoReconnect = true
        mqtt.didReceiveTrust = { _, trust, completion in
            completion(true)
        }
        mqtt.didConnectAck = { _, ack in
            if ack == .accept {
                self.mqtt.subscribe(ChimeTopic)
            }
        }
        mqtt.didChangeState = { _, state in
            print("new state: \(state)")
        }
        mqtt.didDisconnect = { _, error in
            print("did disconnect \(error)")
            //mqtt.connect(timeout: 60)
        }
        mqtt.didReceiveMessage = { _, message, id in
            print("did receive message \(message.topic)")
            if (message.topic == ChimeTopic) {
                do {
                    if let body = try JSONSerialization.jsonObject(with: Data(message.payload), options: []) as? [String: Any] {
                        print(body)
                        if let results = body["results"] as? [String: String] {
                            if let url = results["url"],
                               let token = results["token"] {
                                print("\(url) \(token)")
                                AF.download(url, headers: [ "Authorization": "Basic \(token)"])
                                    .responseData { response in
                                        if response.response?.statusCode == 200, let data = response.value {
                                            if let image = NSImage(data: data) {
                                                let notification = NotificationSender()
                                                notification.send(image: image)
                                            }
                                        } else {
                                            print("Invalid image response \(response.response?.statusCode)")
                                        }
                                    }
                            }
                        }
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
            }
        }
        
        _ = mqtt.connect()
    }
}

