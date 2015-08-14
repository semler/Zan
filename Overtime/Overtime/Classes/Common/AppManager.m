//
//  AppManager.m
//  ExileTribeMile
//
//  Created by Xu Shawn on 2/2/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "AppManager.h"
#import "iCloudUtils.h"
#import <AdSupport/AdSupport.h>
#import "AchievementViewController.h"

NSString * const MSGWorkStart = @"MSGWorkStart";
NSString * const MSGWorkEnd = @"MSGWorkEnd";
NSString * const MSGOTStart = @"MSGOTStart";
NSString * const MSGOTEnd = @"MSGOTEnd";
NSString * const MSGChargeReach = @"MSGChargeReach";
NSString * const MSGLastConfirm = @"MSGLastConfirm";
NSString * const MSGMemoryWarning = @"MSGMemoryWarning";
NSString * const MSGAppTerminate = @"MSGAppTerminate";

@implementation AppManager

+ (AppManager *)sharedInstance
{
    static dispatch_once_t pred;
    static AppManager *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[AppManager alloc] init];
        [shared setup];
    });
    
    return shared;
}

- (void)setup
{
    [self updateToCurrentDate];
    
    self.themeType = ThemeTypeBlue;
    self.areaArray = [NSMutableArray array];
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Holiday" ofType:@"plist"]];
    self.holidayArray = [NSArray arrayWithContentsOfURL:url];
}

- (void)updateToCurrentDate
{
    self.currentDate = [NSDate date];
    self.currentDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:self.currentDate];
}

- (void)loadDefaultData
{
    // Master data
    [self setMasterDic:[Master allMaster]];
    // Area
    [self setAreaArray:[Area allArea]];
    // Task
    [self setFinishedTaskArray:[Task allTasks]];
    
    NSString *oldUser = self.masterDic[MSTKeyOldUser];
    if ([oldUser integerValue] == 1) {
        self.oldUser = YES;
    }
    if (self.oldUser) {
        self.heldDays = 0;
    } else {
        NSInteger days = [self.masterDic[MSTKeyHeldDays] integerValue];
        if (days <= 0) {
            self.heldDays = 0;
        } else {
            self.heldDays = days;
        }
    }
}

- (void)addHeldDays:(NSInteger)days
{
    [self setHeldDays:(self.heldDays + days)];
    [Master saveValue:[NSString stringWithFormat:@"%d", (int)self.heldDays] forKey:MSTKeyHeldDays];
}

- (void)loadCurrentTime
{
    NSString *currentTimePid = [self.masterDic objectForKey:MSTKeyCurrentTimeID];
    if (currentTimePid.length > 0) {
        Time *time = [Time timeWithPid:currentTimePid];
        
        if (time) {
            if (time.end_date.length == 0) {
                [self setCurrentTime:time];
                [self setOvertimeType:OvertimeTypeWorking];
            } else {
                [Master saveValue:@"" forKey:MSTKeyCurrentTimeID];
                [self setOvertimeType:OvertimeTypeNone];
            }
        } else {
            [Master saveValue:@"" forKey:MSTKeyCurrentTimeID];
            [self setOvertimeType:OvertimeTypeNone];
        }
        
    } else {
        [self setOvertimeType:OvertimeTypeNone];
    }
}

- (void)initializeDefaultData
{
    // Default data
    NSString *UUID = [[NSUUID UUID] UUIDString];
    [Master saveValue:UUID forKey:MSTKeyUUID];
    DLog(@"UUID: %@", OTUUID);
    
    [Master saveValue:@"1" forKey:MSTKeyInOutlv];
    [Master saveValue:@"1" forKey:MSTKeyInOutftim];
    [Master saveValue:@"1" forKey:MSTKeyInOutfnum];
    
    [Master saveValue:@"1" forKey:MSTKeyWorkOn];
    [Master saveValue:@"1" forKey:MSTKeyWorkOff];
    [Master saveValue:@"1" forKey:MSTKeyOvertimeOn];
    [Master saveValue:@"1" forKey:MSTKeyOvertimeOff];
    
    [Master saveValue:@"1" forKey:MSTKeyChargeReach];
    [Master saveValue:@"5" forKey:MSTKeyChargeAmount];
    [Master saveValue:@"5" forKey:MSTKeyNextChargeAmount];
    
    [Master saveValue:@"1" forKey:MSTKeyLastConfirm];
    [Master saveValue:@"10:00" forKey:MSTKeyConfirmTime];
    [Master saveValue:@"1,2,3,4,5,6,0" forKey:MSTKeyConfirmWeek];
    
    NSString *dateString = [[NSDate date] localStringWithFormat:DB_DATE_YMDHMS];
    NSString *valueString = [NSString stringWithFormat:@"ON %@", dateString];
    [self sendDefaultPushSwitchStatus:@"PUSH_出勤打刻時" value:valueString];
    [self sendDefaultPushSwitchStatus:@"PUSH_退勤打刻時" value:valueString];
    [self sendDefaultPushSwitchStatus:@"PUSH_残業開始時" value:valueString];
    [self sendDefaultPushSwitchStatus:@"PUSH_残業終了時" value:valueString];
    [self sendDefaultPushSwitchStatus:@"PUSH_残業代が貯まった時" value:valueString];
    [self sendDefaultPushSwitchStatus:@"PUSH_前日の打刻確認" value:valueString];
}

