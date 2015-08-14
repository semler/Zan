//
//  LocationManager.h
//  LocationLibrary
//
//  Created by goto on 12/10/01.
//  Copyright (c) 2012 Microtech. All rights reserved.
//

/* Library Version 1.2.0 */

#import <Foundation/Foundation.h>


/* 測位結果 */
enum {
    LocationManagerStatusSuccess    = 0,    /* 測位成功 */
    LocationManagerStatusPending,           /* 測位結果受信待ち */
    LocationManagerStatusError              /* 測位失敗 */
};
typedef NSUInteger LocationManagerStatus;


/* 測位情報クラス */
@interface LocationInfo : NSObject

@property (nonatomic, readonly) NSDate* timeStamp;              /* タイムスタンプ */
@property (nonatomic, readonly) NSString* date;                 /* 測位日付(YYYYMMDD) */
@property (nonatomic, readonly) NSString* time;                 /* 測位時間(HHMMSS) */
@property (nonatomic, readonly) double latitude;                /* 緯度 */
@property (nonatomic, readonly) double longitude;               /* 経度 */
@property (nonatomic, readonly) NSInteger horizontalAccuracy;   /* 測位誤差(m) */
@property (nonatomic, readonly) double altitude;                /* 標高(m) */

@end


/* 測位開始・設定値変更通知の設定値キー */
extern NSString * const MeasuringSettingURLKey;                 /* 位置情報サーバURL (NSString) */
extern NSString * const MeasuringSettingLogAppParamKey;         /* 位置情報サーバログのアプリケーションからのパラメータ (NSString) */
extern NSString * const MeasuringSettingSchemaKey;              /* スキーマ名 (NSString) */
extern NSString * const MeasuringSettingAccuracyKey;            /* 精度 (NSNumber<float>) */
extern NSString * const MeasuringSettingDistanceKey;            /* 位置情報更新最小距離 (NSNumber<float>) */
extern NSString * const MeasuringSettingIntervalKey;            /* 間隔 (NSNumber<float>) */
extern NSString * const MeasuringSettingPermissionKey;          /* 位置情報履歴ログ送信許可 (NSNumber<BOOL>) */
extern NSString * const MeasuringSettingPushMessageDateKey;     /* 通知メッセージの取得対象日時 (NSDate) */
extern NSString * const MeasuringSettingPushMessageKey;         /* 通知メッセージ受信 (NSNumber<BOOL>) */
extern NSString * const MeasuringSettingSettingServerURLKey;    /* 設定値変更サーバURL (NSString) */
/* 13.06.25 add */
extern NSString * const MeasuringSettingAPPIDKey;               /* アプリケーションID (NSString) */
extern NSString * const MeasuringSettingUIDKey;                 /* uid (NSString) */

/* 設定値変更通知の設定値キー */
extern NSString * const ChangeSettingsDateKey;                      /* 日時 (NSDate) */
extern NSString * const ChangeSettingsOperationKey;                 /* 測位開始・停止 (NSNumber<BOOL>) */
extern NSString * const ChangeSettingsBatteryLevIntervalKey;        /* 測位方式変更バッテリ残量 (NSNumber<float>) */
extern NSString * const ChangeSettingsSignificantChangeAccuracyKey; /* 大幅変更位置情報サービス開始精度 (NSNumber<float>) */
extern NSString * const ChangeSettingsLogUploadCountKey;            /* 測位情報蓄積個数 (NSNumber<NSInteger>) */
extern NSString * const ChangeSettingsSamePositionDistanceKey;      /* 同位置判定距離 (NSNumber<float>) */
extern NSString * const ChangeSettingsSamePositionCountKey;         /* 同位置判定回数 (NSNumber<NSInteger>) */

/* 通知メッセージ情報のキー */
extern NSString * const PushMessageDateKey;     /* 日時 (NSDate) */
extern NSString * const PushMessageTextsKey;    /* 通知テキスト (NSArray<NSString>) */
extern NSString * const PushMessageURLsKey;     /* 通知URL (NSArray<NSString>) */
extern NSString * const PushMessageImgURLsKey;  /* 画像URL (NSArray<NSString>) */


/* LocationManagerのデリゲートプロトコル */
@protocol LocationManagerDelegate <NSObject>

@required
/* 測位情報を通知するコールバック関数 */
- (void)measuringResult:(LocationInfo *)locationInfo status:(LocationManagerStatus)status error:(NSError *)error;

@optional
/* PUSH通知メッセージを通知するコールバック関数 */
- (void)pushMessageList:(NSArray *)messageList error:(NSError *)error;
/* 設定値変更を通知するコールバック関数 */
- (void)changeSettings:(NSDictionary *)settings error:(NSError *)error;

@end


/* LocationManagerクラス */
@interface LocationManager : NSObject

@property (nonatomic, retain) id<LocationManagerDelegate> delegate;

/* インスタンス取得 */
+ (LocationManager *)defaultLocationManager;

/* 測位開始 */
- (BOOL)measuringStart:(NSDictionary *)settings;
/* 測位停止 */
- (void)measuringStop;

/* アプリケーションUID */
- (NSString *)applicationUID;
@end

#warning debug library
