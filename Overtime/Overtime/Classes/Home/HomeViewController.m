//
//  HomeViewController.m
//  Overtime
//
//  Created by Xu Shawn on 2/17/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "HomeViewController.h"
#import "SettingViewController.h"
#import "DebugViewController.h"
#import "RLSNSTutorialViewController.h"
#import "RLSNSViewController.h"
#import "AchievementViewController.h"
#import "HomeMapView.h"
#import "GeoFenceManager.h"
#import "TutorialView.h"
#import "ClockView.h"
#import "Year.h"
#import "Day.h"
#import "MapPoint.h"

#import <MapKit/MapKit.h>

#define KYARA_NEW_TAG 100

@interface HomeViewController () <HomeMapViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) UIButton *clockButton;
@property (nonatomic, strong) UIButton *chartButton;
@property (nonatomic, strong) UIButton *detailButton;
@property (nonatomic, strong) UIButton *settingButton;
@property (nonatomic, strong) UIButton *helpButton;
@property (nonatomic, strong) UILabel *badgeLabel;
@property (nonatomic, strong) HomeMapView *mapView;
@property (nonatomic, strong) UIImageView *startImageView;
@property (nonatomic, strong) UILabel *startLabel;
@property (nonatomic, strong) UIImageView *endImageView;
@property (nonatomic, strong) UILabel *endLabel;
@property (nonatomic, strong) ClockView *clockView;
@property (nonatomic, assign) BOOL frameUpdated;
@property (nonatomic, strong) NSDictionary *allYearDic;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy) NSString *dateString;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleThemeChangeNotification:) name:ThemeChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReloadDataNotification:) name:ReloadDataNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSettingDidUpdateNotification:) name:SettingDidupdateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTopLikeNumNotification:) name:TopLikeNumDidFetchedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleForwardToSNSNotification:) name:ForwardToSNSNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTutorialHomeDidFinishedNotification:) name:TutorialHomeDidFinishedNotification object:nil];
        
        _dateString = [[NSDate date] localStringWithFormat:@"yyyy-MM-dd"];
        
        [[AppManager sharedInstance]  setLocationEdited:NO];
    }
    return self;
}