- (void)sendDefaultPushSwitchStatus:(NSString *)title value:(NSString *)value
{
    // Log tracker
    NSDictionary *parameters = [[GAIDictionaryBuilder createEventWithCategory:OTUUID
                                                                       action:title
                                                                        label:value
                                                                        value:nil] build];
    [[[GAI sharedInstance] defaultTracker] send:parameters];
}

- (void)checkAutoWorkOff
{
    [self checkAutoWorkOffWithAutoWorkOn:NO];
}

+ (BOOL)isNewDayWithStartDateString:(NSString *)startDateString
{
    BOOL result = NO;
    
    if (startDateString.length > 0) {
        NSDate *startDate = [startDateString localDateWithFormat:DB_DATE_YMDHMS];
        NSDate *nowDate = [NSDate date];
        NSDateComponents *startDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:startDate];
        NSDateComponents *nowDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:nowDate];
        
        if (nowDateComponents.hour >= 5 && nowDateComponents.day == startDateComponents.day && startDateComponents.hour >= 0 && startDateComponents.hour < 5) {
            result = YES;
        } else if (nowDateComponents.day != startDateComponents.day && nowDateComponents.hour >= 5) {
            result = YES;
        }
    }
    
    return  result;
}

- (void)checkAutoWorkOffWithAutoWorkOn:(BOOL)autoOnFlag
{
    Time *time = self.currentTime;
    
    if (time) {
        NSDate *startDate = [time.start_date localDateWithFormat:DB_DATE_YMDHMS];
        NSDate *nowDate = [NSDate date];
        NSDateComponents *startDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:startDate];
        NSDateComponents *nowDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:nowDate];
        
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:startDate];
        BOOL autoOffFlag = NO;
        
        NSInteger interval = [nowDate timeIntervalSinceDate:startDate];
        if (interval / 3600 > 24) {
            if (startDateComponents.hour >= 0 && startDateComponents.hour < 5) {
                autoOffFlag = YES;
                
                [dateComponents setHour:4];
                [dateComponents setMinute:59];
                [dateComponents setSecond:59];
            } else {
                autoOffFlag = YES;
                
                [dateComponents setDay:startDateComponents.day + 1];
                [dateComponents setHour:4];
                [dateComponents setMinute:59];
                [dateComponents setSecond:59];
            }
        } else {
            if (nowDateComponents.hour >= 5 && nowDateComponents.day == startDateComponents.day && startDateComponents.hour >= 0 && startDateComponents.hour < 5) {
                autoOffFlag = YES;
                
                [dateComponents setHour:4];
                [dateComponents setMinute:59];
                [dateComponents setSecond:59];
            } else if (nowDateComponents.day != startDateComponents.day && nowDateComponents.hour >= 5) {
                autoOffFlag = YES;
                
                [dateComponents setDay:startDateComponents.day + 1];
                [dateComponents setHour:4];
                [dateComponents setMinute:59];
                [dateComponents setSecond:59];
            }
        }
        
        if (autoOffFlag) {
            NSDate *endDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
            NSString *end_date = [endDate localStringWithFormat:DB_DATE_YMDHMS];
            [time setEnd_date:end_date];
            [time setIsEnd:YES];
            [time setEnd_type:@"0"];
            double latitude = [AppManager sharedInstance].testLatitude;
            double longitude = [AppManager sharedInstance].testLongitude;
            [time setEnd_latitude:[NSString stringWithFormat:@"%f", latitude]];
            [time setEnd_longitude:[NSString stringWithFormat:@"%f", longitude]];
            [time setEnd_type:[NSString stringWithFormat:@"%d", RecordTypeAuto]];
            [time save];
            
            // Set end date to current day
            [self.currentDay setEnd_date:end_date];
            
            // Area id
            NSString *areaID = time.aid;
            // Remove working time
            [self setCurrentTime:nil];
            
            [Master saveValue:@"" forKey:MSTKeyCurrentTimeID];
            [self setOvertimeType:OvertimeTypeNone];
            
            if (autoOnFlag) {
                [dateComponents setYear:nowDateComponents.year];
                [dateComponents setMonth:nowDateComponents.month];
                [dateComponents setDay:nowDateComponents.day];
                [dateComponents setHour:5];
                [dateComponents setMinute:0];
                [dateComponents setSecond:0];
                
                NSDate * date = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
                [self startTimeForDate:date withAreaID:areaID autoFlag:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:ReloadDataNotification object:nil];
            }
        }
    }
}

