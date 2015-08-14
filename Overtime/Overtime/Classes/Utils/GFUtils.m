//
//  GFUtils.m
//  Overtime
//
//  Created by xuxiaoteng on 1/15/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import "GFUtils.h"
#import "GeoFenceManager.h"

@implementation GFUtils

+ (BOOL)configGeoFence:(NSArray *)areaArray
{
    BOOL ret = NO;
    ret = [self setParameter];
    
    for (Area *area in areaArray) {
        Notification *notificationIn = [area notificationIn];
        if (ret && ![notificationIn.send_flag isEqualToString:@"1"]) {
            ret = [self addNotification:notificationIn];
            [notificationIn setSend_flag:@"1"];
            [notificationIn save];
        }
        Notification *notificationOut = [area notificationOut];
        if (ret && ![notificationOut.send_flag isEqualToString:@"1"]) {
            ret = [self addNotification:notificationOut];
            [notificationOut setSend_flag:@"1"];
            [notificationOut save];
        }
        if (ret && ![area.send_flag isEqualToString:@"1"]) {
            ret = [self addAreaInfo:area];
            [area setSend_flag:@"1"];
            [area save];
        }
        if (!ret) {
            break;
        }
    }
    return ret;
}

+ (void)deleteGeoFenceConfig:(NSArray *)areaArray
{
    for (Area *area in areaArray) {
        NSInteger nidIn = [area.notificationIn.nid integerValue];
        NSInteger nidOut = [area.notificationOut.nid integerValue];
        NSArray *nidArray = [[GeoFenceManager defaultManager] removeNotificationConditionInformation:@[@(nidIn), @(nidOut)]];
        NSLog(@"DEL notification: %@", nidArray);
        NSArray *aidArray = [[GeoFenceManager defaultManager] removeAreaInformation:@[area.aid]];
        NSLog(@"DEL area: %@", aidArray);
    }
}

/* アプリから通知条件, エリア情報を指定する場合のサンプル */
+ (BOOL)setParameter
{
    BOOL ret = NO;
    GeoFenceManager *manager = [GeoFenceManager defaultManager];
    GeoFenceManagerSetParamResult result = [manager setParams:nil
                                                operationMode:kGFlGeoFenceManagerOperationMode_Manual];
    
    if ( result == kGFlGeoFenceManagerSetParamSuccess ) {
        /* 設定成功 */
        DLog(@"Set param success");
        ret = YES;
    } else {
        /* 設定失敗 */
        DLog(@"Set param failed");
        ret = NO;
    }
    return ret;
}

+ (BOOL)addNotification:(Notification *)notification
{
    BOOL ret = NO;
    // 通知開始日を指定する
    NSDate *nsvd = [@"201401010000" localDateWithFormat:@"yyyyMMddHHmm"];
    // 通知終了日を指定する
    NSDate *nevd = [@"202012312359" localDateWithFormat:@"yyyyMMddHHmm"];
    // セットするKeyと値
    NSDictionary *info = @{
                           GFlResponseKeyNid:@([notification.nid integerValue]),
                           GFlResponseKeyAid:notification.aid,
                           // 通知タイミング 1:IN 2:OUT
                           GFlResponseKeyNtmg:@([notification.inout_flag integerValue]),
                           GFlResponseKeyNwk:@"1,2,3,4,5,6,0",
                           GFlResponseKeyNstm:@"0000",
                           GFlResponseKeyNetm:@"2359",
                           GFlResponseKeyNsvd:nsvd,
                           GFlResponseKeyNevd:nevd,
                           GFlResponseKeyNotnd:@(0),
                           };
    DLog(@"Notification Param: %@", info);
    GeoFenceManager *manager = [GeoFenceManager defaultManager];
    
    NSArray *array = [manager addNotificationConditionInformation:@[info]];
    if ( array.count == 0 ) {
        // 追加通知条件成功
        DLog(@"Add notification success");
        DLog(@"Notification: %@", array);
        ret = YES;
    } else {
        // 追加通知条件失敗
        NSString *message = @"追加通知条件失敗";
        DLog(@"Add notification failed");
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"設定"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];;
        [alertView show];
        ret = NO;
    }
    return ret;
}

+ (BOOL)addAreaInfo:(Area *)area
{
    BOOL ret = NO;
    // エリアの有効期間(開始)を指定する
    NSDate *vst = [@"201401010000" localDateWithFormat:@"yyyyMMddHHmm"];
    // エリアの有効期間(終了)を指定する
    NSDate *vet = [@"202012312359" localDateWithFormat:@"yyyyMMddHHmm"];
    // Master data
    NSDictionary *masterDic = [[AppManager sharedInstance] masterDic];
    // セットするKeyと値
    NSDictionary *info = @{
                           GFlResponseKeyAid:area.aid,
                           GFlResponseKeyLat:@([area.latitude doubleValue]),
                           GFlResponseKeyLon:@([area.longitude doubleValue]),
                           GFlResponseKeyRad:@([area.radius integerValue]),
                           GFlResponseKeyMsg:area.name,
                           GFlResponseKeyInlv:@([masterDic[MSTKeyInOutlv] integerValue]),
                           GFlResponseKeyInfnum:@([masterDic[MSTKeyInOutfnum] integerValue]),
                           GFlResponseKeyInftim:@([masterDic[MSTKeyInOutftim] integerValue]),
                           //                           GFlResponseKeyInmitim:@(1),
                           GFlResponseKeyOutlv:@([masterDic[MSTKeyInOutlv] integerValue]),
                           GFlResponseKeyOutfnum:@(4),
                           GFlResponseKeyOutftim:@([masterDic[MSTKeyInOutftim] integerValue]),
                           //                           GFlResponseKeyOutmitim:@(1),
                           GFlResponseKeyVst:vst,
                           GFlResponseKeyVet:vet,
                           GFlResponseKeyTout:@(300),
                           };
    DLog(@"Area Param: %@", info);
    NSArray *array = [[GeoFenceManager defaultManager] addAreaInformation:@[info]];
    if ( array.count == 0 ) {
        // 追加エリア成功
        DLog(@"Add area success");
        DLog(@"Area: %@", array);
        ret = YES;
    } else {
        // 追加エリア失敗
        NSString *message = @"追加エリア失敗";
        DLog(@"Add area failed");
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"設定"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];;
        [alertView show];
        ret = NO;
    }
    return ret;
}

@end