- (void)dealloc
{
    [self.timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    if ([[AppManager sharedInstance] currentTime]) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
    }
    
    UIImage *clockImage = [UIImage imageNamed:@"film" themeType:CurrentThemeType];
    self.clockButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.clockButton setFrame:CGRectOffsetFromImage(clockImage, 88.0, 266.0)];
    [self.clockButton setImage:clockImage forState:UIControlStateNormal];
    [self.clockButton addTarget:self action:@selector(clockButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.clockButton];
    
    UIImage *chartImage = [UIImage imageNamed:@"left1" themeType:CurrentThemeType];
    self.chartButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.chartButton setFrame:CGRectOffsetFromImage(chartImage, 3.0, 271.0)];
    [self.chartButton setImage:chartImage forState:UIControlStateNormal];
    [self.chartButton addTarget:self action:@selector(chartButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.chartButton];
    
    UIImage *detailImage = [UIImage imageNamed:@"left2" themeType:CurrentThemeType];
    self.detailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.detailButton setFrame:CGRectOffsetFromImage(detailImage, 4.0, 342.0)];
    [self.detailButton setImage:detailImage forState:UIControlStateNormal];
    [self.detailButton addTarget:self action:@selector(detailButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.detailButton];
    
    UIImage *settingImage = [UIImage imageNamed:@"right1" themeType:CurrentThemeType];
    self.settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.settingButton setFrame:CGRectOffsetFromImage(settingImage, 235.0, 272.0)];
    [self.settingButton setImage:settingImage forState:UIControlStateNormal];
    [self.settingButton addTarget:self action:@selector(settingButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.settingButton];
    
    UIImage *kyaraNewImage = [UIImage imageNamed:@"btn_new"];
    UIImageView *kyaraNewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(settingImage.size.width - kyaraNewImage.size.width - 13.0, 8.0, kyaraNewImage.size.width, kyaraNewImage.size.height)];
    [kyaraNewImageView setImage:kyaraNewImage];
    [kyaraNewImageView setTag:KYARA_NEW_TAG];
    [self.settingButton addSubview:kyaraNewImageView];
    
    UIImage *helpImage = [UIImage imageNamed:@"right2" themeType:CurrentThemeType];
    self.helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.helpButton setFrame:CGRectOffsetFromImage(helpImage, 228.5, 343.0)];
    [self.helpButton setImage:helpImage forState:UIControlStateNormal];
    [self.helpButton addTarget:self action:@selector(helpButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.helpButton];
    
    self.badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 12.0, 16.0, 12.0)];
    [self.badgeLabel setText:@"0"];
    [self.badgeLabel setFont:[UIFont systemFontOfSize:10.0]];
    [self.badgeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.helpButton addSubview:self.badgeLabel];
    
    CGPoint mapAnchorPoint = CGPointMake(0.5, 0.39);
    self.mapView = [[HomeMapView alloc] initWithFrame:CGRectMake(0, 185.0 - (SCREEN_HEIGHT - 185.0) * (0.5 - mapAnchorPoint.y), SCREEN_WIDTH, SCREEN_HEIGHT - 185.0)];
    [self.mapView.layer setAnchorPoint:mapAnchorPoint];
    [self.mapView setDelegate:self];
    [self.view insertSubview:self.mapView atIndex:0];
    
    self.clockView = [[ClockView alloc] initWithFrame:CGRectMake(self.clockButton.left + 1.0, self.clockButton.top - 1.0, 142.0, 142.0)];
    [self.view insertSubview:self.clockView belowSubview:self.clockButton];
    
    [self.stateLabel setTextColor:FONT_BLUE1];
    [self.totalTimeLabel setTextColor:FONT_BLUE1];
    
    UIImage *startImage = [UIImage imageNamed:@"work_start" themeType:CurrentThemeType];
    self.startImageView = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(startImage, 25.0, 10.0)];
    [self.startImageView setImage:startImage];
    [self.startButton addSubview:self.startImageView];

    self.startLabel = [[UILabel alloc] initWithFrame:CGRectMake(25.0, self.startImageView.bottom, self.startImageView.width, 20.0)];
    [self.startLabel setBackgroundColor:[UIColor clearColor]];
    [self.startLabel setFont:[UIFont systemFontOfSize:15.0]];
    [self.startLabel setTextColor:FONT_BLUE2];
    [self.startLabel setText:@"--:--"];
    [self.startLabel setTextAlignment:NSTextAlignmentCenter];
    [self.startButton addSubview:self.startLabel];
    
    UIImage *endImage = [UIImage imageNamed:@"work_end" themeType:CurrentThemeType];
    self.endImageView = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(endImage, 80.0, 10.0)];
    [self.endImageView setImage:endImage];
    [self.endButton addSubview:self.endImageView];
    
    self.endLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0, self.endImageView.bottom, self.endImageView.width, 20.0)];
    [self.endLabel setBackgroundColor:[UIColor clearColor]];
    [self.endLabel setFont:[UIFont systemFontOfSize:15.0]];
    [self.endLabel setTextColor:FONT_GRAY];
    [self.endLabel setText:@"--:--"];
    [self.endLabel setTextAlignment:NSTextAlignmentCenter];
    [self.endButton addSubview:self.endLabel];
    
    [self setCurrentThemeType:CurrentThemeType];
    
    // Reset frame
    if (IS_RETINA4) {
        
    } else {
        CGFloat deltaHeight = 47.0;
        [self.clockButton setTop:(self.clockButton.top - deltaHeight)];
        [self.chartButton setTop:(self.chartButton.top - deltaHeight)];
        [self.detailButton setTop:(self.detailButton.top - deltaHeight)];
        [self.settingButton setTop:(self.settingButton.top - deltaHeight)];
        [self.helpButton setTop:(self.helpButton.top - deltaHeight)];
        [self.clockView setTop:(self.clockView.top - deltaHeight)];
    }
    
    if ([GFUtils configGeoFence:[[AppManager sharedInstance] areaArray]]) {
        DLog(@"Config geo fence success");
    } else {
        DLog(@"Config geo fence failed");
    }

    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:window];
    [window addSubview:hud];
    [hud setRemoveFromSuperViewOnHide:YES];
    [hud showAnimated:YES whileExecutingBlock:^{
        [[AppManager sharedInstance] reloadEraData];
        [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(configLocationManager) withObject:nil waitUntilDone:NO];
    }];
    
//    UIImage *debugImage = [UIImage imageNamed:@"my_location_button"];
//    UIButton *debugButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [debugButton setFrame:CGRectOffsetFromImage(debugImage, (self.view.width - debugImage.size.width) / 2.0, SCREEN_HEIGHT - 5.0 - debugImage.size.height)];
//    [debugButton setImage:debugImage forState:UIControlStateNormal];
//    [debugButton addTarget:self action:@selector(debugButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:debugButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults boolForKey:TutorialHomeShowed]) {
        [TutorialView showWithTutorialType:TutorialTypeHome];
        [userDefaults setBool:YES forKey:TutorialHomeShowed];
        [userDefaults synchronize];
    } else {
        if ([MASTER(MSTKeyUserLogined) isEqualToString:@"1"]) {
            // Request number
            [[AppManager sharedInstance] requestTopLikeNum];
            
            // Request task list
            [[AppManager sharedInstance] requestUserInfo];
        }
    }
    
    if ([MASTER(MSTKeyKyaraNewHidden) integerValue] > 0) {
        UIView *view = [self.settingButton viewWithTag:KYARA_NEW_TAG];
        [view removeFromSuperview];
    }
}

#pragma mark - Private

- (void)configLocationManager
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.distanceFilter = 100.0;
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    [self.locationManager setActivityType:CLActivityTypeFitness];
    
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
    [self.locationManager startUpdatingLocation];
    
    
