//
//  Work.h
//  Overtime
//
//  Created by Xu Shawn on 3/11/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "Modal.h"
#import "Area.h"
#import "Notification.h"

@interface Work : Modal

@property (nonatomic, copy) NSString *rest_start1;
@property (nonatomic, copy) NSString *rest_end1;
@property (nonatomic, copy) NSString *rest_start2;
@property (nonatomic, copy) NSString *rest_end2;
@property (nonatomic, copy) NSString *holiday;
@property (nonatomic, copy) NSString *payment_hour;
@property (nonatomic, copy) NSString *payment_month;

@property (nonatomic, strong) Area *area;
@property (nonatomic, strong) Notification *notificationIn;
@property (nonatomic, strong) Notification *notificationOut;

+ (Work *)work;
+ (NSArray *)workList;

@end
