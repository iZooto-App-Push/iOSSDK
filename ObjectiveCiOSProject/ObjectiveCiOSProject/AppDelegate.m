//
//  AppDelegate.m
//  ObjectiveCiOSProject
//
//  Created by Amit on 14/06/21.
//

#import "AppDelegate.h"
@import MomagiciOSSDK;
@import UserNotifications;
@interface AppDelegate ()
@end
@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    dispatch_async(dispatch_get_main_queue(), ^{
//define settings
        NSMutableDictionary *momagicInitSetting = [[NSMutableDictionary alloc]init];
        [momagicInitSetting setObject:@YES forKey:@"auto_prompt"];
        [momagicInitSetting setObject:@NO forKey:@"nativeWebview"];
        [momagicInitSetting setObject:@NO forKey:@"provisionalAuthorization"];
    // initalise the MoMagic SDK
    [DATB initialisationWithMomagic_app_id: @"de1bdb0a32007eed602064192bb129b7e5e3cc32" application:application MoMagicInitSettings:momagicInitSetting];
       
        
    });
  
    DATB.notificationReceivedDelegate = self;
    DATB.landingURLDelegate = self;
    DATB.notificationOpenDelegate = self;
    return YES;
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //Get Token from When enbale prompt allow
    [DATB getTokenWithDeviceToken:deviceToken];
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSLog(@"Received");
    [DATB handleForeGroundNotificationWithNotification:notification displayNotification:@"NONE"];
    completionHandler(UNNotificationPresentationOptionAlert);
}
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler
{
    [DATB notificationHandlerWithResponse:response];
    completionHandler();
}



- (void)onHandleLandingURLWithUrl:(NSString * _Nonnull)url {
    
}

- (void)onNotificationOpenWithAction:(NSDictionary<NSString *,id> * _Nonnull)action {
    NSLog(@"NSString = %@", action);

}


- (void)onNotificationReceivedWithPayload:(Payload * _Nonnull)payload {
    NSLog(@"NSString = %@",payload);

}

@end

