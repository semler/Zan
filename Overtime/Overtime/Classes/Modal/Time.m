//
//  Time.m
//  Overtime
//
//  Created by Xu Shawn on 3/11/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "Time.h"

@implementation Time

- (id)init
{
    self = [super init];
    if (self) {
        _aid = @"";
        _belong_date = @"";
        _belong_year = @"";
        _belong_month = @"";
        _belong_day = @"";
        _start_date = @"";
        _end_date = @"";
        _start_modify_date = @"";
        _end_modify_date = @"";
        _memo_txt = @"";
        _start_type = @"0";
        _end_type = @"0";
        _start_latitude = @"";
        _start_longitude = @"";
        _end_latitude = @"";
        _end_longitude = @"";
    }
    return self;
}

+ (void)addTempTimes
{
    if ([self timesLikeDate:@"2014-12"].count == 0) {
        [self addTimeStart:@"2014-12-01 05:00:00" end:@"2014-12-01 22:00:00"];
        [self addTimeStart:@"2014-12-02 05:00:00" end:@"2014-12-02 22:00:00"];
        [self addTimeStart:@"2014-12-03 05:00:00" end:@"2014-12-03 22:00:00"];
        [self addTimeStart:@"2014-12-04 05:00:00" end:@"2014-12-04 22:00:00"];
        [self addTimeStart:@"2014-12-05 05:00:00" end:@"2014-12-05 22:00:00"];
        [self addTimeStart:@"2014-12-06 05:00:00" end:@"2014-12-06 22:00:00"];
        [self addTimeStart:@"2014-12-07 05:00:00" end:@"2014-12-07 22:00:00"];
        [self addTimeStart:@"2014-12-08 05:00:00" end:@"2014-12-08 22:00:00"];
        [self addTimeStart:@"2014-12-09 05:00:00" end:@"2014-12-09 22:00:00"];
        [self addTimeStart:@"2014-12-10 05:00:00" end:@"2014-12-10 22:00:00"];
        [self addTimeStart:@"2014-12-11 05:00:00" end:@"2014-12-11 22:00:00"];
        [self addTimeStart:@"2014-12-12 05:00:00" end:@"2014-12-12 22:00:00"];
        [self addTimeStart:@"2014-12-13 05:00:00" end:@"2014-12-13 22:00:00"];
        [self addTimeStart:@"2014-12-14 05:00:00" end:@"2014-12-14 22:00:00"];
        [self addTimeStart:@"2014-12-15 05:00:00" end:@"2014-12-15 22:00:00"];
        [self addTimeStart:@"2014-12-16 05:00:00" end:@"2014-12-16 22:00:00"];
        [self addTimeStart:@"2014-12-17 05:00:00" end:@"2014-12-17 22:00:00"];
        [self addTimeStart:@"2014-12-18 05:00:00" end:@"2014-12-18 22:00:00"];
        [self addTimeStart:@"2014-12-19 05:00:00" end:@"2014-12-20 04:00:00"];
        [self addTimeStart:@"2014-12-20 05:00:00" end:@"2014-12-21 04:00:00"];
        [self addTimeStart:@"2014-12-21 05:00:00" end:@"2014-12-22 04:00:00"];
        [self addTimeStart:@"2014-12-22 05:00:00" end:@"2014-12-23 04:00:00"];
        [self addTimeStart:@"2014-12-23 05:00:00" end:@"2014-12-24 04:00:00"];
        [self addTimeStart:@"2014-12-24 05:00:00" end:@"2014-12-25 04:00:00"];
        [self addTimeStart:@"2014-12-25 05:00:00" end:@"2014-12-26 04:00:00"];
        [self addTimeStart:@"2014-12-26 05:00:00" end:@"2014-12-27 04:00:00"];
        [self addTimeStart:@"2014-12-27 05:00:00" end:@"2014-12-28 04:00:00"];
        [self addTimeStart:@"2014-12-28 05:00:00" end:@"2014-12-29 04:00:00"];
        [self addTimeStart:@"2014-12-29 05:00:00" end:@"2014-12-30 04:00:00"];
        [self addTimeStart:@"2014-12-30 05:00:00" end:@"2015-01-01 04:00:00"];
//        [self addTimeStart:@"2014-12-01 03:50:53" end:@"2014-12-01 04:59:00"];
//        [self addTimeStart:@"2014-12-02 08:50:53" end:@"2014-12-02 20:30:53"];
//        [self addTimeStart:@"2014-12-03 02:50:53" end:@"2014-12-03 04:59:00"];
//        [self addTimeStart:@"2014-12-04 05:50:53" end:@"2014-12-04 20:30:53"];
//        [self addTimeStart:@"2014-12-05 00:50:53" end:@"2014-12-05 03:30:53"];
//        [self addTimeStart:@"2014-12-06 05:50:53" end:@"2014-12-06 20:30:53"];
//        [self addTimeStart:@"2014-12-07 05:00:53" end:@"2014-12-07 20:30:53"];
//        [self addTimeStart:@"2014-12-08 04:50:53" end:@"2014-12-08 04:59:00"];
//        [self addTimeStart:@"2014-05-12 08:50:53" end:@"2014-05-12 20:30:53"];
//        [self addTimeStart:@"2014-05-13 05:00:00" end:@"2014-05-13 18:00:00"];
//        
//        [self addTimeStart:@"2014-03-01 08:50:53" end:@"2014-03-01 20:30:53"];
//        [self addTimeStart:@"2014-03-05 08:50:53" end:@"2014-03-05 20:30:53"];
//        [self addTimeStart:@"2014-03-07 08:50:53" end:@"2014-03-07 20:30:53"];
//        [self addTimeStart:@"2014-03-08 08:50:53" end:@"2014-03-08 20:30:53"];
//        [self addTimeStart:@"2014-03-12 08:50:53" end:@"2014-03-12 20:30:53"];
//        [self addTimeStart:@"2014-03-13 08:50:53" end:@"2014-03-13 20:30:53"];
//        [self addTimeStart:@"2014-03-20 08:50:53" end:@"2014-03-20 20:30:53"];
//        [self addTimeStart:@"2014-03-28 08:50:53" end:@"2014-03-28 20:30:53"];
//        [self addTimeStart:@"2014-03-29 08:50:53" end:@"2014-03-29 20:30:53"];
//        [self addTimeStart:@"2014-03-30 08:50:53" end:@"2014-03-30 20:30:53"];
//        
//        [self addTimeStart:@"2014-01-01 08:50:53" end:@"2014-01-01 20:30:53"];
//        [self addTimeStart:@"2014-01-05 08:50:53" end:@"2014-01-05 20:30:53"];
//        [self addTimeStart:@"2014-01-07 08:50:53" end:@"2014-01-07 20:30:53"];
//        [self addTimeStart:@"2014-01-08 08:50:53" end:@"2014-01-08 20:30:53"];
//        [self addTimeStart:@"2014-01-12 08:50:53" end:@"2014-01-12 20:30:53"];
//        [self addTimeStart:@"2014-01-13 08:50:53" end:@"2014-01-13 20:30:53"];
//        [self addTimeStart:@"2014-01-20 08:50:53" end:@"2014-01-20 20:30:53"];
//        [self addTimeStart:@"2014-01-28 08:50:53" end:@"2014-01-28 20:30:53"];
//        [self addTimeStart:@"2014-01-29 08:50:53" end:@"2014-01-29 20:30:53"];
//        [self addTimeStart:@"2014-01-30 08:50:53" end:@"2014-01-30 20:30:53"];
//        
//        [self addTimeStart:@"2013-12-01 08:50:53" end:@"2013-12-01 20:30:53"];
//        [self addTimeStart:@"2013-12-05 08:50:53" end:@"2013-12-05 20:30:53"];
//        [self addTimeStart:@"2013-12-07 08:50:53" end:@"2013-12-07 20:30:53"];
//        [self addTimeStart:@"2013-12-08 08:50:53" end:@"2013-12-08 20:30:53"];
//        [self addTimeStart:@"2013-12-12 08:50:53" end:@"2013-12-12 20:30:53"];
//        [self addTimeStart:@"2013-12-13 08:50:53" end:@"2013-12-13 20:30:53"];
//        [self addTimeStart:@"2013-12-20 08:50:53" end:@"2013-12-20 20:30:53"];
//        [self addTimeStart:@"2013-12-28 08:50:53" end:@"2013-12-28 20:30:53"];
//        [self addTimeStart:@"2013-12-29 08:50:53" end:@"2013-12-29 20:30:53"];
//        [self addTimeStart:@"2013-12-30 08:50:53" end:@"2013-12-30 20:30:53"];
    }
}

