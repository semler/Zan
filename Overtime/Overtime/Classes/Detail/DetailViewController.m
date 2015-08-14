//
//  DetailViewController.m
//  Overtime
//
//  Created by Xu Shawn on 2/24/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "DetailViewController.h"
#import "DetailCell.h"
#import "TutorialView.h"
#import "Day.h"
#import "iCloudUtils.h"
#import "WebViewController.h"
#import "DetailMapView.h"
#import "DetailView.h"

#define ActionSheetTagStart 1
#define ActionSheetTagEnd 2

@interface DetailViewController () <UITableViewDataSource, UITableViewDelegate, DetailCellDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIActionSheetDelegate, DetailMapViewDelegate, KeyboardBarDelegate>

@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, assign) NSInteger heldDays;
@property (nonatomic, strong) Month *month;
@property (nonatomic, strong) UIView *pickerContainer;
@property (nonatomic, strong) UILabel *pickerDateLabel;
@property (nonatomic, strong) UIPickerView *datePicker;
@property (nonatomic, strong) UILabel *startLabel;
@property (nonatomic, strong) UILabel *endLabel;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIButton *endButton;
@property (nonatomic, strong) DetailMapView *mapView;
@property (nonatomic, assign) BOOL settingStartTime;
@property (nonatomic, strong) Day *editingDay;
@property (nonatomic, copy) NSString *editingStartDate;
@property (nonatomic, copy) NSString *editingEndDate;
@property (nonatomic, copy) NSString *editingYMDDate;
@property (nonatomic, assign) NSInteger toSelectedIndex;
@property (nonatomic, strong) IBOutlet UIView *blockView;
@property (nonatomic, assign) NSInteger editingIndex;
@property (nonatomic, assign) EditingType editingType;
@property (nonatomic, assign) NSInteger memoIndex;
@property (nonatomic, strong) NSDate *maxDate;
@property (nonatomic, strong) NSDateComponents *maxDateComponent;
@property (nonatomic, assign) NSInteger todayIndex;

@end

