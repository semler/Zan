//
//  TaskUtils.h
//  Overtime
//
//  Created by xuxiaoteng on 2/19/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskUtils : NSObject

+ (void)handleDaysIncrease:(NSInteger)days;
+ (void)handleTaskComplete:(Task *)task;
+ (void)scheduleTaskNotificationOnDate:(NSDate *)date;

@end
