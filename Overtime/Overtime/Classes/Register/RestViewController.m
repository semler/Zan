//
//  RestViewController.m
//  Overtime
//
//  Created by Xu Shawn on 3/6/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "RestViewController.h"
#import "HolidayViewController.h"
#import "CustomPicker.h"

@interface RestViewController () <CustomPickerDelegate>

@property (nonatomic, strong) UILabel *beginLabel1;
@property (nonatomic, strong) UILabel *beginLabel2;
@property (nonatomic, strong) UILabel *endLabel1;
@property (nonatomic, strong) UILabel *endLabel2;
@property (nonatomic, strong) UILabel *currentLabel;

@end

@implementation RestViewController

- (id)initWithSettingType:(SettingType)settingType
{
    self = [super init];
    if (self) {
        // Custom initialization
        _settingType = settingType;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIImage *headerImage = nil;
    switch (self.settingType) {
        case SettingTypeInit:
            headerImage = [UIImage imageNamed:@"rest_header"];
            break;
        case SettingTypeEdit:
            headerImage = [UIImage imageNamed:@"rest_reset_header"];
            break;
        case SettingTypeReEdit:
            headerImage = [UIImage imageNamed:@"setting_header"];
            break;
        default:
            break;
    }
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectFromImage(headerImage)];
    [headerImageView setImage:headerImage];
    [self.view addSubview:headerImageView];
    
    switch (self.settingType) {
        case SettingTypeInit:
            [self configBackButton];
            break;
        case SettingTypeEdit:
        case SettingTypeReEdit:
            [self configCancelButton];
            break;
        default:
            break;
    }
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, headerImageView.bottom, SCREEN_WIDTH, SCREEN_HEIGHT - headerImageView.bottom)];
    [self.view addSubview:scrollView];
    
    UIImage *bgImage = [UIImage imageNamed:@"rest_bg"];
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectFromImage(bgImage)];
    [bgImageView setImage:bgImage];
    [scrollView addSubview:bgImageView];

    [scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, bgImageView.bottom)];
    
    UIImage *beginImage = [UIImage imageNamed:@"rest_begin"];
    UIImage *endImage = [UIImage imageNamed:@"rest_end"];
    
    UIButton *beginButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [beginButton1 setFrame:CGRectOffsetFromImage(beginImage, (scrollView.width - beginImage.size.width) / 2, 109.0)];
    [beginButton1 setImage:beginImage forState:UIControlStateNormal];
    [beginButton1 addTarget:self action:@selector(beginButton1DidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:beginButton1];
    
    self.beginLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(230.0, 0, 50.0, beginImage.size.height)];
    [self.beginLabel1 setBackgroundColor:[UIColor clearColor]];
    [self.beginLabel1 setTextColor:[UIColor grayColor]];
    [self.beginLabel1 setFont:[UIFont systemFontOfSize:14.0]];
    [beginButton1 addSubview:self.beginLabel1];
    
    NSString *startTime1 = [Master valueForKey:MSTKeyRestStart1];
    if (startTime1.length > 0) {
        [self.beginLabel1 setText:startTime1];
    } else {
        [self.beginLabel1 setText:@"12:00"];
    }
    
    UIButton *endButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [endButton1 setFrame:CGRectOffsetFromImage(endImage, (scrollView.width - endImage.size.width) / 2, beginButton1.bottom)];
    [endButton1 setImage:endImage forState:UIControlStateNormal];
    [endButton1 addTarget:self action:@selector(endButton1DidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:endButton1];
    
    self.endLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(230.0, 0, 50.0, endImage.size.height)];
    [self.endLabel1 setBackgroundColor:[UIColor clearColor]];
    [self.endLabel1 setTextColor:[UIColor grayColor]];
    [self.endLabel1 setFont:[UIFont systemFontOfSize:14.0]];
    [endButton1 addSubview:self.endLabel1];
    
    NSString *endTime1 = [Master valueForKey:MSTKeyRestEnd1];
    if (endTime1.length > 0) {
        [self.endLabel1 setText:endTime1];
    } else {
        [self.endLabel1 setText:@"13:00"];
    }
    
    UIButton *beginButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [beginButton2 setFrame:CGRectOffsetFromImage(beginImage, (scrollView.width - beginImage.size.width) / 2, 288.0)];
    [beginButton2 setImage:beginImage forState:UIControlStateNormal];
    [beginButton2 addTarget:self action:@selector(beginButton2DidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:beginButton2];
    
    self.beginLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(230.0, 0, 50.0, beginImage.size.height)];
    [self.beginLabel2 setBackgroundColor:[UIColor clearColor]];
    [self.beginLabel2 setTextColor:[UIColor grayColor]];
    [self.beginLabel2 setFont:[UIFont systemFontOfSize:14.0]];
    [beginButton2 addSubview:self.beginLabel2];
    
    NSString *startTime2 = [Master valueForKey:MSTKeyRestStart2];
    if (startTime2.length > 0) {
        [self.beginLabel2 setText:startTime2];
    } else {
        [self.beginLabel2 setText:@"--:--"];
    }
    
    UIButton *endButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [endButton2 setFrame:CGRectOffsetFromImage(endImage, (scrollView.width - endImage.size.width) / 2, beginButton2.bottom)];
    [endButton2 setImage:endImage forState:UIControlStateNormal];
    [endButton2 addTarget:self action:@selector(endButton2DidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:endButton2];
    
    self.endLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(230.0, 0, 50.0, endImage.size.height)];
    [self.endLabel2 setBackgroundColor:[UIColor clearColor]];
    [self.endLabel2 setTextColor:[UIColor grayColor]];
    [self.endLabel2 setFont:[UIFont systemFontOfSize:14.0]];
    [endButton2 addSubview:self.endLabel2];
    
    NSString *endTime2 = [Master valueForKey:MSTKeyRestEnd2];
    if (endTime2.length > 0) {
        [self.endLabel2 setText:endTime2];
    } else {
        [self.endLabel2 setText:@"--:--"];
    }

    UIImage *nextImage = nil;
    switch (self.settingType) {
        case SettingTypeInit:
            nextImage = [UIImage imageNamed:@"confirm_button"];
            break;
        case SettingTypeEdit:
            nextImage = [UIImage imageNamed:@"resetting_button"];
            break;
        case SettingTypeReEdit:
            nextImage = [UIImage imageNamed:@"save_change"];
            break;
        default:
            break;
    }
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setFrame:CGRectOffsetFromImage(nextImage, (SCREEN_WIDTH - nextImage.size.width) / 2, bgImageView.bottom - 93.0)];
    [nextButton setImage:nextImage forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:nextButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)beginButton1DidClicked:(UIButton *)button
{
    [self setCurrentLabel:self.beginLabel1];
    [self showTimerPicker];
}

