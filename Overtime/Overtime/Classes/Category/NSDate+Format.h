//
//  NSDate+Format.h
//  Overtime
//
//  Created by Sean on 3/6/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Format)

- (NSString *)stringWithFormat:(NSString *)format;
- (NSString *)localStringWithFormat:(NSString *)format;
- (NSString *)weekdayString;
- (NSString *)localWeekdayString;
- (NSDate *)dateByAddingMonth:(NSInteger)month;
- (NSDate *)dateByAddingYear:(NSInteger)year;
- (NSDateComponents *)logicalDateComponents;
- (NSString *)displayTime;
- (NSInteger)daysFromDate:(NSDate *)date;
- (NSDate *)logicalDate;
- (NSString *)logicalDateWithFormat:(NSString *)format;
- (BOOL)isToday;

@end
