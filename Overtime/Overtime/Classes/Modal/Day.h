//
//  Day.h
//  Overtime
//
//  Created by Xu Shawn on 4/15/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Time.h"

@interface Day : NSObject

@property (nonatomic, copy) NSString *ymdDate;
@property (nonatomic, copy) NSString *dayOfDate;
@property (nonatomic, copy) NSString *start_date;
@property (nonatomic, copy) NSString *end_date;
@property (nonatomic, copy) NSString *start_modify_date;
@property (nonatomic, copy) NSString *end_modify_date;
@property (nonatomic, copy) NSString *memo_txt;
@property (nonatomic, assign) RecordType start_type;
@property (nonatomic, assign) RecordType end_type;
@property (nonatomic, assign) double money;
@property (nonatomic, copy) NSString *formattedMoney;
@property (nonatomic, strong) Time *startTime;
@property (nonatomic, strong) Time *endTime;
@property (nonatomic, strong) NSMutableArray *timeArray;
@property (nonatomic, assign) double monthOTHours;
@property (nonatomic, assign) double workHours;
@property (nonatomic, assign) double otHours;
@property (nonatomic, assign) double midnightHour;
@property (nonatomic, assign) double over60Hours;
@property (nonatomic, assign) BOOL isHoliday;
@property (nonatomic, assign) BOOL isWeekendIn;
@property (nonatomic, assign) double start_latitude;
@property (nonatomic, assign) double start_longitude;
@property (nonatomic, assign) double end_latitude;
@property (nonatomic, assign) double end_longitude;

+ (Day *)dayFromTimeArray:(NSMutableArray *)timeArray otHours:(double)otHours;
- (void)setStart_date:(NSString *)start_date recordType:(RecordType)recordType;
- (void)setEnd_date:(NSString *)end_date recordType:(RecordType)recordType;
- (void)saveAll;
- (void)save;
- (void)calculateData;
- (double)hourFromDate:(NSString *)startDate toDate:(NSString *)endDate restStartDate1:(NSString *)restStart1 restEndDate1:(NSString *)restEnd1 restStartDate2:(NSString *)restStart2 restEndDate2:(NSString *)restEnd2;

@end
