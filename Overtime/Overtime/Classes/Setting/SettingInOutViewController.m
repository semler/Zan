//
//  SettingInOutViewController.m
//  Overtime
//
//  Created by Xu Shawn on 4/4/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "SettingInOutViewController.h"

#define MinMinute 1
#define MinTimes  2

@interface SettingInOutViewController ()

@property (nonatomic, strong) UIScrollView *minuteScrollView;
@property (nonatomic, strong) UIScrollView *timesScrollView;

@end

@implementation SettingInOutViewController

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
    [self configImage:@"inout_bg"];
    [self configBackButton];
    
    UIImage *rollImage = [UIImage imageNamed:@"inout_roll_bg"];
    UIImageView *minuteImageView = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(rollImage, 30.0, 230.0)];
    [minuteImageView setImage:rollImage];
    [minuteImageView setUserInteractionEnabled:YES];
    [self.view addSubview:minuteImageView];
    
    UIImageView *timesImageView = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(rollImage, 163.0, 230.0)];
    [timesImageView setImage:rollImage];
    [timesImageView setUserInteractionEnabled:YES];
    [self.view addSubview:timesImageView];
    
    // Master data
    NSDictionary *masterDic = [[AppManager sharedInstance] masterDic];
    
    NSString *currentMinute = masterDic[MSTKeyInOutftim];
    NSInteger currentMinuteInt = [currentMinute integerValue];
    if (currentMinuteInt <= 1) {
        currentMinuteInt = 1;
    }
    self.minuteScrollView = [self scrollViewWithFrame:minuteImageView.bounds minNum:MinMinute maxNum:30];
    [self.minuteScrollView setContentOffset:CGPointMake(0, (currentMinuteInt - 1) * self.minuteScrollView.height)];
    [minuteImageView addSubview:self.minuteScrollView];
    
    NSString *currentTimes = masterDic[MSTKeyInOutfnum];
    NSInteger currentTimesInt = [currentTimes integerValue];
    if (currentTimesInt <= 1) {
        currentTimesInt = 1;
    }
    self.timesScrollView = [self scrollViewWithFrame:timesImageView.bounds minNum:MinTimes maxNum:10];
    [self.timesScrollView setContentOffset:CGPointMake(0, (currentTimesInt - 2) * self.timesScrollView.height)];
    [timesImageView addSubview:self.timesScrollView];
    
    UIImage *saveImage = [UIImage imageNamed:@"save_change"];
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setFrame:CGRectOffsetFromImage(saveImage, (self.view.width - saveImage.size.width) / 2.0, (self.view.height - 95.0))];
    [saveButton setImage:saveImage forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (UIScrollView *)scrollViewWithFrame:(CGRect)frame minNum:(NSInteger)minNum maxNum:(NSInteger)maxNum
{
    CGFloat width = CGRectGetWidth(frame);
    CGFloat height = CGRectGetHeight(frame);
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), width, height)];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setPagingEnabled:YES];
    [scrollView setContentSize:CGSizeMake(width, (maxNum - minNum + 1) * height)];

    UIImage *lineImage = [UIImage imageNamed:@"inout_roll_line"];
    
    for (NSInteger i = minNum; i <= maxNum; i++) {
        UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectFromImage(lineImage)];
        [lineImageView setImage:lineImage];
        [scrollView addSubview:lineImageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, (i - minNum) * height, width, height)];
        label.text = [NSString stringWithFormat:@"%d", (int)i];
        label.font = [UIFont boldSystemFontOfSize:40.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        [scrollView addSubview:label];
        
        [lineImageView setCenter:label.center];
    }
    return scrollView;
}

- (void)saveButtonDidClicked:(UIButton *)button
{
    NSInteger minute = self.minuteScrollView.contentOffset.y / self.minuteScrollView.height + MinMinute;
    NSInteger times = self.timesScrollView.contentOffset.y / self.timesScrollView.height + MinTimes;
    [Master saveValue:[NSString stringWithFormat:@"%d", (int)minute] forKey:MSTKeyInOutftim];
    [Master saveValue:[NSString stringWithFormat:@"%d", (int)times] forKey:MSTKeyInOutfnum];
    
    // Database area
    NSMutableArray *areaArray = [[AppManager sharedInstance] areaArray];
    // Delete
    [GFUtils deleteGeoFenceConfig:areaArray];
    // Set flag
    for (Area *area in areaArray) {
        [area setSend_flag:@"0"];
    }
    // Config
    [GFUtils configGeoFence:areaArray];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
