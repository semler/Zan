//
//  BaseResponse.m
//  Overtime
//
//  Created by Ryuukou on 5/2/15.
//  Copyright (c) 2015年 Bravesoft. All rights reserved.
//

#import "BaseResponse.h"

@implementation BaseResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"error" : @"error",
             @"errorMessage" : @"error_message"
             };
}

+ (NSValueTransformer *)errorJSONTransformer
{
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{@"200": @(ErrorNone),
                                                                           @"410": @(ErrorUUIDNotFound),
                                                                           @"411": @(ErrorCompanyIDNotFound),
                                                                           @"412": @(ErrorMessageUpdateTooMuch),
                                                                           @"413": @(ErrorSupportTooMuch),
                                                                           @"414": @(ErrorUserIDNotFound),
                                                                           @"415": @(ErrorTaskIDNotFound),
                                                                           @"416": @(ErrorGenderNotFound),
                                                                           @"417": @(ErrorMessageNotFound),
                                                                           @"418": @(ErrorJobIDNotFound),
                                                                           @"419": @(ErrorMessageLengthTooLong),
                                                                           @"420": @(ErrorInviteCodeNotFound),
                                                                           @"421": @(ErrorBlockedUserIDNotFound),
                                                                           @"422": @(ErrorLevelNotFound),
                                                                           @"421": @(ErrorSupportSelf),
                                                                           @"422": @(ErrorAlreadySupported),
                                                                           @"423": @(ErrorTaskAlreadCompleted),
                                                                           @"424": @(ErrorInviteSelf),
                                                                           @"425": @(ErrorReportUserIDNotFound),
                                                                           @"426": @(ErrorReportReason),
                                                                           @"427": @(ErrorAlreadyBlocked),
                                                                           @"428": @(ErrorTaskNotFound)
                                                                           }
                                                            defaultValue:@(ErrorUnknown)
                                                     reverseDefaultValue:@"-1"];
}

@end
