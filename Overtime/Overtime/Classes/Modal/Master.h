//
//  Master.h
//  Overtime
//
//  Created by Xu Shawn on 3/11/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "Modal.h"

extern NSString * const MSTKeyUUID;
extern NSString * const MSTKeyVersion;
extern NSString * const MSTKeyAppVersion;
extern NSString * const MSTKeyRestStart1;
extern NSString * const MSTKeyRestEnd1;
extern NSString * const MSTKeyRestStart2;
extern NSString * const MSTKeyRestEnd2;
extern NSString * const MSTKeyHoliday;
extern NSString * const MSTKeyWeekday;
extern NSString * const MSTKeyPaymentHour;
extern NSString * const MSTKeyPaymentMonth;
extern NSString * const MSTKeyInOutlv;
extern NSString * const MSTKeyInOutfnum;
extern NSString * const MSTKeyInOutftim;
extern NSString * const MSTKeyWorkOn;
extern NSString * const MSTKeyWorkOff;
extern NSString * const MSTKeyOvertimeOn;
extern NSString * const MSTKeyOvertimeOff;
extern NSString * const MSTKeyChargeReach;
extern NSString * const MSTKeyChargeAmount;
extern NSString * const MSTKeyNextChargeAmount;
extern NSString * const MSTKeyLastConfirm;
extern NSString * const MSTKeyConfirmTime;
extern NSString * const MSTKeyConfirmWeek;
extern NSString * const MSTKeyWeekendIn;
extern NSString * const MSTKeyWeekendOut;
extern NSString * const MSTKeyCurrentTimeID;
extern NSString * const MSTKeyPushMsgType;
extern NSString * const MSTKeyHomeMsgType;
extern NSString * const MSTKeyOldUser;
extern NSString * const MSTKeyUserLogined;
extern NSString * const MSTKeyMaxDate;
extern NSString * const MSTKeyHeldDays;
extern NSString * const MSTKeyFirstLaunch;
extern NSString * const MSTKeyMurMurCount;
extern NSString * const MSTKeyLastMurMurDate;
extern NSString * const MSTKeyGender;
extern NSString * const MSTKeyMessage;
extern NSString * const MSTKeyCareer;
extern NSString * const MSTKeyCompany;
extern NSString * const MSTKeyGenderID;
extern NSString * const MSTKeyCareerID;
extern NSString * const MSTKeyCompanyID;
extern NSString * const MSTKeyInvited;
extern NSString * const MSTKeyKyaraNewHidden;
extern NSString * const MSTKeyKyaraID;

@interface Master : Modal

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *value;

+ (BOOL)saveValue:(NSString *)value forKey:(NSString *)key;
+ (NSString *)valueForKey:(NSString *)key;
+ (NSString *)restTime1;
+ (NSString *)restTime2;
+ (NSString *)weekFromIndex:(NSString *)weekIndex;
+ (NSString *)formattedMoney:(NSString *)money;
+ (NSMutableDictionary *)allMaster;

@end
