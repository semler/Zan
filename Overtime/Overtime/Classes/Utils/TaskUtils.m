//
//  TaskUtils.m
//  Overtime
//
//  Created by xuxiaoteng on 2/19/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import "TaskUtils.h"
#import "Apsalar.h"

@implementation TaskUtils

+ (void)handleTaskComplete:(Task *)task
{
    NSInteger days = [task.task_days integerValue];
    [self handleDaysIncrease:days];
    
    // Apsalar track task title
    if (task.task_title.length > 0) {
        [Apsalar event:task.task_title];
    }
}

+ (void)handleDaysIncrease:(NSInteger)days
{
    NSDate *maxDate = [DateUtils maxDate];
    NSDate *newDate = nil;
    
    if (days > 0) {
        newDate = [maxDate dateByAddingTimeInterval:days * 24 * 60 * 60];
        [DateUtils saveMaxDate:newDate];
        [[AppManager sharedInstance] addHeldDays:days];
    } else {
        newDate = maxDate;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ReloadDetailDataNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:ReloadChartDataNotification object:nil];
    
    [self scheduleTaskNotificationOnDate:newDate];
}

+ (void)scheduleTaskNotificationOnDate:(NSDate *)date
{
    if (![[AppManager sharedInstance] oldUser]) {
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
        [dateComponents setDay:dateComponents.day - 7];
        [dateComponents setHour:12];
        [dateComponents setMinute:0];
        [dateComponents setSecond:0];
        
        NSArray *scheduledNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
        for (UILocalNotification *notification in scheduledNotifications) {
            NSInteger type = [notification.userInfo[NOTIFICATION_TYPE] integerValue];
            if (type == NotificationTypeOneDayBefore || type == NotificationTypeSevenDayBefore) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
            }
        }
        
        NSDate *sevenDayBeforeDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
        [self addLocalNotificationOnDate:sevenDayBeforeDate notificationMessage:@"あと7日で古い残業データが消えちゃう！今すぐ記録期間を拡張しよう！" notificationType:NotificationTypeSevenDayBefore];
        
        [dateComponents setDay:dateComponents.day + 6];
        NSDate *oneDayBeforeDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
        [self addLocalNotificationOnDate:oneDayBeforeDate notificationMessage:@"あと１日で古い残業データが消えちゃう！今すぐ記録期間を拡張しよう！" notificationType:NotificationTypeOneDayBefore];
    }
}

+ (void)addLocalNotificationOnDate:(NSDate *)date notificationMessage:(NSString *)message notificationType:(NotificationType)type
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    [notification setAlertBody:message];
    [notification setFireDate:date];
    [notification setUserInfo:@{NOTIFICATION_TYPE: @(type)}];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

@end
