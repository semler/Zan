//
//  SNSFriend.h
//  Overtime
//
//  Created by Ryuukou on 4/2/15.
//  Copyright (c) 2015年 Bravesoft. All rights reserved.
//

#import "MTLModel.h"

@interface SNSFriend : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) NSDate *lastUpdateDate;
@property (nonatomic, assign) NSInteger companyId;
@property (nonatomic, assign) Gender sex;
@property (nonatomic, assign) LevelType level;
@property (nonatomic, copy) NSString *supportCount;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *companyName;
@property (nonatomic, copy) NSString *careerName;
@property (nonatomic, assign) BOOL isSupported;

@end
