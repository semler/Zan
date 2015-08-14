//
//  Area.m
//  Overtime
//
//  Created by Xu Shawn on 3/11/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "Area.h"

@implementation Area

- (id)init
{
    self = [super init];
    if (self) {
        _aid = @"";
        _name = @"";
        _latitude = @"";
        _longitude = @"";
        _radius = @"";
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

    NSString *sql = @"REPLACE INTO area ('pid', 'aid', 'nid_in', 'nid_out', 'name', 'latitude', 'longitude', 'radius', 'send_flag', 'create_date', 'update_date', 'delete_flag') VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    result =  [self.dbo executeUpdate:sql, self.pid > 0 ? @(self.pid) : NULL, self.aid, self.notificationIn.nid, self.notificationOut.nid, self.name, self.latitude, self.longitude, self.radius, self.send_flag, self.create_date, self.update_date, self.delete_flag];
    
    if (NO == result) {
        DLog(@"SQL ERROR: %@", [self.dbo lastErrorMessage]);
    } else {
        if (self.pid == 0) {
            [self setPid:[self.dbo lastInsertRowId]];
        }
    }
    return result;
}

- (BOOL)physicalDelete
{
    BOOL result = NO;
    
    result = [self.notificationIn physicalDelete];
    result = [self.notificationOut physicalDelete];
    
    FMDatabase *dbo = [[DBUtils sharedDBUtils] dbo];
    NSString *sql = @"DELETE FROM area WHERE aid = ?";
    result = [dbo executeUpdate:sql, self.aid];
    
    if (NO == result) {
        DLog(@"%@", [self.dbo lastErrorMessage]);
    }
    return result;
}

+ (Area *)area
{
    Notification *notificationIn = [[Notification alloc] init];
    [notificationIn setInout_flag:@"1"];
    Notification *notificationOut = [[Notification alloc] init];
    [notificationOut setInout_flag:@"2"];
    
    [notificationIn save];
    [notificationOut save];

    Area *area = [[Area alloc] init];
    [area setNotificationIn:notificationIn];
    [area setNotificationOut:notificationOut];
    [area save];
    [area setAid:[NSString stringWithFormat:@"%lld", area.pid]];
    
    [notificationIn setAid:area.aid];
    [notificationIn setNid:[NSString stringWithFormat:@"%lld", notificationIn.pid]];
    [notificationOut setAid:area.aid];
    [notificationOut setNid:[NSString stringWithFormat:@"%lld", notificationOut.pid]];
    [notificationIn save];
    [notificationOut save];

    [area save];
    
    return area;
}

+ (NSMutableArray *)allArea
{
    FMDatabase *dbo = [[DBUtils sharedDBUtils] dbo];
    NSString *sql = @"SELECT * FROM area";
    FMResultSet *resultSet = [dbo executeQuery:sql];
    
    NSMutableArray *areaArray = [NSMutableArray array];
    while (resultSet.next) {
        Area *area = [self areaFromResultSet:resultSet];
        [areaArray addObject:area];
    }
    return areaArray;
}

+ (Area *)areaWithAid:(NSString *)aid
{
    FMDatabase *dbo = [[DBUtils sharedDBUtils] dbo];
    NSString *sql = @"SELECT * FROM area WHERE aid = ?";
    FMResultSet *resultSet = [dbo executeQuery:sql, aid];
    Area *area = nil;
    
    if (resultSet.next) {
        area = [self areaFromResultSet:resultSet];
    }
    return area;
}

+ (Area *)areaFromResultSet:(FMResultSet *)rs
{
    Area *area = [[Area alloc] init];
    area.pid = [rs longLongIntForColumn:@"pid"];
    area.aid = [rs stringForColumn:@"aid"];
    area.name = [rs stringForColumn:@"name"];
    area.latitude = [rs stringForColumn:@"latitude"];
    area.longitude = [rs stringForColumn:@"longitude"];
    area.radius = [rs stringForColumn:@"radius"];
    area.send_flag = [rs stringForColumn:@"send_flag"];
    area.create_date = [rs stringForColumn:@"create_date"];
    area.update_date = [rs stringForColumn:@"update_date"];
    area.delete_flag = [rs stringForColumn:@"delete_flag"];
    
    NSString *nidIn = [rs stringForColumn:@"nid_in"];
    NSString *nidOut = [rs stringForColumn:@"nid_out"];
    area.notificationIn = [Notification notificationWithNid:nidIn];
    area.notificationOut = [Notification notificationWithNid:nidOut];
    
    return area;
}

@end
