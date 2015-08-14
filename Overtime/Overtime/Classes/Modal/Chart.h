//
//  Chart.h
//  Overtime
//
//  Created by Xu Shawn on 4/14/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Chart : NSObject

@property (nonatomic, assign) double money;
@property (nonatomic, copy) NSString *formattedMoney;
@property (nonatomic, copy) NSString *key;

@end
