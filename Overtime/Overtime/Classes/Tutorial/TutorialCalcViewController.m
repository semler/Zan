//
//  TutorialCalcViewController.m
//  Overtime
//
//  Created by xuxiaoteng on 12/25/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "TutorialCalcViewController.h"
#import "CustomPicker.h"
#import "TutorialView.h"

@interface TutorialCalcViewController () <CustomPickerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *bgImageView;
@property (nonatomic, strong) IBOutlet UIView *weekView;
@property (nonatomic, strong) IBOutlet UIButton *weekButton1;
@property (nonatomic, strong) IBOutlet UIButton *weekButton2;
@property (nonatomic, strong) IBOutlet UIButton *weekButton3;
@property (nonatomic, strong) IBOutlet UIButton *weekButton4;
@property (nonatomic, strong) IBOutlet UIButton *weekButton5;
@property (nonatomic, strong) IBOutlet UIButton *weekButton6;
@property (nonatomic, strong) IBOutlet UIButton *weekButton7;
@property (nonatomic, strong) IBOutlet UIButton *hoursButton;
@property (nonatomic, strong) IBOutlet UITextField *textField;

@property (nonatomic, strong) NSMutableArray *selectedWeekArray;
@property (nonatomic, copy) NSString *inputValue;

@end

@implementation TutorialCalcViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.selectedWeekArray = [NSMutableArray array];
    [self.selectedWeekArray addObject:@(7)];
    [self.selectedWeekArray addObject:@(6)];
    
    [self.bgImageView setImage:[UIImage imageNamed:@"tutorial_setting3"]];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (IBAction)hoursButtonDidClicked:(id)sender
{
    [self.textField resignFirstResponder];
    
    CustomPicker *picker = [CustomPicker sharedInstance];
    [picker setDelegate:self];
    [picker setShowResetButton:NO];
    [picker setPickerType:CustomPickerTypeDefault];
    
    NSMutableArray *dataSource = [NSMutableArray array];
    [dataSource addObject:@"1～8"];
    for (NSInteger i = 9; i <= 24; i++) {
        [dataSource addObject:[NSString stringWithFormat:@"%ld", (long)i]];
    }
    [picker setDataSource:dataSource];

    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [[CustomPicker sharedInstance] showInView:window];
}

- (IBAction)weekButtonDidClicked:(id)sender
{
    [self.textField resignFirstResponder];
    
    UIButton *button = (UIButton *)sender;
    
    if ([self.selectedWeekArray containsObject:@(button.tag)]) {
        if (self.selectedWeekArray.count == 2) {
            [button setSelected:NO];
            [self.selectedWeekArray removeObject:@(button.tag)];
        }
    } else {
        if (self.selectedWeekArray.count == 2) {
            NSInteger tag = [[self.selectedWeekArray firstObject] integerValue];
            UIButton *firstButton = (UIButton *)[self.weekView viewWithTag:tag];
            [firstButton setSelected:NO];
            [self.selectedWeekArray removeObjectAtIndex:0];
        }
        [button setSelected:YES];
        [self.selectedWeekArray addObject:@(button.tag)];
    }
}

- (IBAction)paymentButtonDidClicked:(id)sender
{
    [self.textField becomeFirstResponder];
}