- (void)endButton1DidClicked:(UIButton *)button
{
    [self setCurrentLabel:self.endLabel1];
    [self showTimerPicker];
}

- (void)beginButton2DidClicked:(UIButton *)button
{
    [self setCurrentLabel:self.beginLabel2];
    [self showTimerPicker];
}

- (void)endButton2DidClicked:(UIButton *)button
{
    [self setCurrentLabel:self.endLabel2];
    [self showTimerPicker];
}

- (void)showTimerPicker
{
    CustomPicker *picker = [CustomPicker sharedInstance];
    [picker setDelegate:self];
    [picker setPickerType:CustomPickerTypeTime5];
    [picker setShowResetButton:YES];
    if (![self.currentLabel.text isEqualToString:@"--:--"]) {
        [picker setSelectedValues:@[self.currentLabel.text]];
    }
    [[CustomPicker sharedInstance] showInView:self.view];
}

- (void)nextButtonDidClicked:(UIButton *)button
{
    NSString *startTime1 = self.beginLabel1.text;
    NSString *endTime1 = self.endLabel1.text;
    NSString *startTime2 = self.beginLabel2.text;
    NSString *endTime2 = self.endLabel2.text;
    if ([startTime1 isEqualToString:@"--:--"]) {
        startTime1 = @"";
    }
    if ([endTime1 isEqualToString:@"--:--"]) {
        endTime1 = @"";
    }
    if ([startTime2 isEqualToString:@"--:--"]) {
        startTime2 = @"";
    }
    if ([endTime2 isEqualToString:@"--:--"]) {
        endTime2 = @"";
    }
    
    BOOL complete = YES;
    NSString *errorMessage = @"休憩の設定が完了してないです。休憩しなくて大丈夫？";
    
    if ((startTime1.length > 0 && endTime1.length > 0) && (startTime2.length > 0 && endTime2.length > 0)) {
        if ([startTime1 compare:endTime1] == NSOrderedDescending || ![self isEndTime:endTime1 matchStartTime:startTime1]) {
            complete = NO;
            errorMessage = @"ごめんなさい！休憩は1時間まで設定できます。";
        }
        if ([startTime1 compare:endTime1] == NSOrderedSame) {
            complete = NO;
            errorMessage = @"おや？二つの休憩時間で重なっている時間帯がありますね。次元を超越した休憩はさすがに無理なようです。";
        }
        if ([startTime2 compare:endTime2] == NSOrderedDescending || ![self isEndTime:endTime2 matchStartTime:startTime2]) {
            complete = NO;
            errorMessage = @"ごめんなさい！休憩は1時間まで設定できます。";
        }
        if ([startTime2 compare:endTime2] == NSOrderedSame) {
            complete = NO;
            errorMessage = @"おや？二つの休憩時間で重なっている時間帯がありますね。次元を超越した休憩はさすがに無理なようです。";
        }
        if ([endTime1 compare:startTime2] == NSOrderedDescending) {
            complete = NO;
            errorMessage = @"おや？二つの休憩時間で重なっている時間帯がありますね。次元を超越した休憩はさすがに無理なようです。";
        }
        if ([endTime2 compare:startTime1] == NSOrderedAscending) {
            complete = NO;
            errorMessage = @"休憩時間２は休憩時間１より前の時間に設定できないことにしています。パッと見わかりやすいですよね。";
        }
    } else if (startTime1.length > 0 && endTime1.length > 0) {
        if ([startTime1 compare:endTime1] == NSOrderedDescending || ![self isEndTime:endTime1 matchStartTime:startTime1]) {
            complete = NO;
            errorMessage = @"ごめんなさい！休憩は1時間まで設定できます。";
        }
        if ([startTime1 compare:endTime1] == NSOrderedSame) {
            complete = NO;
            errorMessage = @"おや？二つの休憩時間で重なっている時間帯がありますね。次元を超越した休憩はさすがに無理なようです。";
        }
        if (startTime2.length > 0 || endTime2.length > 0) {
            complete = NO;
        }
    } else if (startTime2.length > 0 && endTime2.length > 0) {
        if ([startTime2 compare:endTime2] == NSOrderedDescending || ![self isEndTime:endTime2 matchStartTime:startTime2]) {
            complete = NO;
            errorMessage = @"ごめんなさい！休憩は1時間まで設定できます。";
        }
        if ([startTime2 compare:endTime2] == NSOrderedSame) {
            complete = NO;
            errorMessage = @"おや？二つの休憩時間で重なっている時間帯がありますね。次元を超越した休憩はさすがに無理なようです。";
        }
        if (startTime1.length > 0 || endTime1.length > 0) {
            complete = NO;
        }
    } else {
        complete = NO;
    }
    
    if (complete) {
        // Rest 1
        [Master saveValue:startTime1 forKey:MSTKeyRestStart1];
        [Master saveValue:endTime1 forKey:MSTKeyRestEnd1];
        // Rest 2
        [Master saveValue:startTime2 forKey:MSTKeyRestStart2];
        [Master saveValue:endTime2 forKey:MSTKeyRestEnd2];
        
        [[AppManager sharedInstance] setSettingNeedReload:YES];
        
        if (self.settingType == SettingTypeEdit || self.settingType == SettingTypeReEdit) {
            [self dismissViewControllerAnimated:YES completion:NULL];
        } else {
            HolidayViewController *holidayViewController = [[HolidayViewController alloc] init];
            [self.navigationController pushViewController:holidayViewController animated:YES];
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:errorMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    }
}

- (BOOL)isEndTime:(NSString *)endTime matchStartTime:(NSString *)startTime
{
    BOOL ret = NO;
    NSDate *startDate = [startTime localDateWithFormat:DB_DATE_HM];
    NSDate *endDate = [endTime localDateWithFormat:DB_DATE_HM];
    
    NSTimeInterval interval = [endDate timeIntervalSinceDate:startDate];
    if (interval <= 3600) {
        ret = YES;
    }
    return ret;
}

#pragma mark - CustomPickerDelegate

- (void)customPicker:(CustomPicker *)picker didSelectDone:(id)value
{
    if ([value length] == 0) {
        [self.currentLabel setText:@"--:--"];
    } else {
        [self.currentLabel setText:value];
    }
}

@end
