//
//  Config.h
//  ExileTribeMile
//
//  Created by Xu Shawn on 2/2/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#ifndef ExileTribeMile_Config_h
#define ExileTribeMile_Config_h

#define __FILE_FNAME_ONLY__ (strrchr(__FILE__,'/')+1)

#ifdef DEBUG
#  define DLog(fmt, ...) NSLog([@"%s(%d):%s " stringByAppendingString:(fmt)], __FILE_FNAME_ONLY__,__LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__);
#  define LOG_CURRENT_METHOD NSLog(@"%@/%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#else
//#  define DLog(fmt, ...) NSLog([@"%s(%d):%s " stringByAppendingString:(fmt)], __FILE_FNAME_ONLY__,__LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__);
//#  define LOG_CURRENT_METHOD NSLog(@"%@/%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#  define DLog(...) ;
#  define LOG_CURRENT_METHOD ;
#endif

// Debug mode
#define DEBUG_MODE NO

// Test
#define BASE_URL @"http://orezan.vm165.dev.vc/"

// Production
//#define BASE_URL @"http://orezan.system.vc/"

#define TIMEOUT_SECONDS 30

#define ADSTORE_ACCESS_CODE @"85a913e2ff37e09f274fe707663223ef"

#define APSALAR_APP_KEY @"f35djfa2da"
#define APSALAR_APP_SECRET @"TVu6lyPy"

// 本番
#define GAITRACKER_KEY @"UA-50564870-1"
// テスト
//#define GAITRACKER_KEY @"UA-43972298-2"

// App version update task
#define TASK_APP_VERSION_ENABLE NO

#define DB_FILE_NAME @"data.sqlite"

// CGRect
#define CGRectFromImage(image) CGRectMake(0, 0, image.size.width, image.size.height)
#define CGRectOffsetFromImage(image, x, y) CGRectMake((x), (y), image.size.width, image.size.height)
// RGBA Color
#define Color(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
// Device
#define IS_RETINA4 (([[UIScreen mainScreen] bounds].size.height < 568) ? NO : YES)
// iOS Version
#define IOS7_OR_LATER (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
#define IOS8_OR_LATER (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)
// Screen Width
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
// Screen Height
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
// Top Offset
#define TOP_OFFSET 64.0
// Tab Height
#define TAB_HEIGHT 49.0
// Image For Different iOS
#define SYS_IMAGE_NAME(name) (IOS7_OR_LATER ? [NSString stringWithFormat:@"%@_7", name] : name)
// Device Passoword
#define DEVICE_PWD @"12345678"
// Cell Identifier
#define CCIdentifier @"CCIdentifier"
// Theme Type
#define CurrentThemeType [[AppManager sharedInstance] themeType]
// Master Value
#define MASTER(key) [[[AppManager sharedInstance] masterDic] objectForKey:key]
// UUID
#define OTUUID MASTER(MSTKeyUUID)

#define KEY_DAY @"KEY_DAY"
#define KEY_WEEK @"KEY_WEEK"

#define DATE_FORMAT @"yyyy年MM月"
#define YEAR_FORMAT @"yyyy年"

// サービスID
#define SID @"1003"
// 企業ID
#define CID @"1880"
// ユーザID
#define UID @"user0001"
// DIV
#define DIV @"1"

#define DB_DATE_YMDHMS @"yyyy-MM-dd HH:mm:ss"
#define DB_DATE_YMD @"yyyy-MM-dd"
#define DB_DATE_HM @"HH:mm"

#define SHARE_TEXT @"今の残業LV.%dH %@\
残業代概算アプリ「俺の残業代がこんなに少ないわけがない」\
%@"

#define INVITE_TEXT @"残業アプリでしっかり残業代を記録しよう！コード「%@」を入力したらイイことあるかも！%@"

#define REVIEW_URL @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=881894937&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"
#define SUGGEST_URL @"https://docs.google.com/forms/d/1gHhEDRIraiC4eY44d-QSqwBzhq7sUrhBsqEVJXKyay0/viewform?usp=send_form"
#define APP_URL @"http://itunes.apple.com/app/id881894937"


#define FONT_BLUE1 [UIColor colorWithRed:0.5 green:0.79 blue:0.95 alpha:1]
#define FONT_BLUE2 [UIColor colorWithRed:0.78 green:0.86 blue:0.89 alpha:1]

#define FONT_RED1 [UIColor colorWithRed:0.95 green:0.73 blue:0.71 alpha:1]
#define FONT_RED2 [UIColor colorWithRed:0.85 green:0.76 blue:0.76 alpha:1]

#define FONT_GRAY [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1]
#define FONT_PLACEHOLDER [UIColor grayColor]
//#define FONT_PLACEHOLDER [UIColor colorWithRed:0.66 green:0.66 blue:0.66 alpha:1]

#define TutorialSettingShowed @"TutorialSettingShowed"
#define TutorialHomeShowed @"TutorialHomeShowed"
#define TutorialChartShowed @"TutorialChartShowed"
#define TutorialDetailShowed @"TutorialDetailShowed"
#define TutorialRedisplay @"TutorialRedisplay"
#define DefaultDataLoaded @"DefaultDataLoaded"

