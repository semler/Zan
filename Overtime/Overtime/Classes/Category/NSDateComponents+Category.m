//
//  NSDateComponent+Category.m
//  Overtime
//
//  Created by xuxiaoteng on 1/16/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import "NSDateComponents+Category.h"

@implementation NSDateComponents (Category)

- (NSDateComponents *)copy
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:self.year];
    [dateComponents setMonth:self.month];
    [dateComponents setDay:self.day];
    [dateComponents setHour:self.hour];
    [dateComponents setMinute:self.minute];
    [dateComponents setSecond:self.second];
    return dateComponents;
}

@end
