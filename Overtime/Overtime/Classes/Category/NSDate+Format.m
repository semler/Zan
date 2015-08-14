//
//  NSDate+Format.m
//  Overtime
//
//  Created by Sean on 3/6/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "NSDate+Format.h"

@implementation NSDate (Format)

- (NSString *)stringWithFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:self];
}

- (NSString *)localStringWithFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    return [formatter stringFromDate:self];
}

- (NSString *)weekdayString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [formatter setDateFormat:@"EEE"];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    return [[formatter stringFromDate:self] uppercaseString];
}

- (NSString *)localWeekdayString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [formatter setDateFormat:@"EEE"];
    return [[formatter stringFromDate:self] uppercaseString];
}

- (NSDate *)dateByAddingMonth:(NSInteger)month
{
    NSDateComponents *addDateComponents = [[NSDateComponents alloc] init];
    [addDateComponents setMonth:month];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar dateByAddingComponents:addDateComponents toDate:self options:NSCalendarWrapComponents];
}

- (NSDate *)dateByAddingYear:(NSInteger)year
{
    NSDateComponents *addDateComponents = [[NSDateComponents alloc] init];
    [addDateComponents setYear:year];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar dateByAddingComponents:addDateComponents toDate:self options:NSCalendarWrapComponents];
}

- (NSDateComponents *)logicalDateComponents
{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:self];
    NSDateComponents *newDateComponents = nil;
    if (dateComponents.hour >= 0 && dateComponents.hour < 5) {
        [dateComponents setDay:(dateComponents.day - 1)];
        NSDate *newDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
        newDateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:newDate];
    } else {
        newDateComponents = dateComponents;
    }
    return newDateComponents;
}

- (NSString *)displayTime
{
    if (self) {
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:self];
        
        NSInteger hour = dateComponents.hour;
        
        if (hour < 5) {
            hour += 24;
        }
        return [NSString stringWithFormat:@"%02d:%02d", (int)hour, (int)dateComponents.minute];
    } else {
        return @"";
    }
}

- (NSInteger)daysFromDate:(NSDate *)date
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:self];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:date];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

- (NSDate *)logicalDate
{
    NSDateComponents *logicalDateComponents = [self logicalDateComponents];
    NSDate *logicalDate = [[NSCalendar currentCalendar] dateFromComponents:logicalDateComponents];
    return logicalDate;
}

- (NSString *)logicalDateWithFormat:(NSString *)format
{
    NSDate *logicalDate = [self logicalDate];
    return [logicalDate localStringWithFormat:format];
}

- (BOOL)isToday
{
    NSDate *currentDate = [[AppManager sharedInstance] currentDate];
    NSDateComponents *currentDateComponents = [currentDate logicalDateComponents];
    NSDateComponents *dateComponents = [self logicalDateComponents];
    
    if (dateComponents.year == currentDateComponents.year && dateComponents.month == currentDateComponents.month && dateComponents.day == currentDateComponents.day) {
        return YES;
    } else {
        return NO;
    }
}

@end
