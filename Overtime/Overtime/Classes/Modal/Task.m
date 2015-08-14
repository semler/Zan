//
//  Task.m
//  Overtime
//
//  Created by xuxiaoteng on 2/17/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import "Task.h"

@implementation Task

- (id)init
{
    self = [super init];
    if (self) {
        _tid = @"";
        _task_id = @"";
        _task_tag = @"";
        _task_title = @"";
        _task_type = @"";
        _task_days = @"";
        _campaign_flag = @"";
        _task_date = @"";
        _capable_times = @"";
        _finished_times = @"";
        _finished_days = @"";
    }
    return self;
}

- (BOOL)save
{
    BOOL result = NO;
    
    if (self.pid > 0) {
        [self setUpdate_date:[[NSDate date] localStringWithFormat:DB_DATE_YMDHMS]];
    } else {
        [self setCreate_date:[[NSDate date] localStringWithFormat:DB_DATE_YMDHMS]];
        [self setUpdate_date:self.create_date];
    }
    
    NSString *sql = @"REPLACE INTO task ('pid', 'tid', 'task_id', 'task_tag', 'task_title', 'task_type', 'task_days', 'campaign_flag', 'task_date', 'capable_times', 'finished_times', 'finished_days', 'create_date', 'update_date', 'delete_flag') VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    result =  [self.dbo executeUpdate:sql, self.pid > 0 ? @(self.pid) : NULL, self.tid, self.task_id, self.task_tag, self.task_title, self.task_tag, self.task_days, self.campaign_flag, self.task_date, self.capable_times, self.finished_times, self.finished_days, self.create_date, self.update_date, self.delete_flag];
    
    if (NO == result) {
        DLog(@"%@", [self.dbo lastErrorMessage]);
    } else {
        if (self.pid == 0) {
            [self setPid:[self.dbo lastInsertRowId]];
        }
    }
    return result;
}

+ (NSMutableArray *)allTasks
{
    FMDatabase *dbo = [[DBUtils sharedDBUtils] dbo];
    NSString *sql = @"SELECT * FROM task";
    FMResultSet *resultSet = [dbo executeQuery:sql];
    
    NSMutableArray *taskArray = [NSMutableArray array];
    while (resultSet.next) {
        Task *task = [self taskFromResultSet:resultSet];
        [taskArray addObject:task];
    }
    return taskArray;
}

+ (Task *)taskFromResultSet:(FMResultSet *)rs
{
    Task *task = [[Task alloc] init];
    task.pid = [rs longLongIntForColumn:@"pid"];
    task.tid = [rs stringForColumn:@"tid"];
    task.task_id = [rs stringForColumn:@"task_id"];
    task.task_tag = [rs stringForColumn:@"task_tag"];
    task.task_title = [rs stringForColumn:@"task_title"];
    task.task_type = [rs stringForColumn:@"task_type"];
    task.task_days = [rs stringForColumn:@"task_days"];
    task.campaign_flag = [rs stringForColumn:@"campaign_flag"];
    task.task_date = [rs stringForColumn:@"task_date"];
    task.create_date = [rs stringForColumn:@"create_date"];
    task.update_date = [rs stringForColumn:@"update_date"];
    task.delete_flag = [rs stringForColumn:@"delete_flag"];
    task.capable_times = [rs stringForColumn:@"capable_times"];
    task.finished_days = [rs stringForColumn:@"finished_days"];
    task.finished_times = [rs stringForColumn:@"finished_times"];
    return task;
}

@end