@implementation DetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _cellIdentifier = @"DetailCell";
        
        _editingIndex = -1;
        _editingType = EditingTypeNone;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReloadDataNotification:) name:ReloadDataNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReloadDataNotification:) name:ReloadDetailDataNotification object:nil];
    
    DetailView *detailView = (DetailView *)self.view;
    [detailView setDelegate:self];
    [detailView setKeyboardBarType:KeyboardBarTypeDetail];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    // Map
    self.mapView = [[DetailMapView alloc] initWithFrame:CGRectMake(0, 185.0, SCREEN_WIDTH, SCREEN_HEIGHT - 185.0)];
    [self.mapView setDelegate:self];
    [self.mapView setHidden:YES];
    [self.view addSubview:self.mapView];
    
    // Log
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView registerNib:[UINib nibWithNibName:self.cellIdentifier bundle:nil] forCellReuseIdentifier:self.cellIdentifier];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 32.0)];
    [headerView setBackgroundColor:[UIColor blackColor]];
    
    UIImage *bgImage = [UIImage imageNamed:@"detail_header"];
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectFromImage(bgImage)];
    [bgImageView setImage:bgImage];
    [headerView addSubview:bgImageView];
    
    UILabel *onDutyLabel = [[UILabel alloc] initWithFrame:CGRectMake(132.0, 0, 30.0, headerView.height)];
    [onDutyLabel setFont:[UIFont systemFontOfSize:14.0]];
    [onDutyLabel setBackgroundColor:[UIColor clearColor]];
    [onDutyLabel setTextColor:[UIColor whiteColor]];
    [onDutyLabel setTextAlignment:NSTextAlignmentCenter];
    [onDutyLabel setText:@"出勤"];
    [headerView addSubview:onDutyLabel];
    
    UILabel *offDutyLabel = [[UILabel alloc] initWithFrame:CGRectMake(250.0, 0, 30.0, headerView.height)];
    [offDutyLabel setFont:[UIFont systemFontOfSize:14.0]];
    [offDutyLabel setBackgroundColor:[UIColor clearColor]];
    [offDutyLabel setTextColor:[UIColor whiteColor]];
    [offDutyLabel setTextAlignment:NSTextAlignmentCenter];
    [offDutyLabel setText:@"退勤"];
    [headerView addSubview:offDutyLabel];
    
    [self.tableView setTableHeaderView:headerView];
    
    if (![[AppManager sharedInstance] oldUser]) {
        // Block
        [self.tableView setTableFooterView:self.blockView];
    }
    
    UIImage *footerImage = [UIImage imageNamed:@"chart_footer"];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectOffsetFromImage(footerImage, 0, SCREEN_HEIGHT - 52.0)];
    
    UIImageView *footerImageView = [[UIImageView alloc] initWithFrame:footerView.bounds];
    [footerImageView setImage:footerImage];
    [footerView addSubview:footerImageView];
    
    UIImage *homeImage = [UIImage imageNamed:@"home"];
    UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [homeButton setFrame:CGRectOffsetFromImage(homeImage, 5.0, 10.0)];
    [homeButton setImage:homeImage forState:UIControlStateNormal];
    [homeButton addTarget:self action:@selector(homeButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:homeButton];
    
    UIImage *currentImage = [UIImage imageNamed:@"current_month_button"];
    UIButton *currentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [currentButton setFrame:CGRectOffsetFromImage(currentImage, 92.0, 10.0)];
    [currentButton setImage:currentImage forState:UIControlStateNormal];
    [currentButton addTarget:self action:@selector(currentButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:currentButton];
    
    [self.view addSubview:footerView];
    
    // Gesture
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
    
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.detailShowType == DetailShowTypeChart) {
        NSInteger days = [self.selectedDate daysFromDate:self.maxDate];
        NSInteger index = self.heldDays - days - 1;
        if (index >= 0 && index < self.heldDays) {
            [self setToSelectedIndex:index];
            [self reloadData];
        }
        
        // Restore show type
        [self setDetailShowType:DetailShowTypeDefault];
    } else {
        if ([[AppManager sharedInstance] overtimeType] != OvertimeTypeNone && self.detailShowType != DetailShowTypeDefault) {
            [self setEditingDay:[[AppManager sharedInstance] currentDay]];
        } else {
            // Tutorial
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            if (![userDefaults boolForKey:TutorialDetailShowed]) {
                [TutorialView showWithTutorialType:TutorialTypeDetail];
                [userDefaults setBool:YES forKey:TutorialDetailShowed];
                [userDefaults synchronize];
            }
        }
        
        // From other page display
        if (self.detailShowType != DetailShowTypeDefault && self.editingDay) {
            // Editing date
            NSDate *date = [self.editingDay.ymdDate localDateWithFormat:DB_DATE_YMD];
            // Index
            NSInteger days = [date daysFromDate:self.maxDate];
            NSInteger index = self.heldDays - days - 1;
            if (index >= 0 && index < self.heldDays) {
                [self setToSelectedIndex:index];
                [self reloadData];
            }
            
            [self setEditingStartDate:self.editingDay.start_date];
            [self setEditingEndDate:self.editingDay.end_date];
            [self setEditingYMDDate:self.editingDay.ymdDate];
            
            // Show data picker
            [self showDatePicker];
            // Restore show type
            [self setDetailShowType:DetailShowTypeDefault];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Gesture

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture
{
    [self.view resignFirstResponder];
    // Enable user interface
    [self enableUserInterface:YES];
    
    if (self.editingIndex >= 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.editingIndex inSection:0];
        
        [self.tableView beginUpdates];
        [self setEditingIndex:-1];
        [self setEditingType:EditingTypeNone];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

#pragma mark - Private

- (void)reloadData
{
    self.editingType = EditingTypeNone;

    // Max
    self.maxDate = [DateUtils maxDate];
    self.maxDateComponent = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:self.maxDate];
    
    if ([[AppManager sharedInstance] oldUser]) {
        // Min
        NSDate *minDate = [DateUtils minDate];
        // Calculate days
        NSInteger days = [minDate daysFromDate:self.maxDate] + 1;
        if (days <= 0) {
            self.heldDays = 1;
        } else {
            self.heldDays = days;
        }
        [self setTodayIndex:self.heldDays - 1];
    } else {
        self.heldDays = [[AppManager sharedInstance] heldDays];
        if (self.heldDays <= 0) {
            self.heldDays = 1;
        }
        // Current
        NSDate *currentDate = [[AppManager sharedInstance] currentDate];
        NSDate *logicalDate = [currentDate logicalDate];
        
        // Calculate today index
        NSInteger daysFromToday = [logicalDate daysFromDate:self.maxDate];
        self.todayIndex = self.heldDays - daysFromToday - 1;
    }

    if (self.toSelectedIndex  == 0) {
        [self setToSelectedIndex:self.todayIndex];
    }
    
    double money = [[[AppManager sharedInstance] era] money];
    double otHours = [[[AppManager sharedInstance] era] otHours];
    NSDictionary *userInfo = @{DataUpdateKeyMoney: @(money), DataUpdateKeyHour: @(otHours)};
    [[NSNotificationCenter defaultCenter] postNotificationName:DetailDataUpdateNotification object:nil userInfo:userInfo];
    
    [self displayControls];
}

- (void)displayControls
{
    [self.tableView reloadData];
    if (self.toSelectedIndex >= 0) {
        NSIndexPath *scrollToIndexPath = [NSIndexPath indexPathForRow:self.toSelectedIndex inSection:0];
        [self.tableView scrollToRowAtIndexPath:scrollToIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [self setToSelectedIndex:-1];
    }
}

//- (void)showModifyAlertView
//{
//    if (!self.alertView) {
//        self.alertView = [[UIView alloc] initWithFrame:self.view.bounds];
//        [self.view addSubview:self.alertView];
//        
//        UIImage *alertImage = [UIImage imageNamed:@"detail_alert_bg"];
//        UIImageView *alertImageView = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(alertImage, (self.view.width - alertImage.size.width) / 2, 184.0)];
//        [alertImageView setImage:alertImage];
//        [alertImageView setUserInteractionEnabled:YES];
//        [self.alertView addSubview:alertImageView];
//        
//        self.alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(35.0, 85.0, 205.0, 50.0)];
//        [self.alertLabel setBackgroundColor:[UIColor clearColor]];
//        [self.alertLabel setTextColor:[UIColor whiteColor]];
//        [self.alertLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
//        [self.alertLabel setNumberOfLines:0];
//        [self.alertLabel setAdjustsFontSizeToFitWidth:YES];
//        [alertImageView addSubview:self.alertLabel];
//        
//        UIImage *okImage = [UIImage imageNamed:@"ok"];
//        UIButton *okButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [okButton setFrame:CGRectOffsetFromImage(okImage, (alertImageView.width - okImage.size.width) / 2, 148.0)];
//        [okButton setImage:okImage forState:UIControlStateNormal];
//        [okButton addTarget:self action:@selector(alertOKButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [alertImageView addSubview:okButton];
//    }
//    
//    NSDate *currentDate = [[AppManager sharedInstance] currentDate];
//    NSDateComponents *lastDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:currentDate];
//    [lastDateComponents setDay:lastDateComponents.day - 1];
//    
//    NSDate *lastDate = [[NSCalendar currentCalendar] dateFromComponents:lastDateComponents];
//    Day *lastDay = [[[AppManager sharedInstance] era] dayFromDate:lastDate];
//    NSInteger hour = 0;
//    if (lastDay) {
//        NSDate *now = [NSDate date];
//        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:now];
//        
//        NSDate *deadlineDate = nil;
//        if (dateComponents.hour < 5) {
//            [dateComponents setHour:5];
//            [dateComponents setMinute:0];
//            [dateComponents setSecond:0];
//
//            deadlineDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
//        } else if (dateComponents.hour >= 5) {
//            [dateComponents setDay:dateComponents.day + 1];
//            [dateComponents setHour:5];
//            [dateComponents setMinute:0];
//            [dateComponents setSecond:0];
//
//            deadlineDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
//        }
//        
//        NSTimeInterval timeInterval = [deadlineDate timeIntervalSinceDate:now];
//        hour = timeInterval / 3600.0;
//        if (hour < 0) {
//            hour = 0;
//        }
//    }
//    if (hour > 0 && hour < 24) {
//        NSString *alertString = [NSString stringWithFormat:@"昨日の打刻を修正することができるのは残り%ld時間です", (long)hour];
//        [self.alertLabel setText:alertString];
//        [self.alertView setHidden:NO];
//        [self.alertView setAlpha:0.0];
//        [UIView animateWithDuration:0.3 animations:^{
//            [self.alertView setAlpha:1.0];
//        }];
//    } else {
//        [self.alertView setHidden:YES];
//    }
//}
//
//- (void)alertOKButtonDidClicked:(UIButton *)button
//{
//    [self.alertView setAlpha:1.0];
//    [UIView animateWithDuration:0.3 animations:^{
//        [self.alertView setAlpha:0.0];
//    } completion:^(BOOL finished) {
//        [self.alertView setHidden:YES];
//    }];
//}

- (void)showDatePicker
{
    if (!self.pickerContainer) {
        self.pickerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - 184.0)];
        [self.pickerContainer setBackgroundColor:Color(219.0, 219.0, 219.0, 0.97)];
        [self.view addSubview:self.pickerContainer];
        
        self.pickerDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.pickerContainer.width, self.pickerContainer.height - 60.0 - 216.0)];
        [self.pickerDateLabel setBackgroundColor:[UIColor blackColor]];
        [self.pickerDateLabel setTextColor:[UIColor whiteColor]];
        [self.pickerDateLabel setTextAlignment:NSTextAlignmentCenter];
        [self.pickerDateLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
        [self.pickerContainer addSubview:self.pickerDateLabel];
        
        UIView *buttonContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.pickerDateLabel.bottom, self.pickerContainer.width, 60.0)];
        [buttonContainer setBackgroundColor:Color(219.0, 219.0, 219.0, 1.0)];
        [self.pickerContainer addSubview:buttonContainer];
        
        UIImage *cancelImage = [UIImage imageNamed:@"work_cancel"];
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setFrame:CGRectOffsetFromImage(cancelImage, 5.0, (buttonContainer.height - cancelImage.size.height) / 2)];
        [cancelButton setImage:cancelImage forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [buttonContainer addSubview:cancelButton];
        
        UIImage *doneImage = [UIImage imageNamed:@"work_done"];
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [doneButton setFrame:CGRectOffsetFromImage(doneImage, buttonContainer.width - doneImage.size.width - 5.0, (buttonContainer.height - doneImage.size.height) / 2)];
        [doneButton setImage:doneImage forState:UIControlStateNormal];
        [doneButton addTarget:self action:@selector(doneButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [buttonContainer addSubview:doneButton];
        
        UIImage *startImage = [UIImage imageNamed:@"work_start_on"];
        self.startButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.startButton setFrame:CGRectOffsetFromImage(startImage, 96.0, (buttonContainer.height - startImage.size.height) / 2.0)];
        [self.startButton setImage:startImage forState:UIControlStateNormal];
        [self.startButton addTarget:self action:@selector(startButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [buttonContainer  addSubview:self.startButton];
        
        self.startLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20.0, self.startButton.width, 20.0)];
        [self.startLabel setTextColor:[UIColor whiteColor]];
        [self.startLabel setFont:[UIFont systemFontOfSize:14.0]];
        [self.startLabel setTextAlignment:NSTextAlignmentCenter];
        [self.startLabel setBackgroundColor:[UIColor clearColor]];
        [self.startButton addSubview:self.startLabel];
        
        UIImage *endImage = [UIImage imageNamed:@"work_end_off"];
        self.endButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.endButton setFrame:CGRectOffsetFromImage(endImage, 166.0, (buttonContainer.height - endImage.size.height) / 2.0)];
        [self.endButton setImage:endImage forState:UIControlStateNormal];
        [self.endButton addTarget:self action:@selector(endButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [buttonContainer  addSubview:self.endButton];
        
        self.endLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20.0, self.endButton.width, 20.0)];
        [self.endLabel setTextColor:[UIColor whiteColor]];
        [self.endLabel setFont:[UIFont systemFontOfSize:14.0]];
        [self.endLabel setTextAlignment:NSTextAlignmentCenter];
        [self.endLabel setBackgroundColor:[UIColor clearColor]];
        [self.endButton addSubview:self.endLabel];
        
        self.datePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 216.0)];
        self.datePicker.top = buttonContainer.bottom;
        [self.datePicker setDelegate:self];
        [self.datePicker setDataSource:self];
        [self.datePicker setShowsSelectionIndicator:YES];
        [self.pickerContainer addSubview:self.datePicker];
    }
    [UIView animateWithDuration:0.3 animations:^{
        [self.pickerContainer setTop:184.0];
    }];
    [self.pickerDateLabel setText:[self.editingDay.ymdDate dateStringWithFomat:@"yyyy年MM月dd日" fromFormat:DB_DATE_YMD]];
    
    NSDate *currentDate = [[AppManager sharedInstance] currentDate];
    NSDateComponents *logicalDateComponents = [currentDate logicalDateComponents];
    
    if ([[AppManager sharedInstance] isWorking] &&
        [self.editingDay.dayOfDate integerValue] == logicalDateComponents.day) {
        [self.endButton setHidden:YES];
    } else {
        [self.endButton setHidden:NO];
    }
    if (self.detailShowType == DetailShowTypeStart) {
        [self setSettingStartTime:YES];
    } else if (self.detailShowType == DetailShowTypeEnd) {
        [self setSettingStartTime:NO];
    }
    
    [self updateButtonStatus];
    
    if (self.editingDay) {
        [self.startLabel setText:[self.editingStartDate displayTime]];
        [self.endLabel setText:[self.editingEndDate displayTime]];
    }
