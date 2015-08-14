//
//  Day.m
//  Overtime
//
//  Created by Xu Shawn on 4/15/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "Day.h"
#import "Time.h"

@implementation Day

- (NSString *)start_date
{
    return self.startTime.start_date;
}

- (NSString *)end_date
{
    return self.endTime.end_date;
}

- (NSString *)start_modify_date
{
    return self.startTime.start_modify_date;
}

- (NSString *)end_modify_date
{
    return self.endTime.end_modify_date;
}

- (RecordType)start_type
{
    if (self.startTime.start_type.length == 0) {
        return RecordTypeGPS;
    } else {
        return (RecordType)[self.startTime.start_type integerValue];
    }
}

- (RecordType)end_type
{
    if (self.endTime.end_type.length == 0) {
        return RecordTypeGPS;
    } else {
        return (RecordType)[self.endTime.end_type integerValue];
    }
}

- (NSString *)memo_txt
{
    return self.startTime.memo_txt;
}

- (double)start_latitude
{
    return [self.startTime.start_latitude doubleValue];
}

- (double)start_longitude
{
    return [self.startTime.start_longitude doubleValue];
}

- (double)end_latitude
{
    return [self.endTime.end_latitude doubleValue];
}

- (double)end_longitude
{
    return [self.endTime.end_longitude doubleValue];
}

- (void)setStart_date:(NSString *)start_date
{
    [self.startTime setStart_date:start_date];
    
    // Find max and min date
    for (Time *time in self.timeArray) {
        if ([time.start_date compare:start_date] == NSOrderedAscending) {
            [time setStart_date:start_date];
        }
    }
    
    [self setStartTime:nil];
    
    // Find max and min date
    for (Time *time in self.timeArray) {
        // Start date
        if (!self.start_date) {
            [self setStartTime:time];
        } else {
            if ([self.start_date compare:time.start_date] == NSOrderedDescending) {
                [self setStartTime:time];
            }
        }
    }
}

- (void)setStart_date:(NSString *)start_date recordType:(RecordType)recordType
{
    [self.startTime setStart_date:start_date];
    
    NSString *type = [NSString stringWithFormat:@"%d", recordType];
    
    // Find max and min date
    for (Time *time in self.timeArray) {
        if ([time.start_date compare:start_date] == NSOrderedAscending) {
            [time setStart_date:start_date];
        }
        [time setStart_type:type];
        
        if (recordType == RecordTypeManual || recordType == RecordTypeManualAdd) {
            [time setStart_modify_date:[[NSDate date] stringWithFormat:DB_DATE_YMDHMS]];
        }
    }
    
    [self setStartTime:nil];
    
    // Find max and min date
    for (Time *time in self.timeArray) {
        // Start date
        if (!self.start_date) {
            [self setStartTime:time];
        } else {
            if ([self.start_date compare:time.start_date] == NSOrderedDescending) {
                [self setStartTime:time];
            }
        }
    }
}

- (void)setEnd_date:(NSString *)end_date
{
    [self.endTime setEnd_date:end_date];
    
    // Find max and min date
    for (Time *time in self.timeArray) {
        if ([time.end_date compare:end_date] == NSOrderedDescending) {
            [time setEnd_date:end_date];
        }
    }
    
    [self setEndTime:nil];
    
    // Find max and min date
    for (Time *time in self.timeArray) {
        // End date
        if (!self.end_date) {
            [self setEndTime:time];
        } else {
            if ([self.end_date compare:time.end_date] == NSOrderedAscending) {
                [self setEndTime:time];
            }
        }
    }
}

- (void)setEnd_date:(NSString *)end_date recordType:(RecordType)recordType
{
    [self.endTime setEnd_date:end_date];
    
    NSString *type = [NSString stringWithFormat:@"%d", recordType];
    
    // Find max and min date
    for (Time *time in self.timeArray) {
        if ([time.end_date compare:end_date] == NSOrderedDescending) {
            [time setEnd_date:end_date];
        }
        [time setEnd_type:type];
        
        if (recordType == RecordTypeManual || recordType == RecordTypeManualAdd) {
            [time setEnd_modify_date:[[NSDate date] stringWithFormat:DB_DATE_YMDHMS]];
        }
    }
    
    [self setEndTime:nil];
    
    // Find max and min date
    for (Time *time in self.timeArray) {
        // End date
        if (!self.end_date) {
            [self setEndTime:time];
        } else {
            if ([self.end_date compare:time.end_date] == NSOrderedAscending) {
                [self setEndTime:time];
            }
        }
    }
}

