//
//  SNSReportReason.m
//  Overtime
//
//  Created by Ryuukou on 5/2/15.
//  Copyright (c) 2015年 Bravesoft. All rights reserved.
//

#import "SNSReportReason.h"

@implementation SNSReportReason

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"reasonID" : @"reason_id",
             @"reasonContent" : @"reason_content"};
}

+ (NSValueTransformer *)reasonIDJSONTransformer {
    return [MTLValueTransformer
            transformerUsingForwardBlock:^(NSString *str, BOOL *success, NSError **error) {
                return @(str.integerValue);
            }
            reverseBlock:^(NSNumber *num, BOOL *success, NSError **error) {
                return num.stringValue;
            }];
}

@end
