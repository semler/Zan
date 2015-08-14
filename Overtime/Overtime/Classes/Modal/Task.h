//
//  Task.h
//  Overtime
//
//  Created by xuxiaoteng on 2/17/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import "Modal.h"

@interface Task : Modal

@property (nonatomic, copy) NSString *tid;
@property (nonatomic, copy) NSString *task_id;
@property (nonatomic, copy) NSString *task_tag;
@property (nonatomic, copy) NSString *task_title;
@property (nonatomic, copy) NSString *task_detail;
@property (nonatomic, copy) NSString *task_type;
@property (nonatomic, copy) NSString *task_days;
@property (nonatomic, copy) NSString *campaign_flag;
@property (nonatomic, copy) NSString *task_date;
@property (nonatomic, copy) NSString *capable_times;
@property (nonatomic, copy) NSString *finished_times;
@property (nonatomic, copy) NSString *finished_days;

+ (NSMutableArray *)allTasks;

@end