- (void)startTimeForDate:(NSDate *)date withAreaID:(NSString *)areaID
{
    [self startTimeForDate:date withAreaID:areaID autoFlag:NO];
}

- (void)startTimeForDate:(NSDate *)date withAreaID:(NSString *)areaID autoFlag:(BOOL)autoFlag
{
    // New time
    Time *time = [[Time alloc] init];
    [time setAid:areaID];
    [time setStart_date:[date localStringWithFormat:DB_DATE_YMDHMS]];
    double latitude = [AppManager sharedInstance].testLatitude;
    double longitude = [AppManager sharedInstance].testLongitude;
    [time setStart_latitude:[NSString stringWithFormat:@"%f", latitude]];
    [time setStart_longitude:[NSString stringWithFormat:@"%f", longitude]];
    if (autoFlag) {
        [time setStart_type:[NSString stringWithFormat:@"%d", RecordTypeAuto]];
    }
    [time save];
    
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
    // New day check
    BOOL newDay = NO;
    if (self.currentDay) {
        NSDate *startDate = [self.currentDay.start_date localDateWithFormat:DB_DATE_YMDHMS];
        NSDateComponents *startDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:startDate];
        
        NSInteger interval = [date timeIntervalSinceDate:startDate];
        if (interval / 3600 > 24) {
            newDay = YES;
        } else {
            if (dateComponents.hour >= 5 && dateComponents.day == startDateComponents.day && startDateComponents.hour >= 0 && startDateComponents.hour < 5) {
                newDay = YES;
            } else if (dateComponents.day != startDateComponents.day && dateComponents.hour >= 5) {
                newDay = YES;
            }
        }
    } else {
        newDay = YES;
    }
    // New day
    if (newDay) {
        // Send last day data
        Year *year = [[[[AppManager sharedInstance] era] yearArray] lastObject];
        Month *month = [[year monthArray] lastObject];
        Day *lastDay = [[month dayArray] lastObject];
        if (lastDay) {
            NSString *formattedMoney = [AppManager currencyFormat:(NSInteger)lastDay.money];
            NSString *formattedHourMoney = [AppManager currencyFormat:[MASTER(MSTKeyPaymentHour) integerValue]];
            NSString *message = [NSString stringWithFormat:@"%@ %@ %@ %@", lastDay.ymdDate,[AppManager hoursToGAHHmm:lastDay.otHours], formattedMoney, formattedHourMoney];
            DLog(@"残業代・時間累積データ: %@", message);

            // Log tracker
            NSDictionary *parameters2 = [[GAIDictionaryBuilder createEventWithCategory:OTUUID
                                                                                action:@"残業代・時間累積データ"
                                                                                 label:message
                                                                                 value:nil] build];
            [[[GAI sharedInstance] defaultTracker] send:parameters2];
        }
        
        // New day
        Day *day = [self.era addNewDay:time withDate:date];
        [self setCurrentDay:day];
        
        if ([MASTER(MSTKeyKyaraID) integerValue] == 0) {
            if ([MASTER(MSTKeyPushMsgType) length] == 0) {
                NSInteger type = 0;
                [Master saveValue:[NSString stringWithFormat:@"%d", (int)type] forKey:MSTKeyPushMsgType];
            } else {
                NSInteger type = arc4random() % 3;
                [Master saveValue:[NSString stringWithFormat:@"%d", (int)type] forKey:MSTKeyPushMsgType];
            }
        }
        
        if ([MASTER(MSTKeyLastConfirm) integerValue] == 1) {
            [AppManager cancelLastConfirmNotification];
            [AppManager addLastConfirmNotification];
        }
        
        if (!month || ![time.belong_month isEqualToString:month.monthOfDate]) {
            NSString *amount = MASTER(MSTKeyChargeAmount);
            [Master saveValue:amount forKey:MSTKeyNextChargeAmount];
        }
        
        // Upload database file to iCloud
        [iCloudUtils uploadFileToiCloud];
    } else {
        // Current day
        if (!self.currentDay) {
            self.currentDay = [self.era dayFromDate:date];
        }
        [self.currentDay.timeArray addObject:time];
    }
    [self setCurrentDate:date];
    [self setCurrentDateComponents:dateComponents];
    
    // Save time pid to master
    NSString *timePid = [NSString stringWithFormat:@"%lld", time.pid];
    [Master saveValue:timePid forKey:MSTKeyCurrentTimeID];
    
    // Save time to memory
    [self setCurrentTime:time];
    
    // Overtime type
    if (self.currentDay.isHoliday) {
        [self setOvertimeType:OvertimeTypeOTing];
    } else {
        [self setOvertimeType:OvertimeTypeWorking];
    }
    
    NSString *body = @"";
    if (self.currentDay.isHoliday) {
        body = [AppManager pushMessageForKey:MSGOTStart];
    } else {
        body = [AppManager pushMessageForKey:MSGWorkStart];
    }
    if ([MASTER(MSTKeyWorkOn) integerValue] == 1 && !self.currentDay.isHoliday) {
        // Log tracker
        NSDictionary *parameters = [[GAIDictionaryBuilder createEventWithCategory:OTUUID
                                                                           action:@"出勤打刻時"
                                                                            label:time.start_date
                                                                            value:nil] build];
        [[[GAI sharedInstance] defaultTracker] send:parameters];
        // Local notification
        [AppManager addLocalNotification:body];
    }
    if ([MASTER(MSTKeyOvertimeOn) integerValue] == 1 && self.currentDay.isHoliday) {
        // Log tracker
        NSDictionary *parameters = [[GAIDictionaryBuilder createEventWithCategory:OTUUID
                                                                           action:@"残業開始時"
                                                                            label:time.start_date
                                                                            value:nil] build];
        [[[GAI sharedInstance] defaultTracker] send:parameters];
        // Local notification
        [AppManager addLocalNotification:body];
    }
}

