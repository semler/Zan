//
//  HolidayViewController.m
//  Overtime
//
//  Created by Xu Shawn on 3/6/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "HolidayViewController.h"
#import "PaymentViewController.h"
#import "HolidayCell.h"

@interface HolidayViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *selectedHolidayArray;

@end

@implementation HolidayViewController

- (id)initWithSettingType:(SettingType)settingType
{
    return [self initWithSettingType:settingType holidayType:HolidayTypeWork];
}

- (id)initWithSettingType:(SettingType)settingType holidayType:(HolidayType)holidayType
{
    self = [super init];
    if (self) {
        // Custom initialization
        _settingType = settingType;
        _holidayType = holidayType;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.selectedHolidayArray = [NSMutableArray array];
    // Master data
    NSDictionary *masterDic = [[AppManager sharedInstance] masterDic];
    
    NSString *holidayString = @"";
    switch (self.holidayType) {
        case HolidayTypeWork:
            holidayString = masterDic[MSTKeyHoliday];
            break;
        case HolidayTypeNotice:
            holidayString = masterDic[MSTKeyConfirmWeek];
            break;
        default:
            break;
    }
    NSArray *holidayArray = [holidayString componentsSeparatedByString:@","];
    
    for (NSString *item in holidayArray) {
        NSInteger realIndex = ([item integerValue] == 0 ? 7 : [item integerValue]);
        [self.selectedHolidayArray addObject:@(realIndex)];
    }
    
    UIImage *headerImage = nil;
    switch (self.settingType) {
        case SettingTypeInit:
            headerImage = [UIImage imageNamed:@"holiday_header"];
            break;
        case SettingTypeEdit:
            headerImage = [UIImage imageNamed:@"holiday_reset_header"];
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
    
    UIScrollView *scrollView = nil;
    
    if (self.holidayType == HolidayTypeWork) {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, headerImageView.bottom, SCREEN_WIDTH, SCREEN_HEIGHT - headerImageView.bottom)];
        [self.view addSubview:scrollView];
        
        UIImage *bgImage = [UIImage imageNamed:@"holiday_bg"];
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectFromImage(bgImage)];
        [bgImageView setImage:bgImage];
        [scrollView addSubview:bgImageView];
        
        [scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, bgImage.size.height)];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 68.0, scrollView.width, 357.0) style:UITableViewStylePlain];
    } else {
        UIImage *bgImage = [UIImage imageNamed:@"bg"];
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(bgImage, 0, headerImageView.bottom)];
        [bgImageView setImage:bgImage];
        [self.view addSubview:bgImageView];
        
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, headerImageView.bottom, SCREEN_WIDTH, SCREEN_HEIGHT - headerImageView.bottom - 10.0)];
        [scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, 480.0)];
        [self.view addSubview:scrollView];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 20.0, scrollView.width, scrollView.height - 20.0) style:UITableViewStylePlain];
    }

    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView registerClass:[HolidayCell class] forCellReuseIdentifier:CCIdentifier];
    [self.tableView setScrollEnabled:NO];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setRowHeight:48.0];
    [self.tableView setShowsHorizontalScrollIndicator:NO];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [self.tableView setAllowsMultipleSelection:YES];
    [scrollView addSubview:self.tableView];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
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
    [nextButton setFrame:CGRectOffsetFromImage(nextImage, (SCREEN_WIDTH - nextImage.size.width) / 2, scrollView.contentSize.height - 93.0)];
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

