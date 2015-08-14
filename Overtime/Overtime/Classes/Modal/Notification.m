//
//  Notification.m
//  Overtime
//
//  Created by Xu Shawn on 3/11/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "Notification.h"

@implementation Notification

- (id)init
{
    self = [super init];
    if (self) {
        _nid = @"";
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
    
    NSString *sql = @"REPLACE INTO notification ('pid', 'nid', 'aid', 'inout_flag', 'send_flag', 'create_date', 'update_date', 'delete_flag') VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    result =  [self.dbo executeUpdate:sql, self.pid > 0 ? @(self.pid) : NULL, self.nid, self.aid, self.inout_flag, self.send_flag, self.create_date, self.update_date, self.delete_flag];
    
    if (NO == result) {
        DLog(@"%@", [self.dbo lastErrorMessage]);
    } else {
        if (self.pid == 0) {
            [self setPid:[self.dbo lastInsertRowId]];
        }
    }
    return result;
}

- (BOOL)physicalDelete
{
    FMDatabase *dbo = [[DBUtils sharedDBUtils] dbo];
    NSString *sql = @"DELETE FROM notification WHERE nid = ?";
    BOOL result = [dbo executeUpdate:sql, self.nid];
    
    if (NO == result) {
        DLog(@"%@", [self.dbo lastErrorMessage]);
    }
    return result;
}

+ (Notification *)notificationWithNid:(NSString *)nid
{
    FMDatabase *dbo = [[DBUtils sharedDBUtils] dbo];
    NSString *sql = @"SELECT * FROM notification WHERE nid = ?";
    FMResultSet *resultSet = [dbo executeQuery:sql, nid];
    Notification *notification = nil;
    
    if (resultSet.next) {
        notification = [self nitificationFromResultSet:resultSet];
    }
    return notification;
}

+ (Notification *)nitificationFromResultSet:(FMResultSet *)rs
{
    Notification *notification = [[Notification alloc] init];
    notification.pid = [rs longLongIntForColumn:@"pid"];
    notification.nid = [rs stringForColumn:@"nid"];
    notification.aid = [rs stringForColumn:@"aid"];
    notification.inout_flag = [rs stringForColumn:@"inout_flag"];
    notification.send_flag = [rs stringForColumn:@"send_flag"];
    notification.create_date = [rs stringForColumn:@"create_date"];
    notification.update_date = [rs stringForColumn:@"update_date"];
    notification.delete_flag = [rs stringForColumn:@"delete_flag"];
    return notification;
}

@end
