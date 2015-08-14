//
//  ShareUtils.h
//  Overtime
//
//  Created by xuxiaoteng on 2/18/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface ShareUtils : NSObject

+ (BOOL)isLineInstalled;
+ (void)shareTextToLine:(NSString *)text;
+ (void)shareTextToFacebook:(NSString *)text;
+ (void)shareTextToTwitter:(NSString *)text;

@end
