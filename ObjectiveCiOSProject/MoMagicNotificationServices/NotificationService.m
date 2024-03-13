//
//  NotificationService.m
//  MoMagicNotificationServices
//
//  Created by Amit on 14/06/21.
//

#import "NotificationService.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;
@property (nonatomic, strong) UNNotificationRequest *receivedRequest;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.receivedRequest = request;
    self.bestAttemptContent = [request.content mutableCopy];
    if (self.bestAttemptContent != nil)
    {
        [DATB didReceiveNotificationExtensionRequestWithBundleName:@"com.momagic.ObjectiveCiOSProject" soundName:@"" isBadge:true request:self.receivedRequest bestAttemptContent:self.bestAttemptContent contentHandler:self.contentHandler];
    }
}
- (void)serviceExtensionTimeWillExpire {
   
    [DATB didReceiveNotificationExtensionRequestWithBundleName:@"com.momagic.ObjectiveCiOSProject" soundName:@"" isBadge:true request:self.receivedRequest bestAttemptContent:self.bestAttemptContent contentHandler:self.contentHandler];
}

@end
