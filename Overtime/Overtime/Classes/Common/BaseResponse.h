//
//  BaseResponse.h
//  Overtime
//
//  Created by Ryuukou on 5/2/15.
//  Copyright (c) 2015年 Bravesoft. All rights reserved.
//

#import "MTLModel.h"

@interface BaseResponse : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) ErrorCode error;
@property (nonatomic, copy) NSString *errorMessage;

@end
