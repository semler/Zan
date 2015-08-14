//
//  NSString+Date.m
//  Overtime
//
//  Created by Sean on 3/6/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "NSString+Date.h"

@implementation NSString (Date)

- (NSDate *)posixDateWithFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    return [formatter dateFromString:self];
}

- (NSDate *)dateWithFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
    return [formatter dateFromString:self];
}

- (NSDate *)localDateWithFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    return [formatter dateFromString:self];
}

- (NSString *)dateStringWithFomat:(NSString *)toFormat fromFormat:(NSString *)fromFormat
{
    NSDate *date = [self localDateWithFormat:fromFormat];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [formatter setDateFormat:toFormat];
    return [formatter stringFromDate:date];
}

- (double)intervalHourToDate:(NSString *)toDate withFormat:(NSString *)format
{
    NSDate *date1 = [self localDateWithFormat:format];
    NSDate *date2 = [toDate localDateWithFormat:format];
    NSTimeInterval timeInterval = [date2 timeIntervalSinceDate:date1];
    return timeInterval / 3600.0;
}

- (NSString *)displayTime
{
    if (self.length > 0) {
        NSDate *date = [self localDateWithFormat:DB_DATE_YMDHMS];
        return [date displayTime];
    } else {
        return @"";
    }
}

@end
