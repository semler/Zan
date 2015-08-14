//
//  SettingChargeViewController.m
//  Overtime
//
//  Created by Xu Shawn on 4/4/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "SettingChargeViewController.h"

@interface SettingChargeViewController ()

@end

@implementation SettingChargeViewController

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
    [self configHeaderImage:@"setting_header"];
    [self configBackButton];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [self.contentView addSubview:scrollView];
    
    UIImage *bgImage = [UIImage imageNamed:@"setting_charge_bg"];
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectFromImage(bgImage)];
    [bgImageView setImage:bgImage];
    [scrollView addSubview:bgImageView];
    
    [scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, bgImageView.bottom)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
