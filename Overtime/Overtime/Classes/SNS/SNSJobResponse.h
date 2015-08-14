//
//  SNSJobResponse.h
//  Overtime
//
//  Created by Ryuukou on 18/2/15.
//  Copyright (c) 2015年 Bravesoft. All rights reserved.
//

#import "MTLModel.h"
#import "SNSJob.h"

@interface SNSJobResponse : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) ErrorCode error;
@property (nonatomic, copy) NSString *errorMessage;
@property (nonatomic, strong) NSArray *jobs;

@end