//    [self selectNowDate];
}

- (void)cancelButtonDidClicked:(UIButton *)button
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.pickerContainer setTop:SCREEN_HEIGHT];
    }];
    if (self.editingType == EditingTypeNewTime) {
        Era *era = [[AppManager sharedInstance] era];
        NSString *yearKey = self.editingDay.startTime.belong_year;
        Year *year = [era.yearDic objectForKey:yearKey];
        NSString *monthKey = self.editingDay.startTime.belong_month;
        Month *month = [year.monthDic objectForKey:monthKey];
        [month.dayDic removeObjectForKey:self.editingDay.startTime.belong_day];
        [month.dayArray removeObject:self.editingDay];
    }
}

- (void)doneButtonDidClicked:(UIButton *)button
{
    if ([self settingDateWithStartFlag:self.settingStartTime]) {
        if (self.settingStartTime) {
            [self.editingDay setStart_date:self.editingStartDate recordType:RecordTypeManual];
        } else {
            [self.editingDay setEnd_date:self.editingEndDate recordType:RecordTypeManual];
        }

        [self.editingDay saveAll];
        [self.editingDay calculateData];
        [self.tableView reloadData];
        
        // Upload
        [iCloudUtils uploadFileToiCloud];
        
        [UIView animateWithDuration:0.3 animations:^{
            [self.pickerContainer setTop:SCREEN_HEIGHT];
        }];
        
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        [hud setRemoveFromSuperViewOnHide:YES];
        [hud showAnimated:YES whileExecutingBlock:^{
            [[[AppManager sharedInstance] era] recalculateData];
        } completionBlock:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:ReloadDataNotification object:nil];
        }];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"おや！？出勤時刻が退勤時刻より後になっていますね。そして、時は動き出すわけですね。" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    }
}

