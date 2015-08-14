//
//  DateUtils.m
//  Overtime
//
//  Created by xuxiaoteng on 2/13/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import "DateUtils.h"

@implementation DateUtils

+ (NSDate *)maxDate
{
    NSDate *maxDate = nil;
    NSDateComponents *nowDateComponents = [[NSDate date] logicalDateComponents];
    [nowDateComponents setHour:5];
    [nowDateComponents setMinute:0];
    [nowDateComponents setSecond:0];
    NSDate *now = [[NSCalendar currentCalendar] dateFromComponents:nowDateComponents];
    
    if ([[AppManager sharedInstance] oldUser]) {
        maxDate = now;
    } else {
        NSString *maxDateStr = MASTER(MSTKeyMaxDate);
        
        if (maxDateStr.length > 0) {
            maxDate = [maxDateStr localDateWithFormat:DB_DATE_YMD];
            maxDate = [maxDate dateByAddingTimeInterval:5 * 60 * 60];
            if ([now compare:maxDate] != NSOrderedAscending) {
                maxDate = now;
            }
        } else {
            [nowDateComponents setDay:nowDateComponents.day - 1];
            [nowDateComponents setHour:5];
            [nowDateComponents setMinute:0];
            [nowDateComponents setSecond:0];
            NSDate *yesterday = [[NSCalendar currentCalendar] dateFromComponents:nowDateComponents];
            maxDate = yesterday;
        }
    }
    
    return maxDate;
}

+ (void)saveMaxDate:(NSDate *)date
{
    NSString *maxDateString = [date localStringWithFormat:DB_DATE_YMD];
    [Master saveValue:maxDateString forKey:MSTKeyMaxDate];
}

+ (NSDate *)minDate
{
    NSString *minDateStr = [Time oldestDate];
    NSDate *minDate = nil;
    if (minDateStr.length == 0) {
        NSDateComponents *nowDateComponents = [[NSDate date] logicalDateComponents];
        [nowDateComponents setHour:5];
        [nowDateComponents setMinute:0];
        [nowDateComponents setSecond:0];
        NSDate *now = [[NSCalendar currentCalendar] dateFromComponents:nowDateComponents];
        minDate = now;
    } else {
        minDate = [minDateStr localDateWithFormat:DB_DATE_YMD];
        minDate = [minDate dateByAddingTimeInterval:5 * 60 * 60];
    }
    return minDate;
}

@end
