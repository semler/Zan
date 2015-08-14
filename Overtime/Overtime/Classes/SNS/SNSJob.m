//
//  SNSJob.m
//  Overtime
//
//  Created by Ryuukou on 18/2/15.
//  Copyright (c) 2015年 Bravesoft. All rights reserved.
//

#import "SNSJob.h"

@implementation SNSJob

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"jobID" : @"job_id",
             @"jobName" : @"job_name"};
}

+ (NSValueTransformer *)jobIDJSONTransformer {
    return [MTLValueTransformer
            transformerUsingForwardBlock:^(NSString *str, BOOL *success, NSError **error) {
                return @(str.integerValue);
            }
            reverseBlock:^(NSNumber *num, BOOL *success, NSError **error) {
                return num.stringValue;
            }];
}

@end
