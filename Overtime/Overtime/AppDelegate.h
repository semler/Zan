//
//  AppDelegate.h
//  Overtime
//
//  Created by Xu Shawn on 2/14/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Pushwoosh/PushNotificationManager.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate, PushNotificationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) UIAlertView *alertView;
@property (strong, nonatomic) UIImageView *splashImageView;

- (void)startApplication:(NSNumber *)restoreFlag;

@end