- (void)setMemo_txt:(NSString *)memo_txt
{
    for (Time *time in self.timeArray) {
        [time setMemo_txt:memo_txt];
        [time save];
    }
}

+ (Day *)dayFromDate:(NSString *)dayDate
{
    NSMutableArray *timeArray = [Time timesLikeDate:dayDate];

    Day *dayModal = [Day dayFromTimeArray:timeArray otHours:0];
    [dayModal setDayOfDate:dayDate];
    return dayModal;
}

+ (Day *)dayFromTimeArray:(NSMutableArray *)timeArray otHours:(double)otHours
{
    Day *day = [[Day alloc] init];
    [day setMonthOTHours:otHours];
    [day setTimeArray:timeArray];
    [day calculateData];
    return day;
}

- (void)calculateData
{
    NSDictionary *masterDic = [[AppManager sharedInstance] masterDic];
    NSString *restStart1 = masterDic[MSTKeyRestStart1];
    NSString *restEnd1 = masterDic[MSTKeyRestEnd1];
    NSString *restStart2 = masterDic[MSTKeyRestStart2];
    NSString *restEnd2 = masterDic[MSTKeyRestEnd2];
    NSString *workingTimePid = masterDic[MSTKeyCurrentTimeID];
    NSString *belongDate = nil;
    double hourMoney = [masterDic[MSTKeyPaymentHour] doubleValue];
    // Find max and min date
    for (Time *time in self.timeArray) {
        if ([workingTimePid integerValue] == time.pid) {
            [time setEnd_date:[[NSDate date] localStringWithFormat:DB_DATE_YMDHMS]];
        }
        // Start date
        if (!self.start_date) {
            [self setStartTime:time];
        } else {
            if ([self.start_date compare:time.start_date] == NSOrderedDescending) {
                [self setStartTime:time];
            }
        }
        
        // End date
        if (!self.end_date) {
            [self setEndTime:time];
        } else {
            if ([self.end_date compare:time.end_date] == NSOrderedAscending) {
                [self setEndTime:time];
            }
        }
        belongDate = time.belong_date;
    }
    restStart1 = [NSString stringWithFormat:@"%@ %@:00", belongDate, restStart1];
    restEnd1 = [NSString stringWithFormat:@"%@ %@:00", belongDate, restEnd1];
    restStart2 = [NSString stringWithFormat:@"%@ %@:00", belongDate, restStart2];
    restEnd2 = [NSString stringWithFormat:@"%@ %@:00", belongDate, restEnd2];
    
    // Belong to date
    [self setYmdDate:belongDate];
    // Work hour
    double workHours = [self hourFromDate:self.start_date toDate:self.end_date restStartDate1:restStart1 restEndDate1:restEnd1 restStartDate2:restStart2 restEndDate2:restEnd2];
    [self setWorkHours:workHours];
    
    NSDateComponents *belongDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[belongDate localDateWithFormat:DB_DATE_YMD]];
    NSInteger weekday = belongDateComponents.weekday - 1;
    NSString *weekendIn = [[[AppManager sharedInstance] masterDic] objectForKey:MSTKeyWeekendIn];
    NSString *weekendOut = [[[AppManager sharedInstance] masterDic] objectForKey:MSTKeyWeekendOut];
    NSString *midnightDate = [NSString stringWithFormat:@"%@ 22:00:00", belongDate];
    
    if ([midnightDate compare:self.start_date] == NSOrderedAscending) {
        midnightDate = self.start_date;
    }
    // Midnight hours
    double midnightHour = [self hourFromDate:midnightDate toDate:self.end_date restStartDate1:restStart1 restEndDate1:restEnd1 restStartDate2:restStart2 restEndDate2:restEnd2];;
    double otHours = 0;
    double over60Hours = 0;
    
    if ((weekendOut.length > 0 && weekday == [weekendOut integerValue]) || [[[AppManager sharedInstance] holidayArray] containsObject:belongDate]) {
        // 法定外休日労働
        otHours = self.workHours;
        over60Hours = 0;
        // Over 60 hours
        if (self.monthOTHours > 60.0) {
            over60Hours = otHours;
        } else if (self.monthOTHours + otHours > 60.0) {
            over60Hours = self.monthOTHours + otHours - 60.0;
        }
        if (otHours < 0) {
            otHours = 0;
        } else if (otHours > 24.0) {
            otHours = 24.0;
        }
        
        if (over60Hours < 0) {
            over60Hours = 0;
        } else if (over60Hours > 24.0) {
            over60Hours = 0;
        }
        self.money = (otHours * 1.25 + midnightHour * 0.25 + over60Hours * 0.25) * hourMoney;
        self.isHoliday = YES;
        self.isWeekendIn = NO;
    } else if ((weekendIn.length > 0 && weekday == [weekendIn integerValue])) {
        // 法定内休日労働
        otHours = self.workHours;
        over60Hours = 0;
        
        if (otHours < 0) {
            otHours = 0;
        } else if (otHours > 24.0) {
            otHours = 24.0;
        }

        self.money = (otHours * 1.35 + midnightHour * 0.25) * hourMoney;
        self.isHoliday = YES;
        self.isWeekendIn = YES;
    } else {
        // 平日
        otHours = self.workHours - 8.0;
        over60Hours = 0;
        // Over 60 hours
        if (self.monthOTHours > 60.0) {
            over60Hours = otHours;
        } else if (self.monthOTHours + otHours > 60.0) {
            over60Hours = self.monthOTHours + otHours - 60.0;
        }
        if (otHours < 0) {
            otHours = 0;
        } else if (otHours > 24.0) {
            otHours = 24.0;
        }
        
        if (over60Hours < 0) {
            over60Hours = 0;
        } else if (over60Hours > 24.0) {
            over60Hours = 0;
        }
        if (otHours > 0) {
            self.money = (otHours * 1.25 + midnightHour * 0.25 + over60Hours * 0.25) * hourMoney;
        } else {
            self.money = midnightHour * 0.25 * hourMoney;;
        }
        self.isHoliday = NO;
        self.isWeekendIn = NO;
    }
    
    [self setOtHours:otHours];
    [self setMidnightHour:midnightHour];
    [self setOver60Hours:over60Hours];
    
    NSString *formattedMoney = [AppManager currencyFormat:(NSInteger)self.money];
    [self setFormattedMoney:[NSString stringWithFormat:@"￥%@", formattedMoney]];
}