- (void)updateButtonStatus
{
    if (self.settingStartTime) {
        [self selectPickerDate:self.editingStartDate];
        [self.startButton setImage:[UIImage imageNamed:@"work_start_on"] forState:UIControlStateNormal];
        [self.endButton setImage:[UIImage imageNamed:@"work_end_off"] forState:UIControlStateNormal];
    } else {
        [self selectPickerDate:self.editingEndDate];
        [self.startButton setImage:[UIImage imageNamed:@"work_start_off"] forState:UIControlStateNormal];
        [self.endButton setImage:[UIImage imageNamed:@"work_end_on"] forState:UIControlStateNormal];
    }
}

- (void)startButtonDidClicked:(UIButton *)button
{
    if ([self settingDateWithStartFlag:self.settingStartTime]) {
        [self setSettingStartTime:YES];
        [self updateButtonStatus];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"おや！？出勤時刻が退勤時刻より後になっていますね。そして、時は動き出すわけですね。" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    }
}

- (void)endButtonDidClicked:(UIButton *)button
{
    if ([self settingDateWithStartFlag:self.settingStartTime]) {
        [self setSettingStartTime:NO];
        [self updateButtonStatus];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"おや！？出勤時刻が退勤時刻より後になっていますね。そして、時は動き出すわけですね。" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    }
}