//    // LocationManagerのデリゲート設定
//    [[LocationManager defaultLocationManager] setDelegate:self];
//    [self startLocationMeasuring];
}

//- (void)startLocationMeasuring
//{
//    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
//    [settings setObject:@"APPID_SAMPLE_APP" forKey:MeasuringSettingAPPIDKey];
//    [settings setObject:@"http://test.fw.its-mo.com/trafficpf_loc/EntryPositionalInfo.php" forKey:MeasuringSettingURLKey];
//    [settings setObject:@"1" forKey:MeasuringSettingPermissionKey];
//    [settings setObject:@"705" forKey:MeasuringSettingSchemaKey];
//    [settings setObject:@"mobi0001" forKey:MeasuringSettingUIDKey];
//    [settings setObject:@"40" forKey:MeasuringSettingBatteryLevIntervalKey];
//    [settings setObject:@"5000" forKey:MeasuringSettingSignificantChangeAccuracyKey];
//    [settings setObject:@"1" forKey:MeasuringSettingLogUploadCountKey];
//    [settings setObject:@"5" forKey:MeasuringSettingAccuracyKey];
//    [settings setObject:@"10" forKey:MeasuringSettingDistanceKey];
//    [settings setObject:@"5" forKey:MeasuringSettingIntervalKey];
//    [settings setObject:@"50" forKey:MeasuringSettingSamePositionDistanceKey];
//    [settings setObject:@"30" forKey:MeasuringSettingSamePositionCountKey];
//    
//    [[LocationManager defaultLocationManager] measuringStart:settings];
//}

//- (void)startLocationMeasuring
//{
//    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
//    [settings setObject:@"APPID_SAMPLE_APP" forKey:MeasuringSettingAPPIDKey];
//    [settings setObject:@"http://test.fw.its-mo.com/position_log/data.php" forKey:MeasuringSettingURLKey];
//    [settings setObject:@"1" forKey:MeasuringSettingPermissionKey];
//    [settings setObject:@"0" forKey:MeasuringSettingPushMessageKey];
//    [settings setObject:@"5" forKey:MeasuringSettingAccuracyKey];
//    [settings setObject:@"10" forKey:MeasuringSettingDistanceKey];
//    [settings setObject:@"5" forKey:MeasuringSettingIntervalKey];
//    [settings setObject:@"50" forKey:ChangeSettingsSamePositionDistanceKey];
//    [settings setObject:@"30" forKey:ChangeSettingsSamePositionCountKey];
//    [settings setObject:@"REGISTER_POINT_TEST" forKey:MeasuringSettingSchemaKey];
//    [settings setObject:@"http://test.fw.its-mo.com/density" forKey:MeasuringSettingSettingServerURLKey];
//    [settings setObject:@"UID_SAMPLE_APP" forKey:MeasuringSettingUIDKey];
//    [[LocationManager defaultLocationManager] measuringStart:settings];
//}

//- (void)stopLocationMeasuring
//{
//    [[LocationManager defaultLocationManager] measuringStop];
//}

- (void)reloadData
{
    [[AppManager sharedInstance] updateToCurrentDate];
    [self reloadTotalTodayData];
    [self reloadControlsData];
}

- (void)reloadTotalTodayData
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    
    double money = 0;
    if (self.homeType == HomeTypeTotal) {
        money = [[[AppManager sharedInstance] era] money];
    } else {
        money = [[[AppManager sharedInstance] currentDay] money];
    }
    NSDate *currentDate = [[AppManager sharedInstance] currentDate];
    Month *month = [[[AppManager sharedInstance] era] monthFromDate:currentDate];
    
    [userInfo setObject:@(money) forKey:DataUpdateKeyMoney];
    [userInfo setObject:@(month.otHours) forKey:DataUpdateKeyHour];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HomeDataUpdateNotification object:nil userInfo:userInfo];
    
    if ([MASTER(MSTKeyChargeReach) integerValue] == 1) {
        double alertMoney = [MASTER(MSTKeyChargeAmount) doubleValue];
        double nextAlertMoney = [MASTER(MSTKeyNextChargeAmount) doubleValue];
        alertMoney *= 10000;
        nextAlertMoney *= 10000;
        if (nextAlertMoney <= 0) {
            nextAlertMoney = alertMoney;
        }
        if (month.money > nextAlertMoney) {
            NSString *format = [AppManager pushMessageForKey:MSGChargeReach];
            NSString *message = [NSString stringWithFormat:format, month.monthOfDate, [MASTER(MSTKeyNextChargeAmount) integerValue]];
            [AppManager addLocalNotification:message];
            nextAlertMoney += alertMoney;
            while (YES) {
                if (month.money > nextAlertMoney) {
                    nextAlertMoney += alertMoney;
                } else {
                    break;
                }
            }
            NSInteger value = nextAlertMoney / 10000;
            [Master saveValue:[NSString stringWithFormat:@"%d", (int)value] forKey:MSTKeyNextChargeAmount];
        } else {
            // Adjust next alert money
            if (month.money < (nextAlertMoney - alertMoney)) {
                while (YES) {
                    if (month.money < (nextAlertMoney - alertMoney)) {
                        nextAlertMoney -= alertMoney;
                    } else {
                        break;
                    }
                }
                NSInteger value = nextAlertMoney / 10000;
                [Master saveValue:[NSString stringWithFormat:@"%d", (int)value] forKey:MSTKeyNextChargeAmount];
            }
            
        }
    }
}

