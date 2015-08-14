//
//  Year.m
//  Overtime
//
//  Created by Xu Shawn on 4/16/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "Year.h"
#import "Month.h"

@implementation Year

+ (Year *)yearFromDate:(NSInteger)yearDate
{
    // Year
    NSString *yearOfDate = [NSString stringWithFormat:@"%d", (int)yearDate];
    // Data source
    NSArray *timeArray = [Time timesLikeDate:yearOfDate];
    
    Year *yearModal = [Year yearFromTimeArray:timeArray];
    [yearModal setYearOfDate:yearOfDate];
    return yearModal;
}

+ (Year *)yearFromTimeArray:(NSArray *)timeArray
{
    NSMutableDictionary *timeDic = [NSMutableDictionary dictionary];
    // Separate times to month
    for (Time *time in timeArray) {
        NSString *month = time.belong_month;
        NSMutableArray *array = timeDic[month];
        if (!array) {
            array = [NSMutableArray array];
            [timeDic setObject:array forKey:month];
        }
        [array addObject:time];
    }
    
    NSMutableDictionary *monthDic = [NSMutableDictionary dictionary];
    NSMutableArray *monthArray = [NSMutableArray array];
    
    double otHours = 0;
    // Month to year
    for (NSInteger i = 1; i <= 12; i++) {
        NSString *monthKey = [NSString stringWithFormat:@"%d", (int)i];
        NSMutableArray *timeOfMonthArray = timeDic[monthKey];
        if (timeOfMonthArray) {
            Month *month = [Month monthFromTimeArray:timeOfMonthArray];
            [month setMonthOfDate:monthKey];
            [monthDic setObject:month forKey:monthKey];
            [monthArray addObject:month];
            
            otHours += month.otHours;
        }
    }
    Year *year = [[Year alloc] init];
    [year setMonthDic:monthDic];
    [year setMonthArray:monthArray];
    [year calculateData];
    [year setOtHours:otHours];
    return year;
}

- (void)calculateData
{
    double yearMoney = 0;
    for (Month *month in self.monthArray) {
        yearMoney += month.money;
    }
    [self setMoney:yearMoney];
    NSString *formattedMoney = [AppManager currencyFormat:(NSInteger)yearMoney];
    [self setFormattedMoney:[NSString stringWithFormat:@"￥%@", formattedMoney]];
}

@end
