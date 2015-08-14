//
//  SNSResponse.h
//  Overtime
//
//  Created by Ryuukou on 4/2/15.
//  Copyright (c) 2015年 Bravesoft. All rights reserved.
//

#import "MTLModel.h"

@class SNSSelf;
@interface SNSResponse : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) ErrorCode error;
@property (nonatomic, copy) NSString *errorMessage;
@property (nonatomic, strong) SNSSelf *myProfile;
@property (nonatomic, strong) NSArray *friends;

@end
