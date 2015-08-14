//
//  PaymentMonthViewController.m
//  Overtime
//
//  Created by Xu Shawn on 3/26/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "PaymentMonthViewController.h"
#import "CheckViewController.h"

@interface PaymentMonthViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, copy) NSString *inputValue;
@property (nonatomic, copy) NSString *formattedValue;
@property (nonatomic, strong) UILabel *moneyLabel;
@property (nonatomic, assign) NSInteger hourMoney;

@end

@implementation PaymentMonthViewController

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
            headerImage = [UIImage imageNamed:@"payment_header"];
            break;
        case SettingTypeEdit:
            headerImage = [UIImage imageNamed:@"payment_reset_header"];
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
    
    [self configBackButton];
    
    UIImage *bgImage = [UIImage imageNamed:@"payment_month_bg"];
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(bgImage, 0, headerImageView.bottom)];
    [bgImageView setImage:bgImage];
    [self.view addSubview:bgImageView];
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(150.0, 138.0, 130.0, 50.0)];
    [self.textField setFont:[UIFont systemFontOfSize:14.0]];
    [self.textField setTextColor:[UIColor whiteColor]];
    [self.textField setReturnKeyType:UIReturnKeyDone];
    [self.textField setDelegate:self];
    [self.textField setTextAlignment:NSTextAlignmentRight];
    [self.textField setKeyboardType:UIKeyboardTypeNumberPad];
    [self.textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.textField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"月給を入力" attributes:@{NSForegroundColorAttributeName: [UIColor grayColor]}]];
    [self.view addSubview:self.textField];
    
    NSDictionary *masterDic = [[AppManager sharedInstance] masterDic];
    [self setInputValue:masterDic[MSTKeyPaymentMonth]];
    if (self.inputValue.length > 0) {
        [self setFormattedValue:[AppManager currencyFormat:[self.inputValue doubleValue]]];
        [self.textField setText:self.formattedValue];
    }
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(68.0, 253.0, 78.0, 30.0)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setText:@"時給換算額"];
    [titleLabel setTextColor:[UIColor colorWithRed:0.49 green:0.77 blue:0.93 alpha:1]];
    [titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [self.view addSubview:titleLabel];
    
    self.moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.right, titleLabel.top, 110.0, titleLabel.height)];
    [self.moneyLabel setBackgroundColor:[UIColor clearColor]];
    [self.moneyLabel setTextAlignment:NSTextAlignmentRight];
    [self.moneyLabel setTextColor:[UIColor colorWithRed:0.49 green:0.77 blue:0.93 alpha:1]];
    [self.moneyLabel setFont:[UIFont systemFontOfSize:15.0]];
    [self.view addSubview:self.moneyLabel];
    
    NSInteger hourMoney = [self calculateHourMoney:self.inputValue];
    [self setHourMoney:hourMoney];
    NSString *formattedHourMoney = [AppManager currencyFormat:hourMoney];
    [self.moneyLabel setText:[NSString stringWithFormat:@"%@円", formattedHourMoney]];
    
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
    [nextButton setFrame:CGRectOffsetFromImage(nextImage, (SCREEN_WIDTH - nextImage.size.width) / 2, 370.0)];
    [nextButton setImage:nextImage forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)nextButtonDidClicked:(UIButton *)button
{
    NSInteger value = [self.inputValue integerValue];
    if (value <= 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"月給の設定が完了してないです。" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    } else if (value > 1000000) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"ごめんなさい。月給は最大100万円までなのです。\n月給多くて羨ましい...。" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    } else {
        [Master saveValue:[NSString stringWithFormat:@"%d", (int)self.hourMoney] forKey:MSTKeyPaymentHour];
        [Master saveValue:self.inputValue forKey:MSTKeyPaymentMonth];
        
        [[AppManager sharedInstance] setSettingNeedReload:YES];
        
        if (self.settingType == SettingTypeEdit || self.settingType == SettingTypeReEdit) {
            [self dismissViewControllerAnimated:YES completion:NULL];
        } else {
            CheckViewController *checkViewController = [[CheckViewController alloc] init];
            [self.navigationController pushViewController:checkViewController animated:YES];
        }
    }
}

- (NSInteger)calculateHourMoney:(NSString *)money
{
    NSInteger monthMoney = [money integerValue];
    
    NSDictionary *masterDic = [[AppManager sharedInstance] masterDic];
    NSArray *weekArray = [masterDic[MSTKeyWeekday] componentsSeparatedByString:@","];
    
    // 月給から時給を計算する方法 ⇒ 月給÷(1週間の出勤日数×4週分)÷8時間
    NSInteger hourMoney = monthMoney / (weekArray.count * 4) / 8;
    
    return hourMoney;
}

- (void)handleTapGesture:(UIGestureRecognizer *)gestureRecognizer
{
    [self.textField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

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
    [self setFormattedValue:[AppManager currencyFormat:[self.inputValue doubleValue]]];
    [textField setText:self.formattedValue];
    
    NSInteger hourMoney = [self calculateHourMoney:self.inputValue];
    [self setHourMoney:hourMoney];
    NSString *formattedHourMoney = [AppManager currencyFormat:hourMoney];
    [self.moneyLabel setText:[NSString stringWithFormat:@"%@円", formattedHourMoney]];
}

@end