- (void)reloadControlsData
{
    if ([[AppManager sharedInstance] overtimeType] != OvertimeTypeNone) {
        Day *currentDay = [[AppManager sharedInstance] currentDay];
        NSString *start_date = [currentDay start_date];
        NSString *end_date = [currentDay end_date];
        NSString *startTime = [start_date dateStringWithFomat:DB_DATE_HM fromFormat:DB_DATE_YMDHMS];
        NSString *endTime = [end_date dateStringWithFomat:DB_DATE_HM fromFormat:DB_DATE_YMDHMS];
        NSString *displayStartTime = [start_date displayTime];
        NSString *displayEndTime = [end_date displayTime];
        
        if (displayStartTime.length > 0) {
            [self.startLabel setText:displayStartTime];
        }
        if (![[AppManager sharedInstance] currentTime]) {
            [self.stateLabel setText:@"勤務外"];
            
            if (displayEndTime.length > 0) {
                [self.endLabel setText:displayEndTime];
            } else {
                [self.endLabel setText:@"--:--"];
            }
            // Reset theme
            [self setCurrentThemeType:CurrentThemeType];
            
//            NSDate *date1 = [start_date dateWithFormat:DB_DATE_YMDHMS];
//            NSDate *date2 = [end_date dateWithFormat:DB_DATE_YMDHMS];
//            NSTimeInterval timeInterval = [date2 timeIntervalSinceDate:date1];
//            NSInteger hour = timeInterval / 3600;
//            NSInteger minute = timeInterval / 60 - hour * 60;

            [self.totalTimeLabel setText:[AppManager hoursToHHmm:currentDay.workHours]];
            
            [self.clockView reloadAtStartTime:startTime endTime:endTime];
            
            // Recalculate all money
            [[[AppManager sharedInstance] era] recalculateData];
            
            if ([[AppManager sharedInstance] themeType] == ThemeTypeRed) {
                [[AppManager sharedInstance] setThemeType:ThemeTypeBlue];
                [[NSNotificationCenter defaultCenter] postNotificationName:ThemeChangeNotification object:nil];
            }
            // Overtime type
            [[AppManager sharedInstance] setOvertimeType:OvertimeTypeWorkOff];
        } else {
            [self.stateLabel setText:@"勤務中"];
            [self.endLabel setText:@"--:--"];
            
            NSDate *now = [NSDate date];
            NSString *endTime = [now localStringWithFormat:DB_DATE_HM];
            [self.clockView reloadAtStartTime:startTime endTime:endTime];
            // Set current day end date to now
            [currentDay setEnd_date:[now localStringWithFormat:DB_DATE_YMDHMS]];
            // Recalculate all money
            [[[AppManager sharedInstance] era] recalculateData];

            NSInteger hour = floor(currentDay.workHours);
            NSInteger minute = (currentDay.workHours - hour) * 60;
            NSString *intervalHM = [NSString stringWithFormat:@"%02d:%02d", (int)hour, (int)minute];
            
            [self.totalTimeLabel setText:intervalHM];
            
            if (currentDay.otHours > 0 || currentDay.midnightHour > 0 || currentDay.isHoliday) {
                if ([[AppManager sharedInstance] themeType] != ThemeTypeRed) {
                    [[AppManager sharedInstance] setThemeType:ThemeTypeRed];
                    [[NSNotificationCenter defaultCenter] postNotificationName:ThemeChangeNotification object:nil];
                    
                    
                    if ([MASTER(MSTKeyOvertimeOn) integerValue] == 1 && !currentDay.isHoliday) {
                        // Log tracker
                        NSDictionary *parameters = [[GAIDictionaryBuilder createEventWithCategory:OTUUID
                                                                                           action:@"残業開始時"
                                                                                            label:currentDay.end_date
                                                                                            value:nil] build];
                        [[[GAI sharedInstance] defaultTracker] send:parameters];
                        // Notification
                        NSString *body = [AppManager pushMessageForKey:MSGOTStart];
                        [AppManager addLocalNotification:body];
                    }
                }
                // Overtime type
                [[AppManager sharedInstance] setOvertimeType:OvertimeTypeOTing];
            } else {
                if ([[AppManager sharedInstance] themeType] == ThemeTypeRed) {
                    [[AppManager sharedInstance] setThemeType:ThemeTypeBlue];
                    [[NSNotificationCenter defaultCenter] postNotificationName:ThemeChangeNotification object:nil];
                }
                // Overtime type
                [[AppManager sharedInstance] setOvertimeType:OvertimeTypeWorking];
            }
            
            [[AppManager sharedInstance] checkAutoWorkOffWithAutoWorkOn:YES];
        }
    } else {
        [self.startLabel setText:@"--:--"];
        [self.endLabel setText:@"--:--"];
        [self.totalTimeLabel setText:@"--:--"];
        [self.clockView reloadAtStartTime:@"00:00" endTime:@"00:00"];
    }
}

