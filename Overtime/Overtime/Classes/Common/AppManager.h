//
//  AppManager.h
//  ExileTribeMile
//
//  Created by Xu Shawn on 2/2/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <AFNetworking/AFNetworking.h>
#import "Area.h"
#import "Master.h"
#import "Era.h"
#import "Time.h"
#import "Day.h"
#import "Task.h"

extern NSString * const MSGWorkStart;
extern NSString * const MSGWorkEnd;
extern NSString * const MSGOTStart;
extern NSString * const MSGOTEnd;
extern NSString * const MSGChargeReach;
extern NSString * const MSGLastConfirm;
extern NSString * const MSGMemoryWarning;
extern NSString * const MSGAppTerminate;

@interface AppManager : NSObject

@property (nonatomic, strong) NSMutableArray *areaArray;
@property (nonatomic, assign) double testLatitude;
@property (nonatomic, assign) double testLongitude;
@property (nonatomic, assign) double horizontalAccuracy;

@property (nonatomic, assign) ThemeType themeType;
@property (nonatomic, assign) OvertimeType overtimeType;

@property (nonatomic, strong) NSArray *holidayArray;
@property (nonatomic, strong) Era *era;
@property (nonatomic, strong) Day *currentDay;
@property (nonatomic, strong) Time *currentTime;
@property (nonatomic, strong) NSMutableDictionary *masterDic;
@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, strong) NSDateComponents *currentDateComponents;

@property (nonatomic, assign) BOOL settingNeedReload;
@property (nonatomic, assign) BOOL locationEdited;
@property (nonatomic, assign) NSInteger heldDays;
@property (nonatomic, assign) BOOL oldUser;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, strong) NSMutableArray *taskArray;
@property (nonatomic, strong) NSMutableArray *finishedTaskArray;
@property (nonatomic, strong) NSMutableArray *unshownTaskArray;

+ (AppManager *)sharedInstance;
+ (AFHTTPRequestOperationManager *)requestOperationManager;
+ (void)requestDidFailed:(id)error;
+ (void)requestDidFailedWithResult:(id)result;

- (void)updateToCurrentDate;
+ (NSString *)currencyFormat:(double)value;
+ (NSString *)weekTextAtIndex:(NSInteger)index;

+ (void)addLocalNotification:(NSString *)body;
+ (NSString *)pushMessageForKey:(NSString *)key;
+ (NSString *)homeMessageForKey:(NSString *)key;
+ (NSString *)homeMessageForHour:(double)hour;
+ (void)addLastConfirmNotification;
+ (void)cancelLastConfirmNotification;
+ (NSString *)hoursToHHmm:(double)totalHours;
+ (NSInteger)calculateHourMoney:(NSString *)money;
+ (NSString *)avatarNameBySex:(Gender)sex levelType:(LevelType)levelType;

- (void)addHeldDays:(NSInteger)days;
- (void)loadCurrentTime;
- (void)loadDefaultData;
- (void)initializeDefaultData;
- (BOOL)isWorking;
- (void)checkAutoWorkOff;
- (void)checkAutoWorkOffWithAutoWorkOn:(BOOL)autoOnFlag;
- (void)reloadEraData;
- (NSString *)shareTextWithURL:(NSString *)urlString;

- (void)startTimeForDate:(NSDate *)date withAreaID:(NSString *)areaID;
- (void)startTimeForDate:(NSDate *)date withAreaID:(NSString *)areaID autoFlag:(BOOL)autoFlag;
- (void)endTimeForDate:(NSDate *)date;
- (void)endTimeForDate:(NSDate *)date withNotificationFlag:(BOOL)notificationFlag;
- (void)endTime:(Time *)time forDate:(NSDate *)date withNotificationFlag:(BOOL)notificationFlag;
+ (BOOL)isNewDayWithStartDateString:(NSString *)startDateString;

- (void)requestUUID;
- (void)requestTopLikeNum;
- (void)requestUserInfo;

- (BOOL)taskValidFromTag:(NSString *)taskTag;
- (Task *)taskFromTag:(NSString *)tag;

@end
