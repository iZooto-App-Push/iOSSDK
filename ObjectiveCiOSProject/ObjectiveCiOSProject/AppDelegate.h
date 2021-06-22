//
//  AppDelegate.h
//  ObjectiveCiOSProject
//
//  Created by Amit on 14/06/21.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
@import MomagiciOSSDK;

@interface AppDelegate : UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate,LandingURLDelegate,NotificationOpenDelegate,NotificationReceiveDelegate>
@property (strong, nonatomic) UIWindow * window;
@property(nonatomic, weak)id <LandingURLDelegate> landingURLDelegate;
@property(nonatomic, weak)id <NotificationOpenDelegate> notificationOpenDelegate;
@property(nonatomic, weak)id <NotificationReceiveDelegate> notificationReceivedDelegate;
@end