- (double)hourFromDate:(NSString *)startDate toDate:(NSString *)endDate restStartDate1:(NSString *)restStart1 restEndDate1:(NSString *)restEnd1 restStartDate2:(NSString *)restStart2 restEndDate2:(NSString *)restEnd2
{
    // Hour
    NSString *realRestStart1 = nil;
    NSString *realRestEnd1 = nil;
    NSString *realRestStart2 = nil;
    NSString *realRestEnd2 = nil;
    
    if ([restStart1 compare:endDate] == NSOrderedDescending ||
        [restEnd1 compare:startDate] == NSOrderedAscending) {
        // Rest self outside start and end
        
    } else {
        if ([restStart1 compare:startDate] == NSOrderedAscending) {
            realRestStart1 = startDate;
        } else {
            realRestStart1 = restStart1;
        }
        if ([restEnd1 compare:endDate] == NSOrderedDescending) {
            realRestEnd1 = endDate;
        } else {
            realRestEnd1 = restEnd1;
        }
    }
    if ([restStart2 compare:endDate] == NSOrderedDescending ||
        [restEnd2 compare:startDate] == NSOrderedAscending) {
        // Rest self outside start and end
        
    } else {
        if ([restStart2 compare:startDate] == NSOrderedAscending) {
            realRestStart2 = startDate;
        } else {
            realRestStart2 = restStart2;
        }
        if ([restEnd2 compare:endDate] == NSOrderedDescending) {
            realRestEnd2 = endDate;
        } else {
            realRestEnd2 = restEnd2;
        }
    }
    double restHour1 = 0;
    double restHour2 = 0;
    if (realRestStart1.length > 0 && realRestEnd1.length > 0) {
        restHour1 = [realRestStart1 intervalHourToDate:realRestEnd1 withFormat:DB_DATE_YMDHMS];
    }
    if (realRestStart2.length > 0 && realRestEnd2.length > 0) {
        restHour2 = [realRestStart2 intervalHourToDate:realRestEnd2 withFormat:DB_DATE_YMDHMS];
    }
    if (restHour1 < 0) {
        restHour1 = 0;
    }
    if (restHour2 < 0) {
        restHour2 = 0;
    }
    
    double hours = [startDate intervalHourToDate:endDate withFormat:DB_DATE_YMDHMS];
    double workHours = hours - restHour1 - restHour2;
    if (workHours < 0) {
        workHours = 0;
    } else if (workHours > 24.0) {
        workHours = 24.0;
    }
    workHours = (round(workHours * 1000.0)) / 1000.0;
    return workHours;
}

- (void)saveAll
{
    for (Time *time in self.timeArray) {
        [time save];
    }
}

- (void)save
{
    if (self.startTime != self.endTime) {
        [self.startTime save];
        [self.endTime save];
    } else {
        [self.startTime save];
    }
}

@end
