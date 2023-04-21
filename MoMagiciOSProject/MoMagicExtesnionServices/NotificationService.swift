//
//  NotificationService.swift
//  MoMagicExtesnionServices
//
//  Created by Amit on 15/06/21.
//

import UserNotifications
import MomagiciOSSDK
import AVFoundation

class NotificationService: UNNotificationServiceExtension {
    var bombSoundEffect: AVAudioPlayer?

    var contentHandler: ((UNNotificationContent) -> Void)?
      var bestAttemptContent: UNMutableNotificationContent?
      var receivedRequest: UNNotificationRequest!
      override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
          self.receivedRequest = request;
          self.contentHandler = contentHandler
          bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
          if let bestAttemptContent = bestAttemptContent {
//              DATB.didReceiveNotificationExtensionRequest(bundleName:"" , soundName: "com.momagic.MoMagiciOSProject", request: "", bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
              
              DATB.didReceiveNotificationExtensionRequest(bundleName: "com.momagic.MoMagiciOSProject", soundName: "String", request: receivedRequest, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
         
          
           
        }
        }
        override func serviceExtensionTimeWillExpire() {
          if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
              DATB.didReceiveNotificationExtensionRequest(bundleName: "String", soundName: "String", request: receivedRequest, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
              
          }
        }

}
