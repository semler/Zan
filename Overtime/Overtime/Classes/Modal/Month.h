//
//  Month.h
//  Overtime
//
//  Created by Xu Shawn on 4/16/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Month : NSObject

@property (nonatomic, copy) NSString *monthOfDate;
@property (nonatomic, assign) double money;
@property (nonatomic, copy) NSString *formattedMoney;
@property (nonatomic, strong) NSMutableDictionary *dayDic;
@property (nonatomic, strong) NSMutableArray *dayArray;
@property (nonatomic, assign) double otHours;

+ (Month *)monthFromDate:(NSString *)monthDate;
+ (Month *)monthFromTimeArray:(NSArray *)timeArray;
- (void)calculateData;

@end