- (void)nextButtonDidClicked:(UIButton *)button
{
    if ((self.selectedHolidayArray.count == 0 || self.selectedHolidayArray.count > 3) && self.holidayType == HolidayTypeWork) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"休日設定が完了してないです！少なくとも週1回の休日を設定してみよう。" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    } else {
        NSMutableString *weekString = [NSMutableString string];
        NSMutableString *holidayString = [NSMutableString string];
        
        if (self.selectedHolidayArray.count > 0) {
            for (NSInteger i = 1; i <= 7; i++) {
                if ([self.selectedHolidayArray containsObject:@(i)]) {
                    NSInteger realIndex = (i == 7 ? 0 : i);
                    [holidayString appendFormat:@"%d,", (int)realIndex];
                } else {
                    NSInteger realIndex = (i == 7 ? 0 : i);
                    [weekString appendFormat:@"%d,", (int)realIndex];
                }
            }
            if (weekString.length > 0) {
                [weekString deleteCharactersInRange:NSMakeRange(weekString.length - 1, 1)];
            }
            if (holidayString.length > 0) {
                [holidayString deleteCharactersInRange:NSMakeRange(holidayString.length - 1, 1)];
            }
        } else {
            [weekString appendString:@"0,1,2,3,4,5,6"];
        }
        
        switch (self.holidayType) {
            case HolidayTypeWork: {
                
                if (self.selectedHolidayArray.count == 1) {
                    NSInteger weekendIn = [self.selectedHolidayArray[0] integerValue];
                    if (weekendIn == 7) {
                        weekendIn = 0;
                    }
                    [Master saveValue:[NSString stringWithFormat:@"%d", (int)weekendIn] forKey:MSTKeyWeekendIn];
                    [Master saveValue:@"" forKey:MSTKeyWeekendOut];
                } else if (self.selectedHolidayArray.count == 2) {
                    NSInteger weekendOut = [self.selectedHolidayArray[0] integerValue];
                    if (weekendOut == 7) {
                        weekendOut = 0;
                    }
                    [Master saveValue:[NSString stringWithFormat:@"%d", (int)weekendOut] forKey:MSTKeyWeekendOut];
                    
                    NSInteger weekendIn = [self.selectedHolidayArray[1] integerValue];
                    if (weekendIn == 7) {
                        weekendIn = 0;
                    }
                    [Master saveValue:[NSString stringWithFormat:@"%d", (int)weekendIn] forKey:MSTKeyWeekendIn];
                }
                
                [Master saveValue:holidayString forKey:MSTKeyHoliday];
                [Master saveValue:weekString forKey:MSTKeyWeekday];
                break;
            }
            case HolidayTypeNotice:
                [Master saveValue:holidayString forKey:MSTKeyConfirmWeek];
                break;
            default:
                break;
        }
        
        NSString *paymentMonth = MASTER(MSTKeyPaymentMonth);
        if (paymentMonth.length > 0) {
            NSInteger hourMoney = [AppManager calculateHourMoney:paymentMonth];
            [Master saveValue:[NSString stringWithFormat:@"%d", (int)hourMoney] forKey:MSTKeyPaymentHour];
        }
        
        [[AppManager sharedInstance] setSettingNeedReload:YES];
        
        if (self.settingType == SettingTypeEdit || self.settingType == SettingTypeReEdit) {
            [self dismissViewControllerAnimated:YES completion:NULL];
        } else {
            PaymentViewController *paymentViewController = [[PaymentViewController alloc] init];
            [self.navigationController pushViewController:paymentViewController animated:YES];
        }
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HolidayCell *cell = [tableView dequeueReusableCellWithIdentifier:CCIdentifier];
    
    NSString *imageName = [NSString stringWithFormat:@"holiday_week%d", (int)indexPath.row + 1];
    UIImage *image = [UIImage imageNamed:imageName];
    [cell.imageView setImage:image];
    
    NSNumber *week = @(indexPath.row + 1);
    if ([self.selectedHolidayArray containsObject:week]) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *week = @(indexPath.row + 1);
    if (![self.selectedHolidayArray containsObject:week]) {
        [self.selectedHolidayArray addObject:week];
        
        if (self.holidayType == HolidayTypeWork && self.selectedHolidayArray.count > 2) {
            [self.selectedHolidayArray removeObjectAtIndex:0];
            [self.tableView reloadData];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *week = @(indexPath.row + 1);
    if ([self.selectedHolidayArray containsObject:week]) {
        [self.selectedHolidayArray removeObject:week];
    }
}

@end