- (NSInteger)level
{
    NSInteger level = 1;
    // Month data
    Month *month = [[[AppManager sharedInstance] era] monthFromDate:self.currentDate];
    
    if (month) {
        if (month.otHours < 10) {
            level = 1;
        } else if (month.otHours >= 10 && month.otHours < 20) {
            level = 2;
        } else if (month.otHours >= 20 && month.otHours < 30) {
            level = 3;
        } else if (month.otHours >= 30 && month.otHours < 50) {
            level = 4;
        } else {
            level = 5;
        }
    }
    return level;
}

+ (NSString *)avatarNameBySex:(Gender)sex levelType:(LevelType)levelType
{
    NSString *gender = @"";
    NSString *color = @"";
    if (sex == Male) {
        gender = @"men";
    } else {
        gender = @"lady";
    }
    switch (levelType) {
        case LevelTypeBlue:
            color = @"blue";
            break;
        case LevelTypeGray:
            color = @"gray";
            break;
        case LevelTypeGreen:
            color = @"green";
            break;
        case LevelTypeOrange:
            color = @"orange";
            break;
        case LevelTypeRed:
            color = @"red";
            break;
        default:
            color = @"gray";
            break;
    }
    NSString *name = [NSString stringWithFormat:@"sns_%@_%@_s",gender,color];
    return name;
}

- (void)endTimeForDate:(NSDate *)date
{
    [self endTimeForDate:date withNotificationFlag:YES];
}

- (void)endTimeForDate:(NSDate *)date withNotificationFlag:(BOOL)notificationFlag
{
    [self endTime:self.currentTime forDate:date withNotificationFlag:notificationFlag];
}

- (void)endTime:(Time *)time forDate:(NSDate *)date withNotificationFlag:(BOOL)notificationFlag
{
    if (time) {
        // Overtime type
        [self setOvertimeType:OvertimeTypeWorkOff];
        
        NSDate *startDate = [time.start_date localDateWithFormat:DB_DATE_YMDHMS];
        NSDate *endDate = nil;
        
        NSDateComponents *startDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:startDate];
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
        
        NSDateComponents *newDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:startDate];
        
        if (dateComponents.hour >= 5 && dateComponents.day == startDateComponents.day && startDateComponents.hour >= 0 && startDateComponents.hour < 5) {
            [newDateComponents setHour:4];
            [newDateComponents setMinute:59];
            [newDateComponents setSecond:59];
            
            endDate = [[NSCalendar currentCalendar] dateFromComponents:newDateComponents];
            
        } else if (dateComponents.day != startDateComponents.day && dateComponents.hour >= 5) {
            [newDateComponents setDay:startDateComponents.day + 1];
            [newDateComponents setHour:4];
            [newDateComponents setMinute:59];
            [newDateComponents setSecond:59];
            
            endDate = [[NSCalendar currentCalendar] dateFromComponents:newDateComponents];
        } else {
            endDate = date;
        }
        
        NSString *end_date = [endDate localStringWithFormat:DB_DATE_YMDHMS];
        [time setEnd_date:end_date];
        [time setIsEnd:YES];
        [time setEnd_type:@"0"];
        double latitude = [AppManager sharedInstance].testLatitude;
        double longitude = [AppManager sharedInstance].testLongitude;
        [time setEnd_latitude:[NSString stringWithFormat:@"%f", latitude]];
        [time setEnd_longitude:[NSString stringWithFormat:@"%f", longitude]];
        [time save];
        
        if (self.currentDay) {
            // Set current day end date to date
            [self.currentDay setEnd_date:end_date];
            
            if (self.currentDay.otHours > 0) {
                // Log tracker
                NSDictionary *parameters1 = [[GAIDictionaryBuilder createEventWithCategory:OTUUID
                                                                                    action:@"残業終了時"
                                                                                     label:time.end_date
                                                                                     value:nil] build];
                [[[GAI sharedInstance] defaultTracker] send:parameters1];
            } else {
                // Log tracker
                NSDictionary *parameters = [[GAIDictionaryBuilder createEventWithCategory:OTUUID
                                                                                   action:@"退勤打刻時"
                                                                                    label:time.end_date
                                                                                    value:nil] build];
                [[[GAI sharedInstance] defaultTracker] send:parameters];
            }
        }
    }
    
    // Remove time from master
    [Master saveValue:@"" forKey:MSTKeyCurrentTimeID];
    
    // Remove time from memory
    [self setCurrentTime:nil];
    
    if (notificationFlag) {
        NSString *body = @"";
        if (self.currentDay.isHoliday || self.currentDay.otHours > 0) {
            body = [AppManager pushMessageForKey:MSGOTEnd];
        } else {
            body = [AppManager pushMessageForKey:MSGWorkEnd];
        }
        if (([MASTER(MSTKeyWorkOff) integerValue] == 1 && self.currentDay.otHours == 0) ||
            ([MASTER(MSTKeyOvertimeOff) integerValue] == 1 && self.currentDay.otHours > 0)) {
            // Local notification
            [AppManager addLocalNotification:body];
        }
    }
}