+ (void)addTimeStart:(NSString *)start end:(NSString *)end
{
    Time *time = [[Time alloc] init];
    [time setAid:@"1"];
    [time setStart_date:start];
    [time setStart_modify_date:start];
    [time setEnd_date:end];
    [time setEnd_modify_date:end];
    [time save];
}

+ (Time *)timeFromDate:(NSDate *)date
{
    Time *time = [[Time alloc] init];
    
    time.belong_date = [date localStringWithFormat:DB_DATE_YMD];
    
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
    
    time.belong_year = [NSString stringWithFormat:@"%d", (int)dateComponents.year];
    time.belong_month = [NSString stringWithFormat:@"%d", (int)dateComponents.month];
    time.belong_day = [NSString stringWithFormat:@"%d", (int)dateComponents.day];
    
    [dateComponents setHour:8];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    
    NSDate *startDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    
    [dateComponents setHour:19];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    
    NSDate *endDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    
    [time setAid:@""];
    [time setStart_date:[startDate localStringWithFormat:DB_DATE_YMDHMS]];
    [time setEnd_date:[endDate localStringWithFormat:DB_DATE_YMDHMS]];
    
    double latitude = [[AppManager sharedInstance] testLatitude];
    double longitude = [[AppManager sharedInstance] testLongitude];
    [time setStart_latitude:[NSString stringWithFormat:@"%f", latitude]];
    [time setStart_longitude:[NSString stringWithFormat:@"%f", longitude]];
    [time setEnd_latitude:[NSString stringWithFormat:@"%f", latitude]];
    [time setEnd_longitude:[NSString stringWithFormat:@"%f", longitude]];
    
    NSString *type = [NSString stringWithFormat:@"%d", RecordTypeManualAdd];
    [time setStart_type:type];
    [time setEnd_type:type];
    
    return time;
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
    
    NSDate *startDate = [self.start_date localDateWithFormat:DB_DATE_YMDHMS];
    NSDateComponents *startDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:startDate];
    NSDateComponents *belongDateComponents = nil;
    // Day: 05:00 ~ 29:00
    if (startDateComponents.hour < 5) {
        [startDateComponents setDay:(startDateComponents.day - 1)];
        NSDate *belongDate = [[NSCalendar currentCalendar] dateFromComponents:startDateComponents];
        self.belong_date = [belongDate localStringWithFormat:DB_DATE_YMD];
        
        belongDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:belongDate];
    } else {
        self.belong_date = [startDate localStringWithFormat:DB_DATE_YMD];
        belongDateComponents = startDateComponents;
    }
    self.belong_year = [NSString stringWithFormat:@"%d", (int)belongDateComponents.year];
    self.belong_month = [NSString stringWithFormat:@"%d", (int)belongDateComponents.month];
    self.belong_day = [NSString stringWithFormat:@"%d", (int)belongDateComponents.day];
    
    NSString *end_date = nil;
    Time *currentTime = [[AppManager sharedInstance] currentTime];
    if (self.pid > 0 && self.pid == currentTime.pid && !self.isEnd) {
        end_date = @"";
    } else {
        end_date = self.end_date;
    }
    
    NSString *sql = @"REPLACE INTO time ('pid', 'aid', 'belong_date', 'belong_year', 'belong_month', 'belong_day', 'start_date', 'end_date', 'start_modify_date', 'end_modify_date', 'create_date', 'update_date', 'delete_flag', 'memo_txt', 'start_type', 'end_type', 'start_latitude', 'start_longitude', 'end_latitude', 'end_longitude') VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    result =  [self.dbo executeUpdate:sql, self.pid > 0 ? @(self.pid) : NULL, self.aid, self.belong_date, self.belong_year, self.belong_month, self.belong_day, self.start_date, end_date, self.start_modify_date, self.end_modify_date, self.create_date, self.update_date, self.delete_flag, self.memo_txt, self.start_type, self.end_type, self.start_latitude, self.start_longitude, self.end_latitude, self.end_longitude];
    
    if (NO == result) {
        DLog(@"%@", [self.dbo lastErrorMessage]);
    } else {
        if (self.pid == 0) {
            [self setPid:[self.dbo lastInsertRowId]];
        }
    }
    return result;
}