- (BOOL)settingDateWithStartFlag:(BOOL)isStartTime
{
    BOOL complete = YES;
    
    if (isStartTime) {
        NSString *start_date = [self selectedPickerDate:self.editingStartDate belongDate:self.editingYMDDate];
        if ([self.editingEndDate compare:start_date] == NSOrderedDescending) {
            [self setEditingStartDate:start_date];
        } else {
            complete = NO;
        }
    } else {
        NSString *end_date = [self selectedPickerDate:self.editingEndDate belongDate:self.editingYMDDate];
        if ([end_date compare:self.editingStartDate] == NSOrderedDescending) {
            [self setEditingEndDate:end_date];
        } else {
            complete = NO;
        }
    }
    
    return complete;
}

- (IBAction)previousButtonDidClicked:(id)sender
{
    NSIndexPath *indexPath = [[self.tableView indexPathsForVisibleRows] lastObject];
    
    NSDate *topDate = [self dateForRow:0];
    NSDate *currentDate = [self dateForRow:indexPath.row];
    
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:currentDate];
    [dateComponents setMonth:dateComponents.month - 1];
    [dateComponents setDay:1];
    NSDate *nextDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    
    NSInteger days = [topDate daysFromDate:nextDate];
    if (days < 0) {
        days = 0;
    }
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:days inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (IBAction)nextButtonDidClicked:(id)sender
{
    NSIndexPath *indexPath = [[self.tableView indexPathsForVisibleRows] lastObject];
    
    NSDate *topDate = [self dateForRow:0];
    NSDate *currentDate = [self dateForRow:indexPath.row];
    
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:currentDate];
    [dateComponents setMonth:dateComponents.month + 1];
    [dateComponents setDay:1];
    NSDate *previousDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    
    NSInteger days = [topDate daysFromDate:previousDate];
    if (days > self.heldDays) {
        days = self.heldDays - 1;
    }
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:days inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)homeButtonDidClicked:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(forwardToHomeViewFromDetailView:)]) {
        [self.delegate forwardToHomeViewFromDetailView:self];
    }
}