- (void)reloadEraData
{
    // Load data from database
    [self setEra:[Era currentEra]];
    [self setCurrentDay:[self.era dayFromDate:self.currentDate]];
    if ([self isWorking]) {
        if (self.currentDay.otHours > 0) {
            [self setOvertimeType:OvertimeTypeOTing];
        } else {
            [self setOvertimeType:OvertimeTypeWorking];
        }
    } else {
        if (self.currentDay) {
            [self setOvertimeType:OvertimeTypeWorkOff];
        }
    }
}

- (BOOL)isWorking
{
    return self.overtimeType == OvertimeTypeWorking || self.overtimeType == OvertimeTypeOTing;
}

//+ (NSArray *)daysArrayAtDate:(NSString *)dateString
//{
//    NSDate *date = [dateString dateWithFormat:@"yyyy年M月"];
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    
//    NSRange days = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
//    NSMutableArray *daysArray = [NSMutableArray array];
//    for (int i = 1; i <= days.length; i++) {
//        NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:date];
//        [dateComponents setDay:i];
//        NSDate *iDate = [calendar dateFromComponents:dateComponents];
//        
//        NSMutableDictionary *dayDictionary = [NSMutableDictionary dictionary];
//        [dayDictionary setObject:[NSString stringWithFormat:@"%d", i] forKey:KEY_DAY];
//        [dayDictionary setObject:[iDate weekdayStringFromDate:iDate] forKey:KEY_WEEK];
//        
//        [daysArray addObject:dayDictionary];
//    }
//    return daysArray;
//}

//- (NSString *)UDID
//{
//    // 1E2DFA89-496A-47FD-9941-DF1FC4E6484A
//    if (!_UDID) {
//#ifdef DEBUG
//        if ([[[UIDevice currentDevice] model] hasSuffix:@"Simulator"]) {
//            _UDID = @"IOS_SIMULATOR";
//            return _UDID;
//        }
//#endif
//        if ([ASIdentifierManager sharedManager].advertisingTrackingEnabled) {
//            _UDID = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
//        } else {
//            _UDID = @"デバイスIDが無効です。\n・iOSのバージョンは最新ですか？  \n・設定の[一般]＞[アドバタイズ]＞[追跡型広告を制限]がオフになっていませんか？";
//        }
//    }
//    return _UDID;
//}

+ (AFHTTPRequestOperationManager *)requestOperationManager
{
    NSURL *url = [NSURL URLWithString:BASE_URL];
    AFHTTPRequestOperationManager *operationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    [serializer setTimeoutInterval:TIMEOUT_SECONDS];
    return operationManager;
}

+ (void)requestDidFailed:(id)error
{
    DLog(@"%@", error);
    [self requestDidFailed:error message:@"ネットワーク接続、またはサーバの状態が不安定になっている可能性があります。時間をおいてもう一度試してみてください。"];
}

+ (void)requestDidFailedWithResult:(id)result
{
    [self requestDidFailedWithResult:result message:@"ネットワーク接続、またはサーバの状態が不安定になっている可能性があります。時間をおいてもう一度試してみてください。"];
}

+ (void)requestDidFailed:(id)error message:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

+ (void)requestDidFailedWithResult:(id)result message:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

