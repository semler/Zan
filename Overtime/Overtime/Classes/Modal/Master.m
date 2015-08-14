//
//  Master.m
//  Overtime
//
//  Created by Xu Shawn on 3/11/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "Master.h"

NSString * const MSTKeyUUID = @"MSTKeyUUID";
NSString * const MSTKeyVersion = @"MSTKeyVersion";
NSString * const MSTKeyAppVersion = @"MSTKeyAppVersion";
NSString * const MSTKeyRestStart1 = @"MSTKeyRestStart1";
NSString * const MSTKeyRestEnd1 = @"MSTKeyRestEnd1";
NSString * const MSTKeyRestStart2 = @"MSTKeyRestStart2";
NSString * const MSTKeyRestEnd2 = @"MSTKeyRestEnd2";
NSString * const MSTKeyHoliday = @"MSTKeyHoliday";
NSString * const MSTKeyWeekday = @"MSTKeyWeekday";
NSString * const MSTKeyPaymentHour = @"MSTKeyPaymentHour";
NSString * const MSTKeyPaymentMonth = @"MSTKeyPaymentMonth";
NSString * const MSTKeyInOutlv = @"MSTKeyInOutlv";
NSString * const MSTKeyInOutfnum = @"MSTKeyInOutfnum";
NSString * const MSTKeyInOutftim = @"MSTKeyInOutftim";
NSString * const MSTKeyWorkOn = @"MSTKeyWorkOn";
NSString * const MSTKeyWorkOff = @"MSTKeyWorkOff";
NSString * const MSTKeyOvertimeOn = @"MSTKeyOvertimeOn";
NSString * const MSTKeyOvertimeOff = @"MSTKeyOvertimeOff";
NSString * const MSTKeyChargeReach = @"MSTKeyChargeReach";
NSString * const MSTKeyChargeAmount = @"MSTKeyChargeAmount";
NSString * const MSTKeyNextChargeAmount = @"MSTKeyNextChargeAmount";
NSString * const MSTKeyLastConfirm = @"MSTKeyLastConfirm";
NSString * const MSTKeyConfirmTime = @"MSTKeyConfirmTime";
NSString * const MSTKeyConfirmWeek = @"MSTKeyConfirmWeek";
NSString * const MSTKeyWeekendIn = @"MSTKeyWeekendIn";
NSString * const MSTKeyWeekendOut = @"MSTKeyWeekendOut";
NSString * const MSTKeyCurrentTimeID = @"MSTKeyCurrentTimeID";
NSString * const MSTKeyPushMsgType = @"MSTKeyPushMsgType";
NSString * const MSTKeyHomeMsgType = @"MSTKeyHomeMsgType";
NSString * const MSTKeyOldUser = @"MSTKeyOldUser";
NSString * const MSTKeyUserLogined = @"MSTKeyUserLogined";
NSString * const MSTKeyMaxDate = @"MSTKeyMaxDate";
NSString * const MSTKeyHeldDays = @"MSTKeyHeldDays";
NSString * const MSTKeyFirstLaunch = @"MSTKeyFirstLaunch";
NSString * const MSTKeyMurMurCount = @"MSTKeyMurMurCount";
NSString * const MSTKeyLastMurMurDate = @"MSTKeyLastMurMurDate";
NSString * const MSTKeyGender = @"MSTKeyGender";
NSString * const MSTKeyMessage = @"MSTKeyMessage";
NSString * const MSTKeyCareer = @"MSTKeyCareer";
NSString * const MSTKeyCompany = @"MSTKeyCompany";
NSString * const MSTKeyGenderID = @"MSTKeyGenderID";
NSString * const MSTKeyCareerID = @"MSTKeyCareerID";
NSString * const MSTKeyCompanyID = @"MSTKeyCompanyID";
NSString * const MSTKeyInvited = @"MSTKeyInvited";
NSString * const MSTKeyKyaraNewHidden = @"MSTKeyKyaraNewHidden";
NSString * const MSTKeyKyaraID = @"MSTKeyKyaraID";

@implementation Master

- (id)init
{
    self = [super init];
    if (self) {
        _key = @"";
        _value = @"";
    }
    return self;
}