- (void)currentButtonDidClicked:(UIButton *)button
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.todayIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (IBAction)blockButtonDidClicked:(id)sender
{
    NSString *urlString = [BASE_URL stringByAppendingPathComponent:@"event"];
    WebViewController *webViewController = [[WebViewController alloc] initWithTitle:@"記録期間の拡張" URLString:urlString webVCType:WebVCTypeTask];
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - DetailMapViewDelegate

- (void)detailMapViewBackToHomeView:(DetailMapView *)mapView
{
    [UIView animateWithDuration:0.5 animations:^{
        [self.mapView setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self.mapView setHidden:YES];
    }];
}

#pragma mark - Notification

- (void)handleReloadDataNotification:(NSNotification *)notification
{
    [self reloadData];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editingType == EditingTypeMemo && indexPath.row == self.editingIndex) {
        return 115.0;
    } else {
        return 45.0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.heldDays;
}

- (NSDate *)dateForRow:(NSInteger)row
{
    NSDateComponents *dateComponents = [self.maxDateComponent copy];
    [dateComponents setDay:dateComponents.day - self.heldDays + row + 1];
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    return date;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    [cell setDelegate:self];
    
    if (indexPath.row % 2 == 0) {
        [cell.bgImageView setImage:[UIImage imageNamed:@"detail_cell_bg1"]];
    } else {
        [cell.bgImageView setImage:[UIImage imageNamed:@"detail_cell_bg2"]];
    }
    
    NSDate *iDate = [self dateForRow:indexPath.row];
    NSString *dayText = [iDate localStringWithFormat:@"MM/dd"];
    NSString *weekText = [iDate localWeekdayString];
    [cell setDate:iDate];
    [cell.dayLabel setText:dayText];
    [cell.weekLabel setText:weekText];
    
    if ([cell.weekLabel.text isEqualToString:@"土"]) {
        [cell.weekLabel setTextColor:[UIColor colorWithRed:0.2 green:0.47 blue:0.74 alpha:1]];
    } else if ([cell.weekLabel.text isEqualToString:@"日"]) {
        [cell.weekLabel setTextColor:[UIColor colorWithRed:0.94 green:0.29 blue:0.29 alpha:1]];
    } else {
        [cell.weekLabel setTextColor:[UIColor whiteColor]];
    }

    Day *iDay = nil;
    
    if (self.todayIndex == indexPath.row) {
        iDay = [[AppManager sharedInstance] currentDay];
        if (iDay) {
            [cell setStartTime:[iDay.start_date displayTime]];
            
            if (![[AppManager sharedInstance] isWorking]) {
                [cell setEndTime:[iDay.end_date displayTime]];
            } else {
                [cell.endButton setHidden:YES];
            }
        } else {
            [cell.startButton setHidden:YES];
            [cell.endButton setHidden:YES];
        }
    } else {
        iDay = [[[AppManager sharedInstance] era] dayFromDate:iDate];
        [cell setStartTime:[iDay.start_date displayTime]];
        [cell setEndTime:[iDay.end_date displayTime]];
    }
    [cell setDay:iDay];
    
    if (indexPath.row > self.todayIndex) {
        [cell.startButton setHidden:YES];
        [cell.endButton setHidden:YES];
    }
    
    // Memo View
    if (self.editingType == EditingTypeMemo && self.editingIndex == indexPath.row) {
        [cell.memoView setHidden:NO];
    }
    // Memo Text
    if (iDay.memo_txt.length > 0) {
        [cell setMemoText:iDay.memo_txt];
        [cell.memoIcon setHidden:NO];
    }
    
    if (iDay.start_type == RecordTypeGPS || iDay.start_type == RecordTypeAuto) {
        [cell.startIcon setImage:[UIImage imageNamed:@"icon_gps"]];
    } else {
        [cell.startIcon setImage:[UIImage imageNamed:@"icon_pen"]];
    }
    
    if (iDay.end_type == RecordTypeGPS || iDay.end_type == RecordTypeAuto) {
        [cell.endIcon setImage:[UIImage imageNamed:@"icon_gps"]];
    } else {
        [cell.endIcon setImage:[UIImage imageNamed:@"icon_pen"]];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailCell *detailCell = (DetailCell *)cell;
    [self.dateLabel setText:[detailCell.date localStringWithFormat:DATE_FORMAT]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [tableView beginUpdates];
    
    if (self.editingType == EditingTypeMemo && self.memoIndex == indexPath.row) {
        [self setEditingIndex:-1];
        [self setEditingType:EditingTypeNone];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [tableView endUpdates];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.editingType == EditingTypeMemo && self.editingIndex != -1) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.editingIndex inSection:0];
        [self.tableView beginUpdates];
        [self setEditingIndex:-1];
        [self setEditingType:EditingTypeNone];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

#pragma mark - DetailCellDelegate

- (BOOL)hasStartLocationOnDay:(Day *)day
{
    if (day.start_type == RecordTypeGPS && day.start_latitude > 0 && day.start_longitude > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)hasEndLocationOnDay:(Day *)day
{
    if (day.end_type == RecordTypeGPS && day.end_latitude > 0 && day.end_longitude > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)detailCell:(DetailCell *)detailCell startButtonDidClicked:(UIButton *)button
{
    if (detailCell.startLabel.text.length > 0) {
        if ([self hasStartLocationOnDay:detailCell.day]) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"キャンセル" destructiveButtonTitle:nil otherButtonTitles:@"出勤時刻を修正する", @"出勤位置を確認する", @"メモを編集する", nil];
            [actionSheet setTag:ActionSheetTagStart];
            [actionSheet showInView:self.view];
        } else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"キャンセル" destructiveButtonTitle:nil otherButtonTitles:@"出勤時刻を修正する", @"メモを編集する", nil];
            [actionSheet setTag:ActionSheetTagStart];
            [actionSheet showInView:self.view];
        }
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:detailCell];
        [self setEditingIndex:indexPath.row];
    } else {
        [self setEditingType:EditingTypeNewTime];
        
        [self setSettingStartTime:YES];
        
        // New day
        Era *era = [[AppManager sharedInstance] era];
        Time *time = [Time timeFromDate:detailCell.date];
        Day *day = [era addNewDay:time withDate:detailCell.date];
        
        [self setEditingDay:day];
        [self setEditingStartDate:day.start_date];
        [self setEditingEndDate:day.end_date];
        [self setEditingYMDDate:day.ymdDate];
        [self showDatePicker];
    }
}

- (void)detailCell:(DetailCell *)detailCell endButtonDidClicked:(UIButton *)button
{
    if (detailCell.endLabel.text.length > 0) {
        if ([self hasEndLocationOnDay:detailCell.day]) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"キャンセル" destructiveButtonTitle:nil otherButtonTitles:@"退勤時刻を修正する", @"退勤位置を確認する", @"メモを編集する", nil];
            [actionSheet setTag:ActionSheetTagEnd];
            [actionSheet showInView:self.view];
        } else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"キャンセル" destructiveButtonTitle:nil otherButtonTitles:@"退勤時刻を修正する", @"メモを編集する", nil];
            [actionSheet setTag:ActionSheetTagEnd];
            [actionSheet showInView:self.view];
        }
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:detailCell];
        [self setEditingIndex:indexPath.row];
    } else {
        [self setEditingType:EditingTypeNewTime];
        
        [self setSettingStartTime:NO];
        
        // New day
        Era *era = [[AppManager sharedInstance] era];
        Time *time = [Time timeFromDate:detailCell.date];
        Day *day = [era addNewDay:time withDate:detailCell.date];
        
        [self setEditingDay:day];
        [self setEditingStartDate:day.start_date];
        [self setEditingEndDate:day.end_date];
        [self setEditingYMDDate:day.ymdDate];
        [self showDatePicker];
    }
}