// Number to currency
+ (NSString *)formatToCurrency:(double)value withDigit:(NSInteger)digit
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMinimumFractionDigits:digit];
    [formatter setMaximumFractionDigits:digit];
    return [formatter stringFromNumber:[NSNumber numberWithDouble:value]];
}

+ (NSString *)formatValue:(double)value withFormat:(NSString *)format
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat:format];
    return [formatter stringFromNumber:[NSNumber numberWithDouble:value]];
}

+ (NSString *)currencyFormat:(double)value
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter stringFromNumber:[NSNumber numberWithDouble:value]];
}

+ (NSString *)weekTextAtIndex:(NSInteger)index
{
    NSString *weekText = @"";
    switch (index) {
        case 1:
            weekText = @"月";
            break;
        case 2:
            weekText = @"火";
            break;
        case 3:
            weekText = @"水";
            break;
        case 4:
            weekText = @"木";
            break;
        case 5:
            weekText = @"金";
            break;
        case 6:
            weekText = @"土";
            break;
        case 0:
            weekText = @"日";
            break;
        default:
            break;
    }
    return weekText;
}

+ (void)addLocalNotification:(NSString *)body
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    [notification setAlertBody:body];
    [notification setFireDate:[NSDate date]];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

+ (NSString *)pushMessageForKey:(NSString *)key
{
    NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"PushMsg" ofType:@"plist"]];
    NSArray *pushMessageArray = [NSArray arrayWithContentsOfURL:fileURL];
    NSDictionary *masterDic = [[AppManager sharedInstance] masterDic];
    NSInteger type = [masterDic[MSTKeyPushMsgType] integerValue];
    if (type < 0 || type > 3) {
        type = 0;
    }
    NSDictionary *pushMessageDic = pushMessageArray[type];
    return pushMessageDic[key];
}

+ (NSString *)messageKeyForHour:(double)hour
{
    if (hour >= 100.0) {
        return @"MSGLV100H";
    } else if (hour >= 50) {
        return @"MSGLV50H";
    } else if (hour >= 30) {
        return @"MSGLV30H";
    } else if (hour >= 20) {
        return @"MSGLV20H";
    } else if (hour >= 10) {
        return @"MSGLV10H";
    } else {
        return @"";
    }
}

+ (NSString *)homeMessageForKey:(NSString *)key
{
    NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"HomeMsg" ofType:@"plist"]];
    NSArray *homeMessageArray = [NSArray arrayWithContentsOfURL:fileURL];
    NSDictionary *masterDic = [[AppManager sharedInstance] masterDic];
    NSInteger type = [masterDic[MSTKeyHomeMsgType] integerValue];
    if (type < 0 || type > 8) {
        type = 0;
    }
    
    NSDictionary *pushMessageDic = homeMessageArray[type];
    return pushMessageDic[key];
}

+ (NSString *)homeMessageForHour:(double)hour
{
    NSString *key = [self messageKeyForHour:hour];
    NSString *message = @"";
    if (key.length > 0) {
        message = [self homeMessageForKey:key];
    }
    return message;
}

+ (void)addLastConfirmNotification
{
    NSString *lastConfirmWeek = MASTER(MSTKeyConfirmWeek);
    NSString *time = MASTER(MSTKeyConfirmTime);
    
    if ([lastConfirmWeek rangeOfString:@"1"].location != NSNotFound) {
        NSString *dateString = [NSString stringWithFormat:@"2000-01-03 %@:00", time];
        NSDate *date = [dateString localDateWithFormat:DB_DATE_YMDHMS];
        [self addWeekRepeatLocalNotification:date];
    }
    if ([lastConfirmWeek rangeOfString:@"2"].location != NSNotFound) {
        NSString *dateString = [NSString stringWithFormat:@"2000-01-04 %@:00", time];
        NSDate *date = [dateString localDateWithFormat:DB_DATE_YMDHMS];
        [self addWeekRepeatLocalNotification:date];
    }
    if ([lastConfirmWeek rangeOfString:@"3"].location != NSNotFound) {
        NSString *dateString = [NSString stringWithFormat:@"2000-01-05 %@:00", time];
        NSDate *date = [dateString localDateWithFormat:DB_DATE_YMDHMS];
        [self addWeekRepeatLocalNotification:date];
    }
    if ([lastConfirmWeek rangeOfString:@"4"].location != NSNotFound) {
        NSString *dateString = [NSString stringWithFormat:@"2000-01-06 %@:00", time];
        NSDate *date = [dateString localDateWithFormat:DB_DATE_YMDHMS];
        [self addWeekRepeatLocalNotification:date];
    }
    if ([lastConfirmWeek rangeOfString:@"5"].location != NSNotFound) {
        NSString *dateString = [NSString stringWithFormat:@"2000-01-07 %@:00", time];
        NSDate *date = [dateString localDateWithFormat:DB_DATE_YMDHMS];
        [self addWeekRepeatLocalNotification:date];
    }
    if ([lastConfirmWeek rangeOfString:@"6"].location != NSNotFound) {
        NSString *dateString = [NSString stringWithFormat:@"2000-01-01 %@:00", time];
        NSDate *date = [dateString localDateWithFormat:DB_DATE_YMDHMS];
        [self addWeekRepeatLocalNotification:date];
    }
    if ([lastConfirmWeek rangeOfString:@"0"].location != NSNotFound) {
        NSString *dateString = [NSString stringWithFormat:@"2000-01-02 %@:00", time];
        NSDate *date = [dateString localDateWithFormat:DB_DATE_YMDHMS];
        [self addWeekRepeatLocalNotification:date];
    }
}