- (void)setCurrentThemeType:(ThemeType)themeType
{
    [self.bgImageView setImage:[UIImage imageNamed:@"bg1" themeType:themeType]];
    [self.clockButton setImage:[UIImage imageNamed:@"film" themeType:themeType] forState:UIControlStateNormal];
    [self.chartButton setImage:[UIImage imageNamed:@"left1" themeType:themeType] forState:UIControlStateNormal];
    [self.detailButton setImage:[UIImage imageNamed:@"left2" themeType:themeType] forState:UIControlStateNormal];
    [self.settingButton setImage:[UIImage imageNamed:@"right1" themeType:themeType] forState:UIControlStateNormal];
    [self.helpButton setImage:[UIImage imageNamed:@"right2" themeType:themeType] forState:UIControlStateNormal];
    [self.smallClockImageView setImage:[UIImage imageNamed:@"clock" themeType:themeType]];
    [self.clockView updateTheme:themeType];
    
    [self.startImageView setImage:[UIImage imageNamed:@"work_start" themeType:themeType]];
    
    switch (themeType) {
        case ThemeTypeBlue: {
            [self.stateLabel setTextColor:FONT_BLUE1];
            [self.totalTimeLabel setTextColor:FONT_BLUE1];
            [self.startLabel setTextColor:FONT_BLUE2];
            if ([self.endLabel.text isEqualToString:@"--:--"]) {
                [self.endLabel setTextColor:FONT_GRAY];
                [self.endImageView setImage:[UIImage imageNamed:@"work_end_none"]];
            } else {
                [self.endLabel setTextColor:FONT_BLUE2];
                [self.endImageView setImage:[UIImage imageNamed:@"work_end" themeType:themeType]];
            }
            break;
        }
        case ThemeTypeRed: {
            [self.stateLabel setTextColor:FONT_RED1];
            [self.totalTimeLabel setTextColor:FONT_RED1];
            [self.startLabel setTextColor:FONT_RED2];
            if ([self.endLabel.text isEqualToString:@"--:--"]) {
                [self.endLabel setTextColor:FONT_GRAY];
                [self.endImageView setImage:[UIImage imageNamed:@"work_end_none"]];
            } else {
                [self.endLabel setTextColor:FONT_RED2];
            }
            break;
        }
        default:
            break;
    }
}

- (void)clockButtonDidClicked:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        for (UIView *view in self.view.subviews) {
            if (view != self.mapView) {
                [view setAlpha:0.0];
            }
        }
    } completion:^(BOOL finished) {
        for (UIView *view in self.view.subviews) {
            if (view != self.mapView) {
                [view setHidden:YES];
            }
        }
    }];
}

- (void)detailButtonDidClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(homeViewController:forwardToDetailViewWithShowType:)]) {
        [self.delegate homeViewController:self forwardToDetailViewWithShowType:DetailShowTypeDefault];
    }
}

- (void)chartButtonDidClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(forwardToChartViewFromHomeView:)]) {
        [self.delegate forwardToChartViewFromHomeView:self];
    }
}

- (void)settingButtonDidClicked:(id)sender
{
    SettingViewController *settingViewController = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:settingViewController animated:YES];
    [self checkLocation];
}

- (void)helpButtonDidClicked:(id)sender
{
    [self forwardToSNS];
}

