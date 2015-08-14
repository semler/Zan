//
//  Notification.h
//  Overtime
//
//  Created by Xu Shawn on 3/11/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "Modal.h"

@interface Notification : Modal

@property (nonatomic, copy) NSString *nid;
@property (nonatomic, copy) NSString *aid;
// 通知タイミング 1:IN 2:OUT
@property (nonatomic, copy) NSString *inout_flag;

- (BOOL)physicalDelete;
+ (Notification *)notificationWithNid:(NSString *)nid;

@end
