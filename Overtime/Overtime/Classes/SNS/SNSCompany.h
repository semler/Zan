//
//  SNSCompany.h
//  Overtime
//
//  Created by Ryuukou on 18/2/15.
//  Copyright (c) 2015年 Bravesoft. All rights reserved.
//

#import "MTLModel.h"

@interface SNSCompany : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) NSInteger companyID;
@property (nonatomic, copy) NSString *companyName;
@property (nonatomic, assign) NSInteger groupID;
@property (nonatomic, copy) NSString *groupName;

@end
