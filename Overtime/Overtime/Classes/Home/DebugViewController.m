//
//  DebugViewController.m
//  Overtime
//
//  Created by Xu Shawn on 4/25/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "DebugViewController.h"

@interface DebugViewController ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation DebugViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configHeaderImage:@"setting_header" andBgImage:@"bg"];
    [self configDismissButton];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 38.0, SCREEN_WIDTH - 20.0, self.contentView.height - 48.0)];
    [self.label setBackgroundColor:[UIColor clearColor]];
    [self.label setTextColor:[UIColor whiteColor]];
    [self.label setFont:[UIFont systemFontOfSize:14.0]];
    [self.label setNumberOfLines:0];
    [self.contentView addSubview:self.label];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud setRemoveFromSuperViewOnHide:YES];
    [hud showAnimated:YES whileExecutingBlock:^{
        Day *currentDay = [[AppManager sharedInstance] currentDay];
        if (!currentDay) {
            Year *year = [[[[AppManager sharedInstance] era] yearArray] lastObject];
            Month *month = [[year monthArray] lastObject];
            currentDay = [[month dayArray] lastObject];
        }
        NSString *subTitle = [NSString stringWithFormat:@"DEBUG: %@", currentDay.ymdDate];
        [self performSelectorOnMainThread:@selector(configSubTitle:) withObject:subTitle waitUntilDone:NO];
        
        NSString *start_date = [currentDay start_date];
        NSString *end_date = [currentDay end_date];
        NSString *startTime = [start_date dateStringWithFomat:DB_DATE_HM fromFormat:DB_DATE_YMDHMS];
        NSString *endTime = [end_date dateStringWithFomat:DB_DATE_HM fromFormat:DB_DATE_YMDHMS];
        
        
        NSDictionary *masterDic = [[AppManager sharedInstance] masterDic];
        NSString *restStart1 = masterDic[MSTKeyRestStart1];
        NSString *restEnd1 = masterDic[MSTKeyRestEnd1];
        NSString *restStart2 = masterDic[MSTKeyRestStart2];
        NSString *restEnd2 = masterDic[MSTKeyRestEnd2];
        NSString *belongDate = currentDay.ymdDate;
        double hourMoney = [masterDic[MSTKeyPaymentHour] doubleValue];
        
        restStart1 = [NSString stringWithFormat:@"%@ %@:00", belongDate, restStart1];
        restEnd1 = [NSString stringWithFormat:@"%@ %@:00", belongDate, restEnd1];
        restStart2 = [NSString stringWithFormat:@"%@ %@:00", belongDate, restStart2];
        restEnd2 = [NSString stringWithFormat:@"%@ %@:00", belongDate, restEnd2];
        
        
        NSDate *startDate = [start_date localDateWithFormat:DB_DATE_YMDHMS];
        
        NSMutableString *text = [NSMutableString string];
        
        double money = 0;
        double midnightMoney = 0;
        
        if ([[AppManager sharedInstance] isWorking]) {
            [text appendFormat:@"勤務中: %@ ~ %@\n", startTime, endTime];
        } else {
            [text appendFormat:@"勤務外: %@ ~ %@\n", startTime, endTime];
        }
        [text appendFormat:@"全部の勤務時間: %@\n\n", [AppManager hoursToHHmm:currentDay.workHours]];
        
//        NSDate *endDate = [end_date localDateWithFormat:DB_DATE_YMDHMS];
        
        if (currentDay.otHours > 0) {
            //        NSDate *otStartDate = [endDate dateByAddingTimeInterval:-currentDay.otHours * 3600];
            //        NSString *otStartHM = [otStartDate localStringWithFormat:DB_DATE_HM];
            
            if (currentDay.isHoliday) {
                NSString *startTime = [start_date dateStringWithFomat:DB_DATE_HM fromFormat:DB_DATE_YMDHMS];
                
                [text appendFormat:@"残業中: %@ ~ %@\n", startTime, endTime];
                [text appendFormat:@"残業時間: %f 残業代: %@円\n\n", currentDay.otHours, currentDay.formattedMoney];
            } else {
                NSDateComponents *otDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:startDate];
                NSDate *theDate = nil;
                NSString *the_date = nil;
                while (YES) {
                    theDate = [[NSCalendar currentCalendar] dateFromComponents:otDateComponents];
                    the_date = [theDate localStringWithFormat:DB_DATE_YMDHMS];
                    double hour = [currentDay hourFromDate:start_date toDate:the_date restStartDate1:restStart1 restEndDate1:restEnd1 restStartDate2:restStart2 restEndDate2:restEnd2];
                    if (hour > 8) {
                        break;
                    }
                    [otDateComponents setMinute:(otDateComponents.minute + 1)];
                }
                [otDateComponents setMinute:(otDateComponents.minute - 1)];
                theDate = [[NSCalendar currentCalendar] dateFromComponents:otDateComponents];
                the_date = [theDate localStringWithFormat:DB_DATE_YMDHMS];
                NSString *theTime = [the_date dateStringWithFomat:DB_DATE_HM fromFormat:DB_DATE_YMDHMS];
                
                [text appendFormat:@"残業中: %@ ~ %@\n", theTime, endTime];
                [text appendFormat:@"残業時間: %@ 残業代: %@円\n\n", [AppManager hoursToHHmm:currentDay.otHours], currentDay.formattedMoney];
            }
            
        } else {
            [text appendString:@"残業なし: ~ \n"];
            [text appendString:@"残業時間: 0 残業代: 0円\n\n"];
        }
        
        if (currentDay.midnightHour > 0) {
//            NSDate *midnightStartDate = [endDate dateByAddingTimeInterval:-currentDay.midnightHour * 3600];
//            NSString *midnightStartHM = [midnightStartDate localStringWithFormat:DB_DATE_HM];
            
            NSString *midnightDate = [NSString stringWithFormat:@"%@ 22:00:00", belongDate];
            
            if ([midnightDate compare:start_date] == NSOrderedAscending) {
                midnightDate = start_date;
            }
            
            NSDateComponents *midnightDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[midnightDate localDateWithFormat:DB_DATE_YMDHMS]];
            
            NSDate *theDate = nil;
            NSString *the_date = nil;
            while (YES) {
                theDate = [[NSCalendar currentCalendar] dateFromComponents:midnightDateComponents];
                the_date = [theDate localStringWithFormat:DB_DATE_YMDHMS];
                double hour = [currentDay hourFromDate:midnightDate toDate:the_date restStartDate1:restStart1 restEndDate1:restEnd1 restStartDate2:restStart2 restEndDate2:restEnd2];
                if (hour > 0) {
                    break;
                }
                [midnightDateComponents setMinute:(midnightDateComponents.minute + 1)];
            }
            [midnightDateComponents setMinute:(midnightDateComponents.minute - 1)];
            theDate = [[NSCalendar currentCalendar] dateFromComponents:midnightDateComponents];
            the_date = [theDate localStringWithFormat:DB_DATE_YMDHMS];
            NSString *theTime = [the_date dateStringWithFomat:DB_DATE_HM fromFormat:DB_DATE_YMDHMS];
            
            [text appendFormat:@"深夜残業中: %@ ~ %@\n", theTime, endTime];
            midnightMoney = currentDay.midnightHour * hourMoney * 0.25;
            NSString *formattedMoney = [AppManager currencyFormat:(NSInteger)midnightMoney];
            [text appendFormat:@"深夜残業時間: %@ 残業代: %@円\n\n", [AppManager hoursToHHmm:currentDay.midnightHour], formattedMoney];
        } else {
            [text appendString:@"深夜残業なし: ~ \n"];
            [text appendString:@"深夜残業時間: 0 残業代: 0円\n\n"];
        }
        
        if (currentDay.over60Hours > 0) {
//            NSDate *over60StartDate = [endDate dateByAddingTimeInterval:-currentDay.over60Hours * 3600];
            
            NSDateComponents *over60DateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:startDate];
            NSDate *theDate = nil;
            NSString *the_date = nil;
            while (YES) {
                theDate = [[NSCalendar currentCalendar] dateFromComponents:over60DateComponents];
                the_date = [theDate localStringWithFormat:DB_DATE_YMDHMS];
                double hour = [currentDay hourFromDate:start_date toDate:the_date restStartDate1:restStart1 restEndDate1:restEnd1 restStartDate2:restStart2 restEndDate2:restEnd2];
                if (currentDay.monthOTHours + hour > 60) {
                    break;
                }
                [over60DateComponents setMinute:(over60DateComponents.minute + 1)];
            }
            [over60DateComponents setMinute:(over60DateComponents.minute - 1)];
            theDate = [[NSCalendar currentCalendar] dateFromComponents:over60DateComponents];
            the_date = [theDate localStringWithFormat:DB_DATE_YMDHMS];
            NSString *theTime = [the_date dateStringWithFomat:DB_DATE_HM fromFormat:DB_DATE_YMDHMS];
            
            [text appendFormat:@"60H以上残業中: %@ ~ %@\n", theTime, endTime];
            money = currentDay.over60Hours * hourMoney * 0.25;
            [text appendFormat:@"60H以上残業時間: %@ 残業代: %@円\n\n", [AppManager hoursToHHmm:currentDay.over60Hours], [AppManager currencyFormat:(NSInteger)money]];
        } else {
            [text appendString:@"60H以上残業なし: ~ \n"];
            [text appendString:@"60H以上残業時間: 0 残業代: 0円\n\n"];
        }
        
        [text appendFormat:@"休憩時間1: %@ ~ %@\n", MASTER(MSTKeyRestStart1), MASTER(MSTKeyRestEnd1)];
        [text appendFormat:@"休憩時間2: %@ ~ %@\n", MASTER(MSTKeyRestStart2), MASTER(MSTKeyRestEnd2)];
        [text appendFormat:@"祝日マーク: %@\n", currentDay.isHoliday ? @"YES" : @"NO"];
        
        NSString *week1 = [NSString stringWithFormat:@"%@曜日", [AppManager weekTextAtIndex:[MASTER(MSTKeyWeekendIn) integerValue]]];
        NSString *week2 = [NSString stringWithFormat:@"%@曜日", [AppManager weekTextAtIndex:[MASTER(MSTKeyWeekendOut) integerValue]]];
        [text appendFormat:@"法定内休日: %@\n", week1];
        [text appendFormat:@"法定外休日: %@\n", week2];
        [text appendFormat:@"時給: %@円\n\n", MASTER(MSTKeyPaymentHour)];
        
        if (currentDay.otHours > 0) {
            money = currentDay.money;
        } else {
            money = midnightMoney;
        }
        
        [text appendFormat:@"全部の残業代: %@\n", [AppManager currencyFormat:(NSInteger)money]];

        [self.label performSelectorOnMainThread:@selector(setText:) withObject:text waitUntilDone:NO];
    }];
}

@end