+ (void)cancelLastConfirmNotification
{
    NSArray *scheduledNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *notification in scheduledNotifications) {
        NSInteger type = [notification.userInfo[NOTIFICATION_TYPE] integerValue];
        if (type != NotificationTypeOneDayBefore && type != NotificationTypeSevenDayBefore) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}

+ (void)addWeekRepeatLocalNotification:(NSDate *)date
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    [notification setAlertBody:[self pushMessageForKey:MSGLastConfirm]];
    [notification setFireDate:date];
    [notification setRepeatInterval:NSWeekCalendarUnit];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

+ (NSString *)hoursToHHmm:(double)totalHours
{
    NSInteger hour = floor(totalHours);
    NSInteger minute = (totalHours - hour) * 60;
    NSString *intervalHM = [NSString stringWithFormat:@"%02d:%02d", (int)hour, (int)minute];
    return intervalHM;
}

+ (NSString *)hoursToGAHHmm:(double)totalHours
{
    NSInteger hour = floor(totalHours);
    NSInteger minute = (totalHours - hour) * 60;
    NSString *intervalHM = [NSString stringWithFormat:@"%02d:%02d", (int)hour, (int)minute];
    return intervalHM;
}

+ (NSInteger)calculateHourMoney:(NSString *)money
{
    NSInteger monthMoney = [money integerValue];
    
    NSDictionary *masterDic = [[AppManager sharedInstance] masterDic];
    NSArray *weekArray = [masterDic[MSTKeyWeekday] componentsSeparatedByString:@","];
    
    // 月給から時給を計算する方法 ⇒ 月給÷(1週間の出勤日数×4週分)÷8時間
    NSInteger hourMoney = monthMoney / (weekArray.count * 4) / 8;
    
    return hourMoney;
}

- (NSString *)shareTextWithURL:(NSString *)urlString
{
    Month *month = [self.era monthFromDate:self.currentDate];
    double hours = [month otHours];
    NSString *shareText = [NSString stringWithFormat:SHARE_TEXT, (int)hours, [AppManager homeMessageForHour:hours], urlString];
    return shareText;
}

#pragma mark - Network

