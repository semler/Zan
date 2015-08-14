//
//  CalendarUtils.m
//  Overtime
//
//  Created by xuxiaoteng on 1/15/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import "CalendarUtils.h"

@implementation CalendarUtils

+ (NSArray *)monthArray
{
    return @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12"];
}

+ (NSArray *)daysArrayAtDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSRange days = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    NSMutableArray *daysArray = [NSMutableArray array];
    for (NSInteger i = days.length; i >= 1; i--) {
        NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:date];
        [dateComponents setDay:i];
        NSDate *iDate = [calendar dateFromComponents:dateComponents];
        
        NSMutableDictionary *dayDictionary = [NSMutableDictionary dictionary];
        [dayDictionary setObject:[NSString stringWithFormat:@"%02d/%02d", (int)dateComponents.month, (int)i] forKey:KEY_DAY];
        [dayDictionary setObject:[iDate localWeekdayString] forKey:KEY_WEEK];
        
        [daysArray addObject:dayDictionary];
    }
    return daysArray;
}

@end
