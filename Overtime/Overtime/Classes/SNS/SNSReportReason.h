//
//  SNSReportReason.h
//  Overtime
//
//  Created by Ryuukou on 5/2/15.
//  Copyright (c) 2015年 Bravesoft. All rights reserved.
//

#import "MTLModel.h"

@interface SNSReportReason : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) NSInteger reasonID;
@property (nonatomic, copy) NSString *reasonContent;

@end