- (void)requestUUID
{
    AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
    NSDictionary *parameters = @{@"uuid": MASTER(MSTKeyUUID), @"is_new": MASTER(MSTKeyOldUser)};
    [manager POST:@"user/login" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        if ([responseObject[@"error"] integerValue] == 200) {
            // Save uuid flag
            [Master saveValue:@"1" forKey:MSTKeyUserLogined];
            
            // Request number
            [[AppManager sharedInstance] requestTopLikeNum];
            
            // Request task list
            [[AppManager sharedInstance] requestUserInfo];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)requestTopLikeNum
{
    AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
    NSDictionary *parameters = @{@"uuid": MASTER(MSTKeyUUID)};
    [manager POST:@"/user/toplikenum" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"error"] integerValue] == ErrorNone) {
            NSDictionary *userInfo = @{TopLikeNumKey: responseObject[@"like_num"]};
            [[NSNotificationCenter defaultCenter] postNotificationName:TopLikeNumDidFetchedNotification object:nil userInfo:userInfo];
        } else if ([responseObject[@"error"] integerValue] == ErrorUUIDNotFound) {
            // Save uuid flag
            [Master saveValue:@"" forKey:MSTKeyUserLogined];
            // Relogin
            [[AppManager sharedInstance] requestUUID];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (BOOL)taskValidFromTag:(NSString *)taskTag
{
    BOOL ret = NO;
    for (Task *task in self.taskArray) {
        if ([task.task_tag isEqualToString:taskTag]) {
            ret = YES;
            break;
        }
    }
    return ret;
}

- (Task *)taskFromTag:(NSString *)taskTag
{
    Task *task = nil;
    for (task in self.taskArray) {
        if ([task.task_tag isEqualToString:taskTag]) {
            break;
        }
    }
    return task;
}

- (void)requestUserInfo
{
    AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
    NSDictionary *parameters = @{@"uuid": MASTER(MSTKeyUUID)};
    [manager POST:@"/user/info" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"error"] integerValue] == ErrorNone) {
            // Not shown task
            self.unshownTaskArray = [NSMutableArray array];
            
            NSMutableArray *taskArray = [NSMutableArray array];
            NSArray *dicTaskArray = responseObject[@"tasks"];
            for (NSDictionary *dic in dicTaskArray) {
                NSArray *finishedTaskArray = dic[@"task_detail"];
                if (finishedTaskArray.count > 0) {
                    for (NSDictionary *subDic in finishedTaskArray) {
                        BOOL exist = NO;
                        for (Task *dbTask in self.finishedTaskArray) {
                            if ([dbTask.tid isEqualToString:subDic[@"id"]]) {
                                exist = YES;
                                break;
                            }
                        }
                        if (!exist) {
                            Task *task = [self taskFromDic:dic];
                            [task setTid:subDic[@"id"]];
                            [task setCampaign_flag:subDic[@"isEvent"]];
                            [task setTask_days:subDic[@"times"]];
                            [task setTask_date:subDic[@"date"]];
                            [task save];
                            
                            [self.finishedTaskArray addObject:task];
                            
                            if ([task.task_tag isEqualToString:TASK_INVITE]) {
                                [self.unshownTaskArray addObject:task];
                            }
                        }
                    }
                }
                Task *task = [self taskFromDic:dic];
                [taskArray addObject:task];
            }
            [self setTaskArray:taskArray];
            
            NSInteger totalDays = [responseObject[@"total_time"] integerValue];
            if ([MASTER(MSTKeyMaxDate) length] == 0) {
                [TaskUtils handleDaysIncrease:totalDays];
            } else {
                NSInteger deltaDays = totalDays - self.heldDays;
                if (deltaDays > 0) {
                    Task *task = [self taskFromTag:TASK_INVITE];
                    [task setTask_days:[NSString stringWithFormat:@"%d", (int)deltaDays]];
                    [TaskUtils handleTaskComplete:task];
                } else if (deltaDays < 0) {
                    [Master saveValue:responseObject[@"total_time"] forKey:MSTKeyHeldDays];
                }
            }
            
            for (Task *task in self.unshownTaskArray) {
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [AchievementViewController showInController:appDelegate.navigationController taskInfo:task];
            }
            [self.unshownTaskArray removeAllObjects];
            
            if (TASK_APP_VERSION_ENABLE && ![[NSUserDefaults standardUserDefaults] boolForKey:TASK_APP_VERSION_DISABLE]) {
                NSString *lastVersion = MASTER(MSTKeyAppVersion);
                if (lastVersion.length > 0) {
                    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                    if ([lastVersion compare:currentVersion] == NSOrderedAscending) {
                        [self requestTaskComplete:TASK_APP_VERSION];
                    }
                } else {
                    [self requestTaskComplete:TASK_APP_VERSION];
                }
            }
        } else if ([responseObject[@"error"] integerValue] == ErrorUUIDNotFound) {
            // Save uuid flag
            [Master saveValue:@"" forKey:MSTKeyUserLogined];
            // Relogin
            [[AppManager sharedInstance] requestUUID];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (Task *)taskFromDic:(NSDictionary *)dic
{
    Task *task = [[Task alloc] init];
    [task setTask_id:dic[@"task_id"]];
    [task setTask_tag:dic[@"task_tag"]];
    [task setTask_title:dic[@"task_title"]];
    [task setTask_detail:dic[@"task_content"]];
    [task setTask_type:dic[@"task_type"]];
    [task setTask_days:dic[@"times"]];
    [task setFinished_times:dic[@"finished_num"]];
    [task setFinished_days:dic[@"finished_times"]];
    [task setCapable_times:dic[@"capable_num"]];
    return task;
}

- (void)requestTaskComplete:(NSString *)taskTag
{
    AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
    NSDictionary *parameters = @{@"uuid": MASTER(MSTKeyUUID), @"task_tag": taskTag};
    [manager POST:@"/task/complete" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"error"] integerValue] == ErrorNone) {
            Task *task = [[AppManager sharedInstance] taskFromTag:taskTag];
            [task setTask_date:[[NSDate date] localStringWithFormat:DB_DATE_YMDHMS]];
            [TaskUtils handleTaskComplete:task];
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [AchievementViewController showInController:appDelegate.navigationController taskInfo:task];
            
            if ([taskTag isEqualToString:TASK_APP_VERSION]) {
                NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                [Master saveValue:currentVersion forKey:MSTKeyAppVersion];
            }
        } else if ([responseObject[@"error"] integerValue] == ErrorUUIDNotFound) {
            // Save uuid flag
            [Master saveValue:@"" forKey:MSTKeyUserLogined];
            // Relogin
            [[AppManager sharedInstance] requestUUID];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

@end
