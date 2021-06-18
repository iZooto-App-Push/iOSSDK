//
//  NotificationService.swift
//  MoMagicExtesnionServices
//
//  Created by Amit on 15/06/21.
//

import UserNotifications
import MomagiciOSSDK

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
      var bestAttemptContent: UNMutableNotificationContent?
      var receivedRequest: UNNotificationRequest!
      override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        print("Response",request)
          self.receivedRequest = request;
          self.contentHandler = contentHandler
          bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
          if let bestAttemptContent = bestAttemptContent {
          DATB.didReceiveNotificationExtensionRequest(request: receivedRequest, bestAttemptContent: bestAttemptContent,contentHandler: contentHandler)
           
        }
        }
        override func serviceExtensionTimeWillExpire() {
          if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
          }
        }

}
