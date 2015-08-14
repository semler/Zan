//
//  Era.m
//  Overtime
//
//  Created by Xu Shawn on 4/21/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "Era.h"

@implementation Era

+ (Era *)currentEra
{
    NSArray *timeArray = [Time allTimes];
    
    NSMutableDictionary *timeDic = [NSMutableDictionary dictionary];
    // Separate times to year
    for (Time *time in timeArray) {
        NSString *year = time.belong_year;
        NSMutableArray *array = timeDic[year];
        if (!array) {
            array = [NSMutableArray array];
            [timeDic setObject:array forKey:year];
        }
        [array addObject:time];
    }
    
    NSMutableDictionary *yearDic = [NSMutableDictionary dictionary];
    NSMutableArray *yearArray = [NSMutableArray array];
    
    double otHours = 0;
    // Year to era
    for (NSInteger i = 2000; i <= 2020; i++) {
        NSString *yearKey = [NSString stringWithFormat:@"%d", (int)i];
        NSMutableArray *timeOfYearArray = timeDic[yearKey];
        if (timeOfYearArray) {
            Year *year = [Year yearFromTimeArray:timeOfYearArray];
            [year setYearOfDate:yearKey];
            [yearDic setObject:year forKey:yearKey];
            [yearArray addObject:year];
            
            otHours += year.otHours;
        }
    }
    Era *era = [[Era alloc] init];
    [era setYearDic:yearDic];
    [era setYearArray:yearArray];
    [era calculateData];
    [era setOtHours:otHours];
    return era;
}

- (void)calculateData
{
    double eraMoney = 0;
    for (Year *year in self.yearArray) {
        eraMoney += year.money;
    }
    [self setMoney:eraMoney];
    NSString *formattedMoney = [AppManager currencyFormat:(NSInteger)eraMoney];
    [self setFormattedMoney:[NSString stringWithFormat:@"￥%@", formattedMoney]];
}

- (void)recalculateData
{
    double eraOTHours = 0;
    for (Year *year in self.yearArray) {
        double yearOTHours = 0;
        for (Month *month in year.monthArray) {
            double monthOTHours = 0;
            for (Day *day in month.dayArray) {
                [day setMonthOTHours:monthOTHours];
                [day calculateData];
                if (![day isWeekendIn]) {
                    monthOTHours += day.otHours;
                }
            }
            [month setOtHours:monthOTHours];
            [month calculateData];
            
            yearOTHours += monthOTHours;
        }
        [year setOtHours:yearOTHours];
        [year calculateData];
        
        eraOTHours += yearOTHours;
    }
    [self setOtHours:eraOTHours];
    [self calculateData];
}

- (Day *)addNewDay:(Time *)time withDate:(NSDate *)date
{
    NSDateComponents *dateComponents = [date logicalDateComponents];
    
    NSString *yearKey = [NSString stringWithFormat:@"%d", (int)dateComponents.year];
    NSString *monthKey = [NSString stringWithFormat:@"%d", (int)dateComponents.month];
    NSString *dayKey = [NSString stringWithFormat:@"%d", (int)dateComponents.day];
    NSMutableArray *timeArray = [NSMutableArray arrayWithObject:time];

    Day *day = nil;
    
    Year *year = [self yearFromDateComponents:dateComponents];
    if (year) {
        Month *month = [self monthFromDateComponents:dateComponents];
        if (month) {
            day = [Day dayFromTimeArray:timeArray otHours:month.otHours];
            [day setDayOfDate:dayKey];
            [month.dayDic setObject:day forKey:dayKey];
            [month.dayArray addObject:day];
        } else {
            day = [Day dayFromTimeArray:timeArray otHours:0];
            [day setDayOfDate:dayKey];
            
            month = [[Month alloc] init];
            [month setMonthOfDate:monthKey];
            [month setDayDic:[NSMutableDictionary dictionaryWithObject:day forKey:dayKey]];
            [month setDayArray:[NSMutableArray arrayWithObject:day]];
            
            [year.monthDic setObject:month forKey:monthKey];
            [year.monthArray addObject:month];
        }
    } else {
        day = [Day dayFromTimeArray:timeArray otHours:0];
        [day setDayOfDate:dayKey];
        
        Month *month = [[Month alloc] init];
        [month setMonthOfDate:monthKey];
        [month setDayDic:[NSMutableDictionary dictionaryWithObject:day forKey:dayKey]];
        [month setDayArray:[NSMutableArray arrayWithObject:day]];
        
        year = [[Year alloc] init];
        [year setYearOfDate:yearKey];
        [year setMonthDic:[NSMutableDictionary dictionaryWithObject:month forKey:monthKey]];
        [year setMonthArray:[NSMutableArray arrayWithObject:month]];
        
        [self.yearDic setObject:year forKey:yearKey];
        [self.yearArray addObject:year];
    }
    return day;
}

- (Year *)yearFromDate:(NSDate *)date
{
    NSDateComponents *dateComponents = [date logicalDateComponents];
    return [self yearFromDateComponents:dateComponents];
}

- (Year *)yearFromDateComponents:(NSDateComponents *)dateComponents
{
    NSString *yearKey = [NSString stringWithFormat:@"%d", (int)dateComponents.year];
    Year *year = [self.yearDic objectForKey:yearKey];
    return year;
}

- (Month *)monthFromDate:(NSDate *)date
{
    NSDateComponents *dateComponents = [date logicalDateComponents];
    return [self monthFromDateComponents:dateComponents];
}

- (Month *)monthFromDateComponents:(NSDateComponents *)dateComponents
{
    NSString *yearKey = [NSString stringWithFormat:@"%d", (int)dateComponents.year];
    Year *year = [self.yearDic objectForKey:yearKey];
    NSString *monthKey = [NSString stringWithFormat:@"%d", (int)dateComponents.month];
    Month *month = [year.monthDic objectForKey:monthKey];
    return month;
}

- (Day *)dayFromDate:(NSDate *)date
{
    NSDateComponents *dateComponents = [date logicalDateComponents];
    return [self dayFromDateComponents:dateComponents];
}

- (Day *)dayFromDateComponents:(NSDateComponents *)dateComponents
{
    NSString *yearKey = [NSString stringWithFormat:@"%d", (int)dateComponents.year];
    Year *year = [self.yearDic objectForKey:yearKey];
    NSString *monthKey = [NSString stringWithFormat:@"%d", (int)dateComponents.month];
    Month *month = [year.monthDic objectForKey:monthKey];
    NSString *dayKey = [NSString stringWithFormat:@"%d", (int)dateComponents.day];
    Day *day = [month.dayDic objectForKey:dayKey];
    return day;
}

@end