- (void)detailCell:(DetailCell *)detailCell memoInputDidStart:(NSString *)text
{
    if (!self.view.isFirstResponder) {
        DetailView *detailView = (DetailView *)self.view;
        [detailView setInitialText:text];
        [self.view becomeFirstResponder];
        // Disable user interface
        [self enableUserInterface:NO];
    }
}

- (void)detailCell:(DetailCell *)detailCell memoButtonDidClicked:(UIButton *)button
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:detailCell];
    if (self.editingType == EditingTypeMemo && self.memoIndex == indexPath.row) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.editingIndex inSection:0];
        
        [self.tableView beginUpdates];
        [self setEditingIndex:-1];
        [self setEditingType:EditingTypeNone];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    } else {
        [self showMemoAtIndex:indexPath.row];
    }
}

#pragma mark - KeyboardBarDelegate 

- (void)keyboardBar:(KeyboardBar *)keyboardBar inputDidFinished:(NSString *)text
{
    if (text.length > 30) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"メモは30文字まで入力できます。" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    } else {
        [self.view resignFirstResponder];
        // Enable user interface
        [self enableUserInterface:YES];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.editingIndex inSection:0];
        DetailCell *detailCell = (DetailCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [detailCell.day setMemo_txt:text];
        [detailCell setMemoText:text];
    }
}

- (void)enableUserInterface:(BOOL)enabled
{
    if (enabled) {
        [self.tableView setUserInteractionEnabled:YES];
        [self.previousButton setUserInteractionEnabled:YES];
        [self.nextButton setUserInteractionEnabled:YES];
    } else {
        [self.tableView setUserInteractionEnabled:NO];
        [self.previousButton setUserInteractionEnabled:NO];
        [self.nextButton setUserInteractionEnabled:NO];
    }
}

- (BOOL)isEditable:(NSString *)dateString
{
    BOOL ret = NO;
    
    if (dateString.length > 0) {
        NSDate *date = [dateString localDateWithFormat:DB_DATE_YMD];
        
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
        
        NSDateComponents *nowDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[NSDate date]];
        
        if (nowDateComponents.hour < 5) {
            [nowDateComponents setDay:(nowDateComponents.day - 2)];
        } else {
            [nowDateComponents setDay:(nowDateComponents.day - 1)];
        }
        
        NSDate *lastDate = [[NSCalendar currentCalendar] dateFromComponents:nowDateComponents];
        NSDateComponents *lastDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:lastDate];
        if (dateComponents.year == lastDateComponents.year && dateComponents.month == lastDateComponents.month && dateComponents.day == lastDateComponents.day) {
            ret = YES;
        }
    }
    
    return ret;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.editingIndex inSection:0];
    DetailCell *detailCell = (DetailCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    Day *day = detailCell.day;
    BOOL hasLocation = NO;
    
    if (actionSheet.tag == ActionSheetTagStart && [self hasStartLocationOnDay:detailCell.day]) {
        hasLocation = YES;
    } else if (actionSheet.tag == ActionSheetTagEnd && [self hasEndLocationOnDay:detailCell.day]) {
        hasLocation = YES;
    }
    
    switch (buttonIndex) {
        case 0: {
            [self setEditingType:EditingTypeEditTime];

            if (actionSheet.tag == ActionSheetTagStart) {
                [self setSettingStartTime:YES];
            } else if (actionSheet.tag == ActionSheetTagEnd) {
                [self setSettingStartTime:NO];
            }
            
            [self setEditingDay:day];
            [self setEditingStartDate:day.start_date];
            [self setEditingEndDate:day.end_date];
            [self setEditingYMDDate:day.ymdDate];
            [self showDatePicker];
            break;
        }
        case 1: {
            if (hasLocation) {
                [self setEditingType:EditingTypeLocation];
                
                // Location
                NSString *dateStr = [detailCell.date localStringWithFormat:@"yyyy年MM月dd日"];
                NSString *info = @"";
                NSString *aid = @"";
                double latitude = 0;
                double longitude = 0;
                
                if (actionSheet.tag == ActionSheetTagStart) {
                    info = [NSString stringWithFormat:@"%@（%@）\n%@ 出勤", dateStr, detailCell.weekLabel.text, detailCell.startLabel.text];
                    latitude = day.start_latitude;
                    longitude = day.start_longitude;
                    aid = day.startTime.aid;
                } else if (actionSheet.tag == ActionSheetTagEnd) {
                    info = [NSString stringWithFormat:@"%@（%@）\n%@ 退勤", dateStr, detailCell.weekLabel.text, detailCell.endLabel.text];
                    latitude = day.end_latitude;
                    longitude = day.end_longitude;
                    aid = day.endTime.aid;
                }
                
                if (latitude == 0 || longitude == 0) {
                    NSMutableArray *areaArray = [[AppManager sharedInstance] areaArray];

                    for (Area *area in areaArray) {
                        if ([area.aid isEqualToString:aid]) {
                            latitude = [area.latitude doubleValue];
                            longitude = [area.longitude doubleValue];
                            break;
                        }
                    }
                }
                if (latitude == 0 || longitude == 0) {
                    latitude = [[AppManager sharedInstance] testLatitude];
                    longitude = [[AppManager sharedInstance] testLongitude];
                }
                
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                [self.mapView addAnnotationAtCoordinate:coordinate infoString:info];
                [self.mapView setHidden:NO];
                [self.mapView setAlpha:0.0];
                [self.view bringSubviewToFront:self.mapView];
                [UIView animateWithDuration:0.5 animations:^{
                    [self.mapView setAlpha:1.0];
                }];
                
                break;
            } else {
                if (self.editingIndex != self.memoIndex || self.editingType != EditingTypeMemo) {
                    [self showMemoAtIndex:self.editingIndex];
                }
            }
        }
        case 2: {
            if (hasLocation) {
                if (self.editingIndex != self.memoIndex || self.editingType != EditingTypeMemo) {
                    [self showMemoAtIndex:self.editingIndex];
                }
                
                break;
            }
        }
        default:
            break;
    }
}

