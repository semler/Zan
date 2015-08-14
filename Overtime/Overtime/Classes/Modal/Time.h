//
//  Time.h
//  Overtime
//
//  Created by Xu Shawn on 3/11/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "Modal.h"

@interface Time : Modal

@property (nonatomic, copy) NSString *aid;
@property (nonatomic, copy) NSString *belong_date;
@property (nonatomic, copy) NSString *belong_year;
@property (nonatomic, copy) NSString *belong_month;
@property (nonatomic, copy) NSString *belong_day;
@property (nonatomic, copy) NSString *start_date;
@property (nonatomic, copy) NSString *end_date;
@property (nonatomic, copy) NSString *start_modify_date;
@property (nonatomic, copy) NSString *end_modify_date;
@property (nonatomic, copy) NSString *memo_txt;
@property (nonatomic, copy) NSString *start_type;
@property (nonatomic, copy) NSString *end_type;
@property (nonatomic, assign) NSInteger money;
@property (nonatomic, assign) double workHours;
@property (nonatomic, assign) BOOL isEnd;
@property (nonatomic, copy) NSString *start_latitude;
@property (nonatomic, copy) NSString *start_longitude;
@property (nonatomic, copy) NSString *end_latitude;
@property (nonatomic, copy) NSString *end_longitude;

+ (void)addTempTimes;
+ (Time *)timeWithPid:(NSString *)pid;
+ (NSMutableArray *)allTimes;
+ (NSMutableArray *)timesLikeDate:(NSString *)date;
- (BOOL)save;
+ (NSString *)oldestDate;
+ (Time *)timeFromDate:(NSDate *)date;

@end