- (BOOL)save
{
    BOOL result = NO;
    
    if (self.create_date.length > 0) {
        [self setUpdate_date:[[NSDate date] localStringWithFormat:DB_DATE_YMDHMS]];
    } else {
        [self setCreate_date:[[NSDate date] localStringWithFormat:DB_DATE_YMDHMS]];
        [self setUpdate_date:self.create_date];
    }
    
    NSString *sql = @"REPLACE INTO master ('key', 'value', 'create_date', 'update_date', 'delete_flag') VALUES (?, ?, ?, ?, ?)";
    result =  [self.dbo executeUpdate:sql, self.key, self.value, self.create_date, self.update_date, self.delete_flag];
    
    if (NO == result) {
        DLog(@"%@", [self.dbo lastErrorMessage]);
    }
    
    NSMutableDictionary *masterDic = [[AppManager sharedInstance] masterDic];
    [masterDic setObject:self.value forKey:self.key];
    
    return result;
}

+ (NSString *)restTime1
{
    // Master data
    NSDictionary *masterDic = [[AppManager sharedInstance] masterDic];
    NSString *startTime = masterDic[MSTKeyRestStart1];
    NSString *endTime = masterDic[MSTKeyRestEnd1];
    if (startTime.length > 0 && endTime.length > 0) {
        return [NSString stringWithFormat:@"%@~%@", startTime, endTime];
    } else {
        return @"-";
    }
}

+ (NSString *)restTime2
{
    // Master data
    NSDictionary *masterDic = [[AppManager sharedInstance] masterDic];
    NSString *startTime = masterDic[MSTKeyRestStart2];
    NSString *endTime = masterDic[MSTKeyRestEnd2];
    if (startTime.length > 0 && endTime.length > 0) {
        return [NSString stringWithFormat:@"%@~%@", startTime, endTime];
    } else {
        return @"-";
    }
}

+ (NSString *)weekFromIndex:(NSString *)weekIndex
{
    NSArray *weekIndexArray = [weekIndex componentsSeparatedByString:@","];
    NSMutableString *weekString = [NSMutableString string];
    for (NSString *week in weekIndexArray) {
        [weekString appendFormat:@"%@•", [AppManager weekTextAtIndex:[week integerValue]]];
    }
    if (weekString.length > 0) {
        [weekString deleteCharactersInRange:NSMakeRange(weekString.length - 1, 1)];
    } else {
        [weekString appendString:@"-"];
    }
    return weekString;
}

+ (NSString *)formattedMoney:(NSString *)money
{
    NSString *formattedMoney = [AppManager currencyFormat:[money doubleValue]];
    if (formattedMoney.length > 0) {
        return [NSString stringWithFormat:@"%@円", formattedMoney];
    } else {
        return @"-";
    }
}

+ (NSMutableDictionary *)allMaster
{
    FMDatabase *dbo = [[DBUtils sharedDBUtils] dbo];
    NSString *sql = @"SELECT * FROM master";
    FMResultSet *resultSet = [dbo executeQuery:sql];
    
    NSMutableDictionary *masterDic = [NSMutableDictionary dictionary];
    while (resultSet.next) {
        Master *master = [self masterFromResultSet:resultSet];
        [masterDic setObject:master.value forKey:master.key];
    }
    return masterDic;
}

+ (BOOL)saveValue:(NSString *)value forKey:(NSString *)key
{
    Master *master = [[Master alloc] init];
    [master setKey:key];
    
    if (value.length > 0) {
        [master setValue:value];
    } else {
        [master setValue:@""];
    }
    return [master save];
}

+ (NSString *)valueForKey:(NSString *)key
{
    FMDatabase *dbo = [[DBUtils sharedDBUtils] dbo];
    NSString *sql = @"SELECT * FROM master WHERE key = ?";
    FMResultSet *resultSet = [dbo executeQuery:sql, key];
    Master *master = nil;
    
    if (resultSet.next) {
        master = [self masterFromResultSet:resultSet];
    }
    return master.value;
}

+ (Master *)masterFromResultSet:(FMResultSet *)rs
{
    Master *master = [[Master alloc] init];
    
    master.key = [rs stringForColumn:@"key"];
    master.value = [rs stringForColumn:@"value"];
    master.create_date = [rs stringForColumn:@"create_date"];
    master.update_date = [rs stringForColumn:@"update_date"];
    master.delete_flag = [rs stringForColumn:@"delete_flag"];

    return master;
}

@end
