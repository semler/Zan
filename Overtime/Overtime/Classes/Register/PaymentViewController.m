//
//  PaymentViewController.m
//  Overtime
//
//  Created by Xu Shawn on 3/6/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "PaymentViewController.h"
#import "PaymentHourViewController.h"
#import "PaymentMonthViewController.h"
#import "CheckViewController.h"

@interface PaymentViewController ()

@end

@implementation PaymentViewController

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
    
    UIImage *bgImage = [UIImage imageNamed:@"payment_bg"];
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(bgImage, 0, headerImageView.bottom)];
    [bgImageView setImage:bgImage];
    [self.view addSubview:bgImageView];
    
    UIImage *hourImage = [UIImage imageNamed:@"payment_hour_button"];
    UIButton *hourButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [hourButton setFrame:CGRectOffsetFromImage(hourImage, (self.view.width - hourImage.size.width) / 2, 141.0)];
    [hourButton setImage:hourImage forState:UIControlStateNormal];
    [hourButton addTarget:self action:@selector(hourButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hourButton];
    
    UIImage *monthImage = [UIImage imageNamed:@"payment_month_button"];
    UIButton *monthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [monthButton setFrame:CGRectOffsetFromImage(monthImage, (self.view.width - monthImage.size.width) / 2, 205.0)];
    [monthButton setImage:monthImage forState:UIControlStateNormal];
    [monthButton addTarget:self action:@selector(monthButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:monthButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)hourButtonDidClicked:(UIButton *)button
{
    PaymentHourViewController *hourViewController = [[PaymentHourViewController alloc] initWithSettingType:self.settingType];
    [self.navigationController pushViewController:hourViewController animated:YES];
}

- (void)monthButtonDidClicked:(UIButton *)button
{
    PaymentMonthViewController *monthViewController = [[PaymentMonthViewController alloc] initWithSettingType:self.settingType];
    [self.navigationController pushViewController:monthViewController animated:YES];
}

@end
