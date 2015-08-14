//
//  AppDelegate.m
//  Overtime
//
//  Created by Xu Shawn on 2/14/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "LocationViewController.h"
#import "DBUtils.h"
#import "Apsalar.h"
#import "iCloudUtils.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    if (!IOS7_OR_LATER) {
        [application setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    }
    
    // Initial google analytics tracker
    [self initGAITracker];

    //-----------PUSHWOOSH PART-----------
    // set custom delegate for push handling, in our case - view controller
    PushNotificationManager * pushManager = [PushNotificationManager pushManager];
    pushManager.delegate = self;
    
    // handling push on app start
    [[PushNotificationManager pushManager] handlePushReceived:launchOptions];
    
    // make sure we count app open in Pushwoosh stats
    [[PushNotificationManager pushManager] sendAppOpen];
    
    // register for push notifications!
    [[PushNotificationManager pushManager] registerForPushNotifications];
    
    // clear notification
    [PushNotificationManager clearNotificationCenter];
    
    // Clear badge number
    [application setApplicationIconBadgeNumber:0];
    
    [Apsalar startSession:APSALAR_APP_KEY withKey:APSALAR_APP_SECRET andLaunchOptions:launchOptions];
    if (launchOptions) {
        [Apsalar event:@"Pushからの起動"];
    }
    
    // Splash
    UIImage *splashImage = nil;
    if (IS_RETINA4) {
        splashImage = [UIImage imageNamed:@"LaunchImage-568h"];
    } else {
        splashImage = [UIImage imageNamed:@"LaunchImage"];
    }
    self.splashImageView = [[UIImageView alloc] initWithFrame:CGRectFromImage(splashImage)];
    [self.splashImageView setImage:splashImage];
    [self.window addSubview:self.splashImageView];
    
    // iCloud
    if ([iCloudUtils needsDownloadiCloudFile]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"iCloudに過去の打刻データがありました。データを復元してインストールしますか？（おすすめ）"
                                                           delegate:self
                                                  cancelButtonTitle:@"キャンセル"
                                                  otherButtonTitles:@"OK", nil];
        [alertView show];
    } else {
        // Start application
        [self startApplication:@(NO)];
    }
    
    [self.window makeKeyAndVisible];
    [self.window bringSubviewToFront:self.splashImageView];
    
    [LogUtils saveRunningLog:[NSString stringWithFormat:@"アプリ起動：%@\n", [[NSDate date] localStringWithFormat:DB_DATE_YMDHMS]]];
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [iCloudUtils downloadFileFromiCloud];
    } else {
        // Start application
        [self startApplication:@(NO)];
    }
}

- (void)startApplication:(NSNumber *)restoreFlag
{
    // Setup database
    [[DBUtils sharedDBUtils] setupDB:DB_FILE_NAME];
    // Open database
    [[DBUtils sharedDBUtils] openDB];
    // Handle old user
    [DBUtils handleOldUser];
    // Update Table
    BOOL ret = [DBUtils updateTable];
    // Database broken
    if (!ret) {
        // Delete
        [GFUtils deleteGeoFenceConfig:[Area allArea]];
        // Resetup database
        [[DBUtils sharedDBUtils] resetupDB:DB_FILE_NAME];
        // Open database
        [[DBUtils sharedDBUtils] openDB];
        // Handle old user
        [DBUtils handleOldUser];
        // Update Table
        [DBUtils updateTable];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:DefaultDataLoaded];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // Load default data
    [[AppManager sharedInstance] loadDefaultData];
    // Database area
    NSMutableArray *areaArray = [[AppManager sharedInstance] areaArray];
    
    BOOL needSetting = YES;

    if ([restoreFlag boolValue] && [MASTER(MSTKeyUUID) length] > 0) {
        NSLog(@"Restore data from icloud");
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DefaultDataLoaded];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        for (Area *area in areaArray) {
            [area setSend_flag:@"0"];
            [area.notificationIn setSend_flag:@"0"];
            [area.notificationOut setSend_flag:@"0"];
            
            [area.notificationIn save];
            [area.notificationOut save];
            [area save];
        }
        
        NSString *currentTimePid = MASTER(MSTKeyCurrentTimeID);
        if (currentTimePid.length > 0) {
            Time *time = [Time timeWithPid:currentTimePid];
            [[AppManager sharedInstance] endTime:time forDate:[NSDate date] withNotificationFlag:NO];
        }

        needSetting = NO;
    } else {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:DefaultDataLoaded] || [MASTER(MSTKeyUUID) length] == 0) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DefaultDataLoaded];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[AppManager sharedInstance] initializeDefaultData];
        }
        
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        for (NSInteger i = 0; i < areaArray.count; i++) {
            Area *area = [areaArray objectAtIndex:i];
            if (area.latitude.length == 0 || area.longitude.length == 0 || area.name.length == 0 || area.radius.length == 0) {
                [area physicalDelete];
                [indexSet addIndex:i];
            }
        }
        [areaArray removeObjectsAtIndexes:indexSet];
        
        for (Area *area in areaArray) {
            if ([area.send_flag isEqualToString:@"1"] &&
                [area.notificationIn.send_flag isEqualToString:@"1"] &&
                [area.notificationOut.send_flag isEqualToString:@"1"]) {
                needSetting = NO;
                break;
            }
        }
    }
    
    // Current working time
    [[AppManager sharedInstance] loadCurrentTime];
    // Check auto workoff
    [[AppManager sharedInstance] checkAutoWorkOffWithAutoWorkOn:YES];
    
    if (DEBUG_MODE) {
        // To do
//        [Time addTempTimes];
    }

    if (needSetting) {
//        BOOL showAlert = NO;
//        for (Area *area in areaArray) {
//            if ([area.name length] > 0) {
//                showAlert = YES;
//                break;
//            }
//        }
//        if (showAlert) {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"もうちょっとチュートリアルを見ておこう。あと少し！" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//            [alertView show];
//        }
        
        // Log tracker
        NSDictionary *parameters = [[GAIDictionaryBuilder createEventWithCategory:@"チュートリアル"
                                                                           action:@"開始"
                                                                            label:nil
                                                                            value:nil] build];
        [[[GAI sharedInstance] defaultTracker] send:parameters];
        
        Area *area = [areaArray lastObject];
        if (!area) {
            area = [Area area];
        }
        LocationViewController *locationViewController = [[LocationViewController alloc] initWithSettingType:SettingTypeInit areaModal:area];
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:locationViewController];
    } else {
        MainViewController *mainViewController = [[MainViewController alloc] init];
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    }
    [self.navigationController setNavigationBarHidden:YES];
    
    // Regist UUID
    [self userLogin];
    
    [self.window setRootViewController:self.navigationController];
    [self.window bringSubviewToFront:self.splashImageView];
    
    CGFloat delay = 1.0;
    if ([restoreFlag boolValue]) {
        delay = 0;
    }
    
    [UIView animateWithDuration:0.3 delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.splashImageView setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self.splashImageView removeFromSuperview];
    }];
}