- (void)forwardToSNS
{
    NSString *first = MASTER(MSTKeyFirstLaunch);
    if (first.length != 0) {
        RLSNSViewController *snsVC = [[RLSNSViewController alloc] init];
        snsVC.homeVC = self.parentViewController;
        [self.navigationController pushViewController:snsVC animated:YES];
    } else {
        RLSNSTutorialViewController *vc = [[RLSNSTutorialViewController alloc] initWithTutorial:YES];
        vc.homeVC = self.parentViewController;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)startButtonDidClicked:(id)sender
{
    if (![self.startLabel.text isEqualToString:@"--:--"] && self.delegate && [self.delegate respondsToSelector:@selector(homeViewController:forwardToDetailViewWithShowType:)]) {
        [self.delegate homeViewController:self forwardToDetailViewWithShowType:DetailShowTypeStart];
    }
}

- (IBAction)endButtonDidClicked:(id)sender
{
    if (![self.endLabel.text isEqualToString:@"--:--"] && self.delegate && [self.delegate respondsToSelector:@selector(homeViewController:forwardToDetailViewWithShowType:)]) {
        [self.delegate homeViewController:self forwardToDetailViewWithShowType:DetailShowTypeEnd];
    }
}

- (void)debugButtonDidClicked:(UIButton *)button
{
    DebugViewController *debugViewController = [[DebugViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:debugViewController];
    [navigationController setNavigationBarHidden:YES];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

/*
- (void)setGeoParam:(NSString *)nid
{
    NSDictionary *params = @{
                              GFlRequestParamKeyDiv : @(0),
                              GFlRequestParamKeySid : SID,
                              GFlRequestParamKeyCid : CID,
                              GFlRequestParamKeyUid : UID,
                              GFlRequestParamKeyMid : [[AppManager sharedInstance] UDID],
                              GFlRequestParamKeyPwd : DEVICE_PWD,
                              GFlRequestParamKeyOwnid : [[AppManager sharedInstance] UDID],
                              GFlRequestParamKeyTntp : @(4),
                              GFlRequestParamKeyTnlv : @(0),
                              GFlRequestParamKeyTcid : CID,
                              GFlRequestParamKeyTuid : UID,
                              GFlRequestParamKeyTmid : [[AppManager sharedInstance] UDID],
                              GFlRequestParamKeyTnid : nid,
                              };
    DLog(@"Set Params: %@", params);
    
	GeoFenceManagerSetParamResult result;
    result = [[GeoFenceManager defaultManager] setParams:params saveInterval:5 operationMode:kGFlGeoFenceManagerOperationMode_Manual];
    
	if (result == kGFlGeoFenceManagerSetParamSuccess) {
		// Set Patams Success
        DLog(@"Set Params Success");
	} else {
		// Set Patams Faild
        DLog(@"Set Params Faild");
	}
}

- (void)updateArea
{
    GeoFenceManagerUpdateAreaInfoResult result = [[GeoFenceManager defaultManager] updateAreaInformation];
    
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    
	if (result == kGFlGeoFenceManagerUpdateNoError) {
		// Update did success
        DLog(@"Update area did success");
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [hud setMode:MBProgressHUDModeText];
        [hud setLabelText:@"Update area did success"];
        [hud setRemoveFromSuperViewOnHide:YES];
        [hud hide:YES afterDelay:1.0];
    } else {
		// Update did faild
        DLog(@"Update area did failed");
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [hud setMode:MBProgressHUDModeText];
        [hud setLabelText:@"Update area did failed"];
        [hud setRemoveFromSuperViewOnHide:YES];
        [hud hide:YES afterDelay:1.0];
	}
}
*/

- (void)checkLocation
{
    double latitude = [AppManager sharedInstance].testLatitude;
    double longitude = [AppManager sharedInstance].testLongitude;
    double horizontalAccuracy = [AppManager sharedInstance].horizontalAccuracy;
    
    for (Area *area in [[AppManager sharedInstance] areaArray]) {
        NSLog(@"AREA: %@ %@", area.latitude, area.longitude);
    }

    // ntmg
    // 1:IN
    // 2:OUT
    NSArray *array = [[GeoFenceManager defaultManager] checkLocation:[NSDate date] latitude:latitude longitude:longitude horizontalAccuracy:horizontalAccuracy];
    NSLog(@"CheckLocation: %f %f %f %@", latitude, longitude, horizontalAccuracy, array);
    
    /** match */
	if (array.count > 0){
        if (array.count > 1) {
            NSDictionary *info = [array objectAtIndex:0];
            NSDictionary *notificationInfo = [info objectForKey:GFlResponseTagKeyCondition];
            NSString *areaID = [notificationInfo objectForKey:GFlResponseKeyAid];
            
            if ([notificationInfo[GFlResponseKeyNtmg] integerValue] == 1) {
                // In region
                [LogUtils saveLog:[NSString stringWithFormat:@"Date:%@ Latitude:%f Longitude:%f Double Area:%@ Result:IN\n", [[NSDate date] localStringWithFormat:DB_DATE_YMDHMS], latitude, longitude, areaID]];
            } else if ([notificationInfo[GFlResponseKeyNtmg] integerValue] == 2) {
                // Out region
                [LogUtils saveLog:[NSString stringWithFormat:@"Date:%@ Latitude:%f Longitude:%f Double Area:%@ Result:OUT\n", [[NSDate date] localStringWithFormat:DB_DATE_YMDHMS], latitude, longitude, areaID]];
            }
        }
        
        NSDictionary *info = [array lastObject];
        
	    NSDictionary *areaInfo = [info objectForKey:GFlResponseTagKeyArea];
        NSDictionary *notificationInfo = [info objectForKey:GFlResponseTagKeyCondition];
        NSNumber *notificationID = [notificationInfo objectForKey:GFlResponseKeyNid];
        NSString *areaID = [notificationInfo objectForKey:GFlResponseKeyAid];
        NSString *msg = areaInfo[GFlResponseKeyMsg];
        NSLog(@"%@ %@ %@", notificationID, areaID, msg);
        
        if ([notificationInfo[GFlResponseKeyNtmg] integerValue] == 1) {
            // In region
            [LogUtils saveLog:[NSString stringWithFormat:@"Date:%@ Latitude:%f Longitude:%f Area:%@ Result:IN\n", [[NSDate date] localStringWithFormat:DB_DATE_YMDHMS], latitude, longitude, areaID]];
            
            // Now
            NSDate *now = [NSDate date];
            
            // Check exist time
            if ([[AppManager sharedInstance] currentTime]) {
                // End time
                [[AppManager sharedInstance] endTimeForDate:now withNotificationFlag:NO];
                // Log
                [LogUtils saveLog:[NSString stringWithFormat:@"Date:%@ Latitude:00.000000 Longitude:000.000000 Area:0 Result:AUTOOUTIN\n", [[NSDate date] localStringWithFormat:DB_DATE_YMDHMS]]];
            }
            
            //                // Master data
            //                NSDictionary *masterDic = [[AppManager sharedInstance] masterDic];
            
            //                // Calculate real date
            //                NSInteger minutes = [masterDic[MSTKeyInOutftim] integerValue];
            //                NSInteger times = [masterDic[MSTKeyInOutfnum] integerValue];
            //                NSDate *realDate = [now dateByAddingTimeInterval:(-(times - 1) * minutes * 60)];
            // New time
            [[AppManager sharedInstance] startTimeForDate:now withAreaID:areaID];
           
            if (!self.timer.isValid) {
                self.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
                [self.timer fire];
            } else {
                [self.timer fire];
            }
        } else if ([notificationInfo[GFlResponseKeyNtmg] integerValue] == 2) {
            // Out region
            [LogUtils saveLog:[NSString stringWithFormat:@"Date:%@ Latitude:%f Longitude:%f Area:%@ Result:OUT\n", [[NSDate date] localStringWithFormat:DB_DATE_YMDHMS], latitude, longitude, areaID]];
            //                // Master data
            //                NSDictionary *masterDic = [[AppManager sharedInstance] masterDic];
            // Now
            NSDate *now = [NSDate date];
            //                NSInteger minutes = [masterDic[MSTKeyInOutftim] integerValue];
            //                NSInteger times = [masterDic[MSTKeyInOutfnum] integerValue];
            //                NSDate *realDate = [now dateByAddingTimeInterval:(-(times - 1) * minutes * 60)];
            // End time
            [[AppManager sharedInstance] endTimeForDate:now];
            
            // Recalculate all money
            [[[AppManager sharedInstance] era] recalculateData];
            
            if (self.timer.isValid) {
                [self.timer invalidate];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:ReloadDataNotification object:nil];
        }
	} else {
	    /** nothing match */
        [LogUtils saveLog:[NSString stringWithFormat:@"Date:%@ Latitude:%f Longitude:%f Area:0 Result:NONE\n", [[NSDate date] localStringWithFormat:DB_DATE_YMDHMS], latitude, longitude]];
    }
}

#pragma mark - HomeMapViewDelegate

- (void)homeMapViewBackToHomeView:(HomeMapView *)mapView
{
    for (UIView *view in self.view.subviews) {
        if (view != self.mapView) {
            [view setHidden:NO];
        }
    }
    [UIView animateWithDuration:0.5 animations:^{
        for (UIView *view in self.view.subviews) {
            if (view != self.mapView) {
                [view setAlpha:1.0];
            }
        }
    }];
}

#pragma mark - LocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([manager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [manager requestAlwaysAuthorization];
            }
            break;
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    DLog(@"didUpdateToLocation: %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    // Save coordinate
    [[AppManager sharedInstance] setTestLatitude:newLocation.coordinate.latitude];
    [[AppManager sharedInstance] setTestLongitude:newLocation.coordinate.longitude];
    [[AppManager sharedInstance] setHorizontalAccuracy:newLocation.horizontalAccuracy];
    
    [self checkLocation];
}

/* 測位情報を通知するコールバック関数 */
//- (void)measuringResult:(LocationInfo *)locationInfo status:(LocationManagerStatus)status error:(NSError *)error
//{
//    if (status == LocationManagerStatusError) {
//        [self setLogText:@"測位に失敗しました。"];
//    } else if (status == LocationManagerStatusPending) {
//        [self setLogText:@"測位中です。"];
//    } else {
//        /* 出力ログの形成 */
//        NSMutableString *log = [NSMutableString string];
//        
//        [log appendFormat:@"現在: %@\n", [NSDate date]];
//        [log appendFormat:@"日付: %@          ", locationInfo.date];
//        [log appendFormat:@"時間: %@\n", locationInfo.time];
//        [log appendFormat:@"緯度: %+f       ", locationInfo.latitude];
//        [log appendFormat:@"経度: %+f       ", locationInfo.longitude];
//        [log appendFormat:@"誤差: %d\n", locationInfo.horizontalAccuracy];
//        [log appendFormat:@"標高: %+f\n\n", locationInfo.altitude];
//        
//        [self setLogText:log];
//        
//        if (!DEBUG_MODE) {
//            [[AppManager sharedInstance] setTestLatitude:locationInfo.latitude];
//            [[AppManager sharedInstance] setTestLongitude:locationInfo.longitude];
//            [[AppManager sharedInstance] setHorizontalAccuracy:locationInfo.horizontalAccuracy];
//
//            [self checkLocation];
//        } else {
//            [[AppManager sharedInstance] setHorizontalAccuracy:10];
//            
//            [self checkLocation];
//        }
//        
////        _times++;
////        [_timesLabel setText:[NSString stringWithFormat:@"%u", _times]];
////        [_timesLabel setNeedsDisplay];
//    }
//}

/* PUSH通知メッセージを通知するコールバック関数 */
- (void)pushMessageList:(NSArray *)messageList error:(NSError *)error
{
    /* 出力ログの形成 */
    NSMutableString *log = [NSMutableString stringWithString:@"PUSHメッセージ通知:\n"];
    
    if (messageList != nil) {
        [log appendFormat:@"%@\n\n", [messageList description]];
    } else if (error != nil) {
        [log appendFormat:@"%@\n\n", [error description]];
    }
    
    if ([log length] > 0) {
        [self setLogText:log];
    }
}

/* 設定値変更を通知するコールバック関数 */
- (void)changeSettings:(NSDictionary *)settings error:(NSError *)error
{
    /* 出力ログの形成 */
    NSMutableString *log = [NSMutableString stringWithString:@"設定値変更通知:\n"];
    
    if (settings != nil) {
        [log appendFormat:@"%@\n\n", [settings description]];
    } else if (error != nil) {
        [log appendFormat:@"%@\n\n", [error description]];
    }
    
    if ([log length] > 0) {
        [self setLogText:log];
    }
}

/* ログを追加 */
-(void)setLogText:(NSString *)test
{
    NSLog(@"%@", test);
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D location = [userLocation coordinate];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 1500.0, 1500.0);
    [mapView setRegion:region animated:YES];
//    DLog(@"Home User Location: %f, %f", location.latitude, location.longitude);
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *PinIdentifier = @"AnnotationIdentifier";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:PinIdentifier];
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:PinIdentifier];
        [annotationView setImage:[UIImage imageNamed:@"current_location"]];
    }
    return annotationView;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    MKCircleView *circleView = nil;
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircle *circle = overlay;
        circleView = [[MKCircleView alloc] initWithCircle:circle];
        [circleView setStrokeColor:[UIColor colorWithRed:0.41 green:0.65 blue:0.95 alpha:1]];
        [circleView setFillColor:[UIColor colorWithRed:0.83 green:0.93 blue:1 alpha:0.8]];
        [circleView setLineWidth:1.0];
    }
    return circleView;
}

