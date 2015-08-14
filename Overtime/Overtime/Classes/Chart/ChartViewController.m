//
//  ChartViewController.m
//  Overtime
//
//  Created by Xu Shawn on 2/24/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "ChartViewController.h"
#import "WebViewController.h"
#import "ChartCell.h"
#import "TutorialView.h"
#import "Year.h"
#import "Month.h"

@interface ChartViewController ()

@property (nonatomic, strong) IBOutlet UIView *blockView;
@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) NSInteger heldDays;
@property (nonatomic, strong) NSDateComponents *selectedDateComponents;
@property (nonatomic, strong) Year *year;
@property (nonatomic, strong) Month *month;
@property (nonatomic, strong) UIButton *currentButton;
@property (nonatomic, strong) NSDate *maxDate;
@property (nonatomic, strong) NSDateComponents *maxDateComponent;
@property (nonatomic, assign) NSInteger todayIndex;
@property (nonatomic, assign) NSInteger toSelectedIndex;

@end

@implementation ChartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _cellIdentifier = @"ChartCell";
        
        NSDate *currentDate = [[AppManager sharedInstance] currentDate];
        _selectedDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:currentDate];
        [_selectedDateComponents setDay:1];
        [_selectedDateComponents setHour:12];
        [_selectedDateComponents setMinute:0];
        [_selectedDateComponents setSecond:0];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReloadDataNotification:) name:ReloadChartDataNotification object:nil];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView registerNib:[UINib nibWithNibName:self.cellIdentifier bundle:nil] forCellReuseIdentifier:self.cellIdentifier];
    
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
    self.currentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.currentButton setFrame:CGRectOffsetFromImage(currentImage, 92.0, 10.0)];
    [self.currentButton setImage:currentImage forState:UIControlStateNormal];
    [self.currentButton addTarget:self action:@selector(currentButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:self.currentButton];
    
    [self.view addSubview:footerView];
    
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults boolForKey:TutorialChartShowed]) {
        [TutorialView showWithTutorialType:TutorialTypeChart];
        [userDefaults setBool:YES forKey:TutorialChartShowed];
        [userDefaults synchronize];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)reloadData
{
    NSDate *selectedDate = [[NSCalendar currentCalendar] dateFromComponents:self.selectedDateComponents];
    
    if (self.chartType == ChartTypeMonthly) {
        // Month key
        self.dataArray = [CalendarUtils monthArray];
        
        // Month in a year
        self.year = [[[AppManager sharedInstance] era] yearFromDate:selectedDate];
        // Date
        [self.dateLabel setText:[NSString stringWithFormat:@"%d年", (int)self.selectedDateComponents.year]];
        
        NSDictionary *userInfo = @{DataUpdateKeyMoney: @(self.year.money), DataUpdateKeyHour: @(self.year.otHours)};
        [[NSNotificationCenter defaultCenter] postNotificationName:ChartDataUpdateNotification object:nil userInfo:userInfo];
    } else {
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
    }
    
    [self.tableView reloadData];
    
    if (self.chartType == ChartTypeMonthly) {
        [self.currentButton setImage:[UIImage imageNamed:@"current_year_button"] forState:UIControlStateNormal];
    } else {
        [self.currentButton setImage:[UIImage imageNamed:@"current_month_button"] forState:UIControlStateNormal];
        
        if (self.toSelectedIndex >= 0 && self.toSelectedIndex < self.heldDays) {
            NSIndexPath *scrollToIndexPath = [NSIndexPath indexPathForRow:self.toSelectedIndex inSection:0];
            [self.tableView scrollToRowAtIndexPath:scrollToIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            [self setToSelectedIndex:-1];
        }
    }
}

- (void)homeButtonDidClicked:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(forwardToHomeViewFromChartView:)]) {
        [self.delegate forwardToHomeViewFromChartView:self];
    }
}

- (void)resetDate
{
    NSDateComponents *currentDateComponents = [[AppManager sharedInstance] currentDateComponents];
    if (self.chartType == ChartTypeMonthly) {
        [self.selectedDateComponents setYear:currentDateComponents.year];
    } else {
        [self setToSelectedIndex:self.todayIndex];
    }
}

- (void)currentButtonDidClicked:(UIButton *)button
{
    [self resetDate];
    [self reloadData];
}

- (IBAction)previousButtonDidClicked:(id)sender
{
    if (self.chartType == ChartTypeMonthly) {
        [self.selectedDateComponents setYear:self.selectedDateComponents.year - 1];
        [self reloadData];
    } else {
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
}

- (IBAction)nextButtonDidClicked:(id)sender
{
    if (self.chartType == ChartTypeMonthly) {
        [self.selectedDateComponents setYear:self.selectedDateComponents.year + 1];
        [self reloadData];
    } else {
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
}

- (IBAction)blockButtonDidClicked:(id)sender
{
    NSString *urlString = [BASE_URL stringByAppendingPathComponent:@"event"];
    WebViewController *webViewController = [[WebViewController alloc] initWithTitle:@"記録期間の拡張" URLString:urlString webVCType:WebVCTypeTask];
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.chartType == ChartTypeMonthly) {
        return self.dataArray.count;
    } else {
        return self.heldDays;
    }
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
    ChartCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];

    if (indexPath.row % 2 == 0) {
        [cell.bgImageView setImage:[UIImage imageNamed:@"chart_cell_bg1"]];
    } else {
        [cell.bgImageView setImage:[UIImage imageNamed:@"chart_cell_bg2"]];
    }
    if (self.chartType == ChartTypeMonthly) {
        [cell.dayLabel setText:self.dataArray[indexPath.row]];
        [cell.weekLabel setText:@"月"];
        [cell.weekLabel setTextColor:[UIColor whiteColor]];
        
        Month *month = [self.year.monthDic objectForKey:cell.dayLabel.text];
        [cell setMoneyText:month.formattedMoney];
        [cell setMoney:month.money];
        [cell setMaxMoney:1500000];
    } else {
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
        
        Day *day = [[[AppManager sharedInstance] era] dayFromDate:iDate];
        [cell setMoneyText:day.formattedMoney];
        [cell setMoney:day.money];
        [cell setMaxMoney:50000];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChartCell *chartCell = (ChartCell *)cell;
    [chartCell startAnimation];
    
    if (self.chartType == ChartTypeDaily) {
        [self.dateLabel setText:[chartCell.date localStringWithFormat:DATE_FORMAT]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.chartType == ChartTypeMonthly) {
        NSInteger month = [self.dataArray[indexPath.row] integerValue];
        [self.selectedDateComponents setMonth:month];
        
        [self setChartType:ChartTypeDaily];
        
        [self reloadData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DailyMonthlySwitchNotification object:nil];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(chartViewController:forwardToDetailViewOnDate:)]) {
            NSDate *iDate = [self dateForRow:indexPath.row];
            [self.delegate chartViewController:self forwardToDetailViewOnDate:iDate];
        }
    }
}

#pragma mark - NSNotification

- (void)handleReloadDataNotification:(NSNotification *)notification
{
    [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

@end