- (void)userLogin
{
    if (![MASTER(MSTKeyUserLogined) isEqualToString:@"1"]) {
        [[AppManager sharedInstance] requestUUID];
    } else {
        DLog(@"UUID: %@", MASTER(MSTKeyUUID));
    }
}

- (void)initGAITracker
{
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelNone];
    
    // Initialize tracker.
    [[GAI sharedInstance] trackerWithTrackingId:GAITRACKER_KEY];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [LogUtils saveRunningLog:[NSString stringWithFormat:@"アプリ→バックグラウンド：%@\n", [[NSDate date] localStringWithFormat:DB_DATE_YMDHMS]]];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [LogUtils saveRunningLog:[NSString stringWithFormat:@"バックグラウンド→アプリ：%@\n", [[NSDate date] localStringWithFormat:DB_DATE_YMDHMS]]];
    
    Day *currentDay = [[AppManager sharedInstance] currentDay];
    if (![[AppManager sharedInstance] isWorking] && currentDay && [AppManager isNewDayWithStartDateString:currentDay.start_date]) {
        [[AppManager sharedInstance] setCurrentDay:nil];
        [[AppManager sharedInstance] setCurrentTime:nil];
        [[AppManager sharedInstance] setOvertimeType:OvertimeTypeNone];
        // Set to latest time
        [[AppManager sharedInstance] updateToCurrentDate];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ReloadDataNotification object:nil];
    } else {
        // Set to latest time
        [[AppManager sharedInstance] updateToCurrentDate];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [Apsalar startSession:APSALAR_APP_KEY withKey:APSALAR_APP_SECRET];
    
    if (![MASTER(MSTKeyUserLogined) isEqualToString:@"1"] && [MASTER(MSTKeyUUID) length] > 0) {
        // Relogin
        [self userLogin];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setLabel" object:nil userInfo:nil];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [Apsalar startSession:APSALAR_APP_KEY withKey:APSALAR_APP_SECRET andURL:url];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSString *body = [AppManager pushMessageForKey:MSGAppTerminate];
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    [notification setAlertBody:body];
    [notification setFireDate:[NSDate date]];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    [LogUtils saveRunningLog:[NSString stringWithFormat:@"アプリのプロセスの削除：%@\n", [[NSDate date] localStringWithFormat:DB_DATE_YMDHMS]]];
}

// system push notification registration success callback, delegate to pushManager
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Push Token：%@", deviceToken);
    [[PushNotificationManager pushManager] handlePushRegistration:deviceToken];
    
    if ([MASTER(MSTKeyUserLogined) isEqualToString:@"1"]) {
        AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
        NSDictionary *parameters = @{@"uuid": MASTER(MSTKeyUUID), @"device_token": [deviceToken description]};
        [manager POST:@"/user/deviceToken" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject[@"error"] integerValue] == ErrorNone) {
                
            } else {
                NSLog(@"Device Token Failed: %@", responseObject);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
}

// system push notification registration error callback, delegate to pushManager
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[PushNotificationManager pushManager] handlePushRegistrationFailure:error];
}

// system push notifications callback, delegate to pushManager
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[PushNotificationManager pushManager] handlePushReceived:userInfo];
}

- (void) onPushAccepted:(PushNotificationManager *)pushManager withNotification:(NSDictionary *)pushNotification {
    NSLog(@"Push notification received");
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (application.applicationState == UIApplicationStateActive) {
        if (self.alertView.visible) {
            [self.alertView dismissWithClickedButtonIndex:0 animated:NO];
        }
        self.alertView = [[UIAlertView alloc] initWithTitle:@""
                                                    message:notification.alertBody
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
        [self.alertView show];
    }
    
    DLog(@"%@", notification.alertBody);
}

@end