- (void)showMemoAtIndex:(NSInteger)index
{
    [self setEditingIndex:index];
    [self setEditingType:EditingTypeMemo];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.editingIndex inSection:0];
    
    [self.tableView beginUpdates];

    if (self.editingIndex == self.memoIndex) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:self.memoIndex inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[lastIndexPath, indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    [self setMemoIndex:self.editingIndex];
    
    [self.tableView endUpdates];
    
    if (indexPath.row < self.heldDays - 2) {
        // Scroll to visible
        CGRect rect = [self.tableView rectForRowAtIndexPath:indexPath];
        [self.tableView scrollRectToVisible:rect animated:YES];
    } else {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger rows = 0;
    
    switch (component) {
        case 0:
            rows = 24;
            break;
        case 1:
            rows = 60;
            break;
        default:
            break;
    }
    return rows;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 35.0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = (UILabel *)view;
    if (!label) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [pickerView rowSizeForComponent:component].width - 40.0, [pickerView rowSizeForComponent:component].height)];
        label.font = [UIFont systemFontOfSize:22.0];
        label.adjustsFontSizeToFitWidth = YES;
        label.backgroundColor = [UIColor clearColor];
    }
    NSString *value = @"";
    switch (component) {
        case 0:
            value = [NSString stringWithFormat:@"%02d", (int)row + 5];
            [label setTextAlignment:NSTextAlignmentRight];
            break;
        case 1:
            value = [NSString stringWithFormat:@"%02d", (int)row];
            [label setTextAlignment:NSTextAlignmentLeft];
            break;
        default:
            break;
    }
    label.text = value;
    
    return label;
}

//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
//{
//    if (self.settingStartTime) {
//        NSString *start_date = [self selectedPickerDate:self.editingStartDate belongDate:self.editingYMDDate];
//        [self setEditingStartDate:start_date];
//    } else {
//        NSString *end_date = [self selectedPickerDate:self.editingEndDate belongDate:self.editingYMDDate];
//        [self setEditingEndDate:end_date];
//    }
//
//    [self updateButtonStatus];
//}

- (void)selectNowDate
{
    NSDate *date = [NSDate date];
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
    
    NSInteger hour = dateComponents.hour;

    if (hour >= 5) {
        [self.datePicker selectRow:(hour - 5) inComponent:0 animated:YES];
    } else {
        [self.datePicker selectRow:(hour - 5 + 24) inComponent:0 animated:YES];
    }
    
    [self.datePicker selectRow:dateComponents.minute inComponent:1 animated:YES];
}

- (void)selectPickerDate:(NSString *)dateString
{
    if (dateString.length > 0) {
        NSDate *date = [dateString localDateWithFormat:DB_DATE_YMDHMS];
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
        
        NSInteger hour = dateComponents.hour;
        
        if (hour >= 5) {
            [self.datePicker selectRow:(hour - 5) inComponent:0 animated:YES];
        } else {
            [self.datePicker selectRow:(hour - 5 + 24) inComponent:0 animated:YES];
        }
        
        [self.datePicker selectRow:dateComponents.minute inComponent:1 animated:YES];
    }
}

- (NSString *)selectedPickerDate:(NSString *)dateString belongDate:(NSString *)belongDateString
{
    NSString *retDate = nil;
    
    NSDate *belongDate = [belongDateString localDateWithFormat:DB_DATE_YMD];
    NSDateComponents *belongDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:belongDate];
    
    NSDateComponents *dateComponents = nil;
    if (dateString.length > 0) {
        NSDate *date = [dateString localDateWithFormat:DB_DATE_YMDHMS];
        dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
    } else {
        dateComponents = [belongDateComponents copy];
    }
    
    NSInteger hour = [self.datePicker selectedRowInComponent:0] + 5;
    NSInteger minute = [self.datePicker selectedRowInComponent:1];
    
    [dateComponents setYear:belongDateComponents.year];
    [dateComponents setMonth:belongDateComponents.month];
    if (hour >= 24) {
        hour -= 24;
        [dateComponents setDay:(belongDateComponents.day + 1)];
    } else {
        [dateComponents setDay:belongDateComponents.day];
    }
    [dateComponents setHour:hour];
    [dateComponents setMinute:minute];
    
    NSDate *selectedDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    retDate = [selectedDate localStringWithFormat:DB_DATE_YMDHMS];
    
    return retDate;
}

@end
