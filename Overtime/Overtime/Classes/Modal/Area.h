//
//  Area.h
//  Overtime
//
//  Created by Xu Shawn on 3/11/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "Modal.h"
#import "Notification.h"

@interface Area : Modal

@property (nonatomic, copy) NSString *aid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *longitude;
@property (nonatomic, copy) NSString *radius;

@property (nonatomic, strong) Notification *notificationIn;
@property (nonatomic, strong) Notification *notificationOut;

- (BOOL)physicalDelete;
+ (Area *)area;
+ (Area *)areaWithAid:(NSString *)aid;
+ (NSMutableArray *)allArea;

@end