// To do
- (IBAction)calculateButtonDidClicked:(id)sender
{
    NSString *hoursString = [self.hoursButton titleForState:UIControlStateNormal];
    if ([hoursString integerValue] > 0 && [self.inputValue integerValue] > 0 && [self.inputValue integerValue] <= 100) {
        NSMutableString *weekString = [NSMutableString string];
        NSMutableString *holidayString = [NSMutableString string];
        
        if (self.selectedWeekArray.count > 0) {
            for (NSInteger i = 1; i <= 7; i++) {
                if ([self.selectedWeekArray containsObject:@(i)]) {
                    NSInteger realIndex = (i == 7 ? 0 : i);
                    [holidayString appendFormat:@"%ld,", (long)realIndex];
                } else {
                    NSInteger realIndex = (i == 7 ? 0 : i);
                    [weekString appendFormat:@"%ld,", (long)realIndex];
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
        
        if (self.selectedWeekArray.count == 1) {
            NSInteger weekendIn = [self.selectedWeekArray[0] integerValue];
            if (weekendIn == 7) {
                weekendIn = 0;
            }
            [Master saveValue:[NSString stringWithFormat:@"%ld", (long)weekendIn] forKey:MSTKeyWeekendIn];
            [Master saveValue:@"" forKey:MSTKeyWeekendOut];
        } else if (self.selectedWeekArray.count == 2) {
            NSInteger weekendOut = [self.selectedWeekArray[0] integerValue];
            if (weekendOut == 7) {
                weekendOut = 0;
            }
            [Master saveValue:[NSString stringWithFormat:@"%ld", (long)weekendOut] forKey:MSTKeyWeekendOut];
            
            NSInteger weekendIn = [self.selectedWeekArray[1] integerValue];
            if (weekendIn == 7) {
                weekendIn = 0;
            }
            [Master saveValue:[NSString stringWithFormat:@"%ld", (long)weekendIn] forKey:MSTKeyWeekendIn];
        }
        
        [Master saveValue:holidayString forKey:MSTKeyHoliday];
        [Master saveValue:weekString forKey:MSTKeyWeekday];
        
        NSString *paymentMonth = [NSString stringWithFormat:@"%@0000", self.inputValue];
        NSInteger hourMoney = 0;
        if (paymentMonth.length > 0) {
            hourMoney = [AppManager calculateHourMoney:paymentMonth];
            [Master saveValue:[NSString stringWithFormat:@"%ld", (long)hourMoney] forKey:MSTKeyPaymentHour];
            [Master saveValue:paymentMonth forKey:MSTKeyPaymentMonth];
        }
        
        NSInteger workHours = [hoursString integerValue];
        double allMoney = 0;
        NSInteger midnightHour = 0;
        NSInteger weekendCount = self.selectedWeekArray.count;
        
        if (workHours > 8) {
            NSInteger otHours = 0;
            
            for (NSInteger month = 1; month <= 12; month++) {
                NSInteger monthOTHours = 0;
                NSInteger over60Hours = 0;
                
                for (NSInteger week = 1; week <= 4; week++) {
                    for (NSInteger day = 1; day <= 7 - weekendCount; day++) {
                        double money = 0;
                        
                        // 平日
                        otHours = workHours - 8.0;
                        over60Hours = 0;
                        // Over 60 hours
                        if (monthOTHours > 60.0) {
                            over60Hours = otHours;
                        } else if (monthOTHours + otHours > 60.0) {
                            over60Hours = monthOTHours + otHours - 60.0;
                        }
                        if (otHours < 0) {
                            otHours = 0;
                        } else if (otHours > 24.0) {
                            otHours = 24.0;
                        }
                        
                        if (over60Hours < 0) {
                            over60Hours = 0;
                        } else if (over60Hours > 24.0) {
                            over60Hours = 0;
                        }
                        if (otHours > 0) {
                            money = (otHours * 1.25 + midnightHour * 0.25 + over60Hours * 0.25) * hourMoney;
                        } else {
                            money = midnightHour * 0.25 * hourMoney;;
                        }
                        
                        monthOTHours += otHours;
                        
                        allMoney += money;
                    }
                }
            }
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(tutorialCalcViewController:calculateDidFinished:)]) {
            [self.delegate tutorialCalcViewController:self calculateDidFinished:allMoney];
        }
    } else {
        NSString *message = @"";
        if ([self.inputValue integerValue] > 100) {
            message = @"ごめんなさい。月給は最大100万円までなのです。\n月給多くて羨ましい...。";
        } else {
            message = @"入力に不備があるみたいです。。";
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    }
}

- (void)handleTapGesture:(UIGestureRecognizer *)gestureRecognizer
{
    [self.textField resignFirstResponder];
}

#pragma mark - CustomPickerDelegate

- (void)customPicker:(CustomPicker *)picker didSelectDone:(id)value
{
    if ([value length] > 0) {
        [self.hoursButton setTitle:[NSString stringWithFormat:@"%@", value] forState:UIControlStateNormal];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (newString.length > 4) {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField setText:self.inputValue];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self setInputValue:textField.text];
    NSString *formattedValue = [AppManager currencyFormat:[self.inputValue doubleValue]];
    [textField setText:formattedValue];
}

@end
