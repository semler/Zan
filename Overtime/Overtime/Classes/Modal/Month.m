//
//  Month.m
//  Overtime
//
//  Created by Xu Shawn on 4/16/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "Month.h"
#import "Day.h"

@implementation Month

+ (Month *)monthFromDate:(NSString *)monthDate
{
    NSArray *timeArray = [Time timesLikeDate:monthDate];
    
    Month *monthModal = [Month monthFromTimeArray:timeArray];
    [monthModal setMonthOfDate:monthDate];
    return monthModal;
}

+ (Month *)monthFromTimeArray:(NSArray *)timeArray
{
    NSMutableDictionary *timeDic = [NSMutableDictionary dictionary];
    // Separate times to month
    for (Time *time in timeArray) {
        NSString *day = time.belong_day;
        NSMutableArray *array = [timeDic objectForKey:day];
        if (!array) {
            array = [NSMutableArray array];
            [timeDic setObject:array forKey:day];
        }
        [array addObject:time];
    }
    
    Month *month = [[Month alloc] init];
    
    NSMutableDictionary *dayDic = [NSMutableDictionary dictionary];
    NSMutableArray *dayArray = [NSMutableArray array];
    
    // Day to month
    for (NSInteger i = 1; i <= 31; i++) {
        NSString *dayKey = [NSString stringWithFormat:@"%d", (int)i];
        NSMutableArray *timeOfDayArray = timeDic[dayKey];
        if (timeOfDayArray) {
            Day *day = [Day dayFromTimeArray:timeOfDayArray otHours:month.otHours];
            [day setDayOfDate:dayKey];
            // Save current total hours
            if (![day isWeekendIn]) {
                [month setOtHours:(month.otHours + day.otHours)];
            }
            [dayDic setObject:day forKey:dayKey];
            [dayArray addObject:day];
        }
    }
    
    [month setDayDic:dayDic];
    [month setDayArray:dayArray];
    [month calculateData];
    return month;
}

- (void)calculateData
{
    double monthMoney = 0;
    for (Day *day in self.dayArray) {
        monthMoney += day.money;
    }
    [self setMoney:monthMoney];
    NSString *formattedMoney = [AppManager currencyFormat:(NSInteger)monthMoney];
    [self setFormattedMoney:[NSString stringWithFormat:@"￥%@", formattedMoney]];
}

@end