#define ThemeChangeNotification @"ThemeChangeNotification"
#define ReloadDataNotification @"ReloadDataNotification"
#define ReloadChartDataNotification @"ReloadChartDataNotification"
#define ReloadDetailDataNotification @"ReloadDetailDataNotification"
#define DailyMonthlySwitchNotification @"DailyMonthlySwitchNotification"
#define HomeDataUpdateNotification @"HomeDataUpdateNotification"
#define ChartDataUpdateNotification @"ChartDataUpdateNotification"
#define DetailDataUpdateNotification @"DetailDataUpdateNotification"
#define SettingDidupdateNotification @"SettingDidupdateNotification"
#define TutorialSettingDidFinishedNotification @"TutorialDidFinishedNotification"
#define TutorialHomeDidFinishedNotification @"TutorialHomeDidFinishedNotification"
#define TopLikeNumDidFetchedNotification @"TopLikeNumDidFetchedNotification"

#define ForwardToInviteNotification @"ForwardInviteNotification"
#define ForwardToSNSNotification @"ForwardSNSNotification"
#define ForwardToSuggestionNotification @"ForwardSuggestionNotification"

#define TopLikeNumKey @"LikeNumKey"
#define DataUpdateKeyMoney @"DataUpdateKeyMoney"
#define DataUpdateKeyHour @"DataUpdateKeyHour"

// Override install
#define TASK_APP_VERSION_DISABLE @"TASK_APP_VERSION_DISABLE"

#define FirstLaunchSNSTutorialKey  @"FirstLaunchSNSTutorialKey"

#define TASK_INVITE @"invite"
#define TASK_INVITED @"invited"
#define TASK_SNS_PROFILE @"sns_profile"
#define TASK_TW_FOLLOW @"twitter_follow"
#define TASK_TW_SHARE @"twitter_share"
#define TASK_FB_SHARE @"facebook_share"
#define TASK_LINE_SHARE @"line_share"
#define TASK_ADD_REVIEW @"add_review"
#define TASK_SNS_LIKE @"sns_like"
#define TASK_SUGGEST @"suggest"
#define TASK_SNS_MURMUR @"sns_murmur"
#define TASK_APP_VERSION @"app_version"

#define NOTIFICATION_TYPE @"NOTIFICATION_TYPE"

typedef enum {
    NotificationTypeNone,
    NotificationTypeSevenDayBefore,
    NotificationTypeOneDayBefore
} NotificationType;

typedef enum {
    AlertViewTagReview = 1,
} AlertViewTag;

typedef enum {
    ThemeTypeBlue,
    ThemeTypeRed
} ThemeType;

typedef NS_ENUM(NSInteger, OvertimeType) {
    OvertimeTypeNone,
    OvertimeTypeWorking,
    OvertimeTypeOTing,
    OvertimeTypeWorkOff
};

typedef NS_ENUM(NSInteger, Gender) {
    Male = 1,
    Female
};

typedef NS_ENUM(NSInteger, LevelType) {
    LevelTypeNone = 0,
    LevelTypeGray = 1,
    LevelTypeBlue = 2,
    LevelTypeGreen = 3,
    LevelTypeOrange = 4,
    LevelTypeRed = 5
};

typedef NS_ENUM(NSInteger, ErrorCode) {
    ErrorUnknown = -1,
    ErrorNone = 200,
    ErrorUUIDNotFound = 410,
    ErrorCompanyIDNotFound = 411,
    ErrorMessageUpdateTooMuch = 412,
    ErrorSupportTooMuch = 413,
    ErrorUserIDNotFound = 414,
    ErrorTaskIDNotFound = 415,
    ErrorGenderNotFound = 416,
    ErrorMessageNotFound = 417,
    ErrorJobIDNotFound = 418,
    ErrorMessageLengthTooLong = 419,
    ErrorInviteCodeNotFound = 420,
    ErrorBlockedUserIDNotFound = 421,
    ErrorLevelNotFound = 422,
    ErrorSupportSelf = 423,
    ErrorAlreadySupported = 424,
    ErrorTaskAlreadCompleted = 425,
    ErrorInviteSelf = 426,
    ErrorReportUserIDNotFound = 427,
    ErrorReportReason = 428,
    ErrorAlreadyBlocked = 429,
    ErrorTaskNotFound = 430,
    ErrorReportYourself = 431,
    ErrorInviteCodeLimitCount = 432,
    ErrorInvitedOnlyOneTime = 433
};

typedef enum {
    // Default
    SettingTypeInit,
    // Confirm
    SettingTypeEdit,
    // Add
    SettingTypeAdd,
    // Setting change
    SettingTypeReEdit
} SettingType;

typedef enum {
    RecordTypeGPS,
    RecordTypeManual,
    RecordTypeManualAdd,
    RecordTypeAuto
} RecordType;

typedef enum {
    EditingTypeNone,
    EditingTypeEditTime,
    EditingTypeNewTime,
    EditingTypeLocation,
    EditingTypeMemo
} EditingType;

#define KEY_TOPICS @"topics"
#define KEY_NEWS_ID @"newsId"
#define KEY_TOPICS_TIME @"topics_time"

#endif
