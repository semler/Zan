//
//  SNSSelf.m
//  Overtime
//
//  Created by Ryuukou on 4/2/15.
//  Copyright (c) 2015年 Bravesoft. All rights reserved.
//

#import "SNSSelf.h"

@implementation SNSSelf

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"message" : @"message",
             @"lastUpdateDate" : @"message_last_updated",
             @"companyId" : @"company_id",
             @"sex" : @"sex",
             @"level" : @"level",
             @"supportCount" : @"like_num",
             @"companyName" : @"company_name",
             @"edited" : @"edited"};
}

+ (NSValueTransformer *)companyIdJSONTransformer {
    return [MTLValueTransformer
            transformerUsingForwardBlock:^(NSString *str, BOOL *success, NSError **error) {
                return @(str.integerValue);
            }
            reverseBlock:^(NSNumber *num, BOOL *success, NSError **error) {
                return num.stringValue;
            }];
}

+ (NSDateFormatter *)stringToDateFormatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    return dateFormatter;
}

+ (NSDateFormatter *)dateToStringFormatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"HH:mm";
    return dateFormatter;
}

+ (NSValueTransformer *)lastUpdateDateJSONTransformer
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *str, BOOL *success, NSError *__autoreleasing *error) {
        return [self.stringToDateFormatter dateFromString:str];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateToStringFormatter stringFromDate:date];
    }];
}

+ (NSValueTransformer *)sexJSONTransformer
{
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{@"1": @(Male),
                                                                           @"2": @(Female)}
                                                            defaultValue:@(Male)
                                                     reverseDefaultValue:@"1"];
}

+ (NSValueTransformer *)levelJSONTransformer
{
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{@"0": @(LevelTypeNone),
                                                                           @"1": @(LevelTypeGray),
                                                                           @"2": @(LevelTypeBlue),
                                                                           @"3": @(LevelTypeGreen),
                                                                           @"4": @(LevelTypeOrange),
                                                                           @"5": @(LevelTypeRed)
                                                                           }
                                                            defaultValue:@(LevelTypeNone)
                                                     reverseDefaultValue:@"0"];
}

+ (NSValueTransformer *)editedJSONTransformer
{
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
                                                                           @"1": @(YES),
                                                                           @"0": @(NO)
                                                                           }];
}

@end
