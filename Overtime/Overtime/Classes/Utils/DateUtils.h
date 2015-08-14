//
//  DateUtils.h
//  Overtime
//
//  Created by xuxiaoteng on 2/13/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtils : NSObject

+ (NSDate *)maxDate;
+ (void)saveMaxDate:(NSDate *)date;
+ (NSDate *)minDate;

@end