#pragma mark - Notification

- (void)handleThemeChangeNotification:(NSNotification *)notification
{
    [self setCurrentThemeType:CurrentThemeType];
}

- (void)handleReloadDataNotification:(NSNotification *)notification
{
    [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)handleSettingDidUpdateNotification:(NSNotification *)notification
{
    if ([[AppManager sharedInstance] locationEdited]) {
        [[AppManager sharedInstance] setLocationEdited:NO];
        
        [self.mapView addAreaCircles];
        
        if ([[AppManager sharedInstance] currentTime]) {
            // Now
            NSDate *now = [NSDate date];
            // End time
            [[AppManager sharedInstance] endTimeForDate:now withNotificationFlag:NO];
            // Log
            [LogUtils saveLog:[NSString stringWithFormat:@"Date:%@ Latitude:00.000000 Longitude:000.000000 Area:0 Result:AUTOOUT\n", [[NSDate date] localStringWithFormat:DB_DATE_YMDHMS]]];
        }
    }
    
    // Recalculate all money
    [[[AppManager sharedInstance] era] recalculateData];
    
    [self reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:ReloadDetailDataNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:ReloadChartDataNotification object:nil];
    
//    [self stopLocationMeasuring];
//    [self startLocationMeasuring];
    
    [self.locationManager stopUpdatingLocation];
    [self.locationManager startUpdatingLocation];
}

- (void)handleTopLikeNumNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    [self.badgeLabel setText:userInfo[TopLikeNumKey]];
}

- (void)handleForwardToSNSNotification:(NSNotification *)notification
{
    [self.navigationController popToViewController:self.parentViewController animated:NO];
    
    [self forwardToSNS];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(forwardToHomeViewFromHomeView:)]) {
        [self.delegate forwardToHomeViewFromHomeView:self];
    }
}

- (void)handleTutorialHomeDidFinishedNotification:(NSNotification *)notification
{
    if ([MASTER(MSTKeyUserLogined) isEqualToString:@"1"]) {
        // Request number
        [[AppManager sharedInstance] requestTopLikeNum];
        
        // Request task list
        [[AppManager sharedInstance] requestUserInfo];
    }
}

#pragma mark - Timer

- (void)handleTimer:(NSTimer *)timer
{
    [self reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:ReloadDetailDataNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:ReloadChartDataNotification object:nil];
}

@end
