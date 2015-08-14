//
//  SNSJob.h
//  Overtime
//
//  Created by Ryuukou on 18/2/15.
//  Copyright (c) 2015年 Bravesoft. All rights reserved.
//

#import "MTLModel.h"

@interface SNSJob : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) NSInteger jobID;
@property (nonatomic, copy) NSString *jobName;

@end
