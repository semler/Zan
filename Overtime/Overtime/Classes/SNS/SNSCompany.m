//
//  SNSCompany.m
//  Overtime
//
//  Created by Ryuukou on 18/2/15.
//  Copyright (c) 2015年 Bravesoft. All rights reserved.
//

#import "SNSCompany.h"

@implementation SNSCompany

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"companyID" : @"company_id",
             @"groupID" : @"group_id",
             @"companyName" : @"company_name",
             @"groupName" : @"group_name"};
}

+ (NSValueTransformer *)companyIDJSONTransformer {
    return [MTLValueTransformer
            transformerUsingForwardBlock:^(NSString *str, BOOL *success, NSError **error) {
                return @(str.integerValue);
            }
            reverseBlock:^(NSNumber *num, BOOL *success, NSError **error) {
                return num.stringValue;
            }];
}

+ (NSValueTransformer *)groupIDJSONTransformer {
    return [MTLValueTransformer
            transformerUsingForwardBlock:^(NSString *str, BOOL *success, NSError **error) {
                return @(str.integerValue);
            }
            reverseBlock:^(NSNumber *num, BOOL *success, NSError **error) {
                return num.stringValue;
            }];
}

@end
