//
//  Era.h
//  Overtime
//
//  Created by Xu Shawn on 4/21/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Year.h"
#import "Month.h"
#import "Day.h"

@interface Era : NSObject

@property (nonatomic, copy) NSString *yearOfDate;
@property (nonatomic, assign) double money;
@property (nonatomic, copy) NSString *formattedMoney;
@property (nonatomic, strong) NSMutableDictionary *yearDic;
@property (nonatomic, strong) NSMutableArray *yearArray;
@property (nonatomic, assign) double otHours;

+ (Era *)currentEra;
- (Year *)yearFromDate:(NSDate *)date;
- (Month *)monthFromDate:(NSDate *)date;
- (Day *)dayFromDate:(NSDate *)date;
- (Day *)addNewDay:(Time *)time withDate:(NSDate *)date;
- (void)recalculateData;

@end
