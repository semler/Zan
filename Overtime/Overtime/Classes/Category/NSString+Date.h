//
//  NSString+Date.h
//  Overtime
//
//  Created by Sean on 3/6/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Date)

- (NSDate *)posixDateWithFormat:(NSString *)format;
- (NSDate *)dateWithFormat:(NSString *)format;
- (NSDate *)localDateWithFormat:(NSString *)format;
- (NSString *)dateStringWithFomat:(NSString *)toFormat fromFormat:(NSString *)fromFormat;
- (double)intervalHourToDate:(NSString *)toDate withFormat:(NSString *)format;
- (NSString *)displayTime;

@end
