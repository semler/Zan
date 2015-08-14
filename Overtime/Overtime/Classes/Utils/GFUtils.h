//
//  GFUtils.h
//  Overtime
//
//  Created by xuxiaoteng on 1/15/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GFUtils : NSObject

+ (BOOL)configGeoFence:(NSArray *)areaArray;
+ (void)deleteGeoFenceConfig:(NSArray *)areaArray;
+ (BOOL)setParameter;
+ (BOOL)addAreaInfo:(Area *)area;
+ (BOOL)addNotification:(Notification *)notification;

@end
