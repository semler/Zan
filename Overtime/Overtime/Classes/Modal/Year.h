//
//  Year.h
//  Overtime
//
//  Created by Xu Shawn on 4/16/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Year : NSObject

@property (nonatomic, copy) NSString *yearOfDate;
@property (nonatomic, assign) double money;
@property (nonatomic, copy) NSString *formattedMoney;
@property (nonatomic, strong) NSMutableDictionary *monthDic;
@property (nonatomic, strong) NSMutableArray *monthArray;
@property (nonatomic, assign) double otHours;

+ (Year *)yearFromDate:(NSInteger)yearDate;
+ (Year *)yearFromTimeArray:(NSArray *)timeArray;
- (void)calculateData;

@end
