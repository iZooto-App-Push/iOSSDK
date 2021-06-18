//
//  AppDelegate.swift
//  MoMagiciOSProject
//
//  Created by Amit on 14/06/21.
//

import UIKit
import MomagiciOSSDK
@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, NotificationOpenDelegate, NotificationReceiveDelegate, LandingURLDelegate{
    func onNotificationOpen(action: Dictionary<String, Any>) {
        print("DeepLinkData",action)
        
    }
    
    func onNotificationReceived(payload: Payload) {
        
    }
    
    func onHandleLandingURL(url: String) {
        print("URL",url)
        
    }
    
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
                let momagicInitSettings = ["auto_prompt": true,"nativeWebview": false, "provisionalAuthorization":false]
        DispatchQueue.main.async {
            DATB.initialisation(momagic_app_id: "05e3574fafb1c149ca6e89ac4010e22fd0402215", application: application, MoMagicInitSettings:momagicInitSettings)
        }
        
       
        DATB.registerForPushNotifications()
           UNUserNotificationCenter.current().delegate = self
           DATB.notificationOpenDelegate = self
           DATB.notificationReceivedDelegate = self
           DATB.landingURLDelegate = self
        return true
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
       DATB.getToken(deviceToken: deviceToken)
     }
     
     @available(iOS 10.0, *)
     func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)     {
        DATB.handleForeGroundNotification(notification: notification, displayNotification: "None")
       completionHandler([.badge, .alert, .sound])
     }
     
     // @available(iOS 10.0, *)
     func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
       DATB.notificationHandler(response: response) //iZooto.notificationHandler
       completionHandler()
     }

  


}

