//
//  Work.m
//  Overtime
//
//  Created by Xu Shawn on 3/11/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "Work.h"

@implementation Work

- (id)init
{
    self = [super init];
    if (self) {
        _rest_start1 = @"";
        _rest_start2 = @"";
        _rest_end1 = @"";
        _rest_end2 = @"";
        _holiday = @"";
        _payment_hour = @"";
        _payment_month = @"";
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

    NSString *sql = @"REPLACE INTO work ('pid', 'aid', 'nid_in', 'nid_out', 'rest_start1', 'rest_end1', 'rest_start2', 'rest_end2', 'holiday', 'payment_hour', 'payment_month', 'create_date', 'update_date', 'delete_flag') VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    result =  [self.dbo executeUpdate:sql, self.pid > 0 ? @(self.pid) : NULL, self.area.aid, self.notificationIn.nid, self.notificationOut.nid, self.rest_start1, self.rest_end1, self.rest_start2, self.rest_end2, self.holiday, self.payment_hour, self.payment_month, self.create_date, self.update_date, self.delete_flag];
    
    if (NO == result) {
        DLog(@"%@", [self.dbo lastErrorMessage]);
    } else {
        if (self.pid == 0) {
            [self setPid:[self.dbo lastInsertRowId]];
        }
    }
    return result;
}

- (void)initializeModals
{
    _area = [[Area alloc] init];
    _notificationIn = [[Notification alloc] init];
    [_notificationIn setInout_flag:@"1"];
    _notificationOut = [[Notification alloc] init];
    [_notificationOut setInout_flag:@"2"];
    
    [_area save];
    [_notificationIn save];
    [_notificationOut save];
    
    [_area setAid:[NSString stringWithFormat:@"%lld", _area.pid]];
    [_notificationIn setAid:_area.aid];
    [_notificationIn setNid:[NSString stringWithFormat:@"%lld", _notificationIn.pid]];
    [_notificationOut setAid:_area.aid];
    [_notificationOut setNid:[NSString stringWithFormat:@"%lld", _notificationOut.pid]];
    
    [_area save];
    [_notificationIn save];
    [_notificationOut save];
    [self save];
}

+ (Work *)work
{
    Work *work = [[Work alloc] init];
    [work initializeModals];
    [work save];
    return work;
}

+ (NSArray *)workList
{
    FMDatabase *dbo = [[DBUtils sharedDBUtils] dbo];
    NSString *sql = @"SELECT * FROM work";
    FMResultSet *resultSet = [dbo executeQuery:sql];
    
    NSMutableArray *workArray = [NSMutableArray array];
    while (resultSet.next) {
        Work *work = [self workFromResultSet:resultSet];
        [workArray addObject:work];
    }
    return workArray;
}

+ (Work *)workFromResultSet:(FMResultSet *)rs
{
    Work *work = [[Work alloc] init];
    
    work.pid = [rs longLongIntForColumn:@"pid"];
    NSString *aid = [rs stringForColumn:@"aid"];
    work.area = [Area areaWithAid:aid];
    NSString *nid_in = [rs stringForColumn:@"nid_in"];
    work.notificationIn = [Notification notificationWithNid:nid_in];
    NSString *nid_out = [rs stringForColumn:@"nid_out"];
    work.notificationOut = [Notification notificationWithNid:nid_out];
    work.rest_start1 = [rs stringForColumn:@"rest_start1"];
    work.rest_end1 = [rs stringForColumn:@"rest_end1"];
    work.rest_start2 = [rs stringForColumn:@"rest_start2"];
    work.rest_end2 = [rs stringForColumn:@"rest_end2"];
    work.holiday = [rs stringForColumn:@"holiday"];
    work.payment_hour = [rs stringForColumn:@"payment_hour"];
    work.payment_month = [rs stringForColumn:@"payment_month"];
    work.create_date = [rs stringForColumn:@"create_date"];
    work.update_date = [rs stringForColumn:@"update_date"];
    work.delete_flag = [rs stringForColumn:@"delete_flag"];
    
    return work;
}

@end