+ (NSMutableArray *)allTimes
{
    FMDatabase *dbo = [[DBUtils sharedDBUtils] dbo];
    NSString *sql = @"SELECT * FROM time ORDER BY start_date ASC";
    FMResultSet *resultSet = [dbo executeQuery:sql];

    NSMutableArray *timeArray = [NSMutableArray array];
    while (resultSet.next) {
        Time *time = [self timeFromResultSet:resultSet];
        [timeArray addObject:time];
    }
    return timeArray;
}

+ (NSMutableArray *)timesLikeDate:(NSString *)date
{
    FMDatabase *dbo = [[DBUtils sharedDBUtils] dbo];
    NSString *sql = @"SELECT * FROM time WHERE start_date like ? ORDER BY start_date ASC";
    FMResultSet *resultSet = [dbo executeQuery:sql, [NSString stringWithFormat:@"%@%@", date, @"%"]];
    NSMutableArray *timeArray = [NSMutableArray array];
    while (resultSet.next) {
        Time *time = [self timeFromResultSet:resultSet];
        [timeArray addObject:time];
    }
    return timeArray;
}

+ (Time *)timeWithPid:(NSString *)pid
{
    FMDatabase *dbo = [[DBUtils sharedDBUtils] dbo];
    NSString *sql = @"SELECT * FROM time WHERE pid = ?";
    FMResultSet *resultSet = [dbo executeQuery:sql, pid];
    Time *time = nil;
    
    if (resultSet.next) {
        time = [self timeFromResultSet:resultSet];
    }
    return time;
}

