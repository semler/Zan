//
//  LogUtils.h
//  Overtime
//
//  Created by xuxiaoteng on 1/15/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogUtils : NSObject

+ (void)saveLog:(NSString *)logText;
+ (void)saveRunningLog:(NSString *)logText;

@end