+ (Time *)timeFromResultSet:(FMResultSet *)rs
{
    Time *time = [[Time alloc] init];
    time.pid = [rs longLongIntForColumn:@"pid"];
    time.aid = [rs stringForColumn:@"aid"];
    time.belong_date = [rs stringForColumn:@"belong_date"];
    time.belong_year = [rs stringForColumn:@"belong_year"];
    time.belong_month = [rs stringForColumn:@"belong_month"];
    time.belong_day = [rs stringForColumn:@"belong_day"];
    time.start_date = [rs stringForColumn:@"start_date"];
    time.end_date = [rs stringForColumn:@"end_date"];
    time.start_modify_date = [rs stringForColumn:@"start_modify_date"];
    time.end_modify_date = [rs stringForColumn:@"end_modify_date"];
    time.create_date = [rs stringForColumn:@"create_date"];
    time.update_date = [rs stringForColumn:@"update_date"];
    time.delete_flag = [rs stringForColumn:@"delete_flag"];
    time.memo_txt = [rs stringForColumn:@"memo_txt"];
    time.start_type = [rs stringForColumn:@"start_type"];
    time.end_type = [rs stringForColumn:@"end_type"];
    time.start_latitude = [rs stringForColumn:@"start_latitude"];
    time.start_longitude = [rs stringForColumn:@"start_longitude"];
    time.end_latitude = [rs stringForColumn:@"end_latitude"];
    time.end_longitude = [rs stringForColumn:@"end_longitude"];
    return time;
}

+ (NSString *)oldestDate
{
    FMDatabase *dbo = [[DBUtils sharedDBUtils] dbo];
    NSString *sql = @"SELECT MIN(belong_date) min_date FROM time";
    FMResultSet *resultSet = [dbo executeQuery:sql];
    
    NSString *dateStr;
    if (resultSet.next) {
        dateStr = [resultSet stringForColumn:@"min_date"];
    }
    return dateStr;
}

@end
