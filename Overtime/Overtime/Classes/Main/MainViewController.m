//
//  MainViewController.m
//  Overtime
//
//  Created by Xu Shawn on 2/24/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "MainViewController.h"
#import "HomeViewController.h"
#import "ChartViewController.h"
#import "DetailViewController.h"
#import "ShareViewController.h"
#import "AnimLabel.h"
#import "TopicsListViewController.h"
#import "BaseResponse.h"
#import "TopicsDetailViewController.h"

#define TRANSITION_DURATION 0.3

@interface MainViewController () <HomeViewControllerDelegate, ChartViewControllerDelegate, DetailViewControllerDelegate>

@property (nonatomic, strong) HomeViewController *homeViewController;
@property (nonatomic, strong) ChartViewController *chartViewController;
@property (nonatomic, strong) DetailViewController *detailViewController;
@property (nonatomic, strong) UIViewController *currentViewController;

@property (nonatomic, strong) UIImageView *topBgImageView;
@property (nonatomic, strong) UIImageView *centerBarImageView;

@property (nonatomic, strong) UIView *homeTopView;
@property (nonatomic, strong) UIView *chartTopView;
@property (nonatomic, strong) UIView *detailTopView;
@property (nonatomic, strong) UIView *currentTopView;

@property (nonatomic, strong) UIImageView *homeTitleBgImageView;
//@property (nonatomic, strong) AnimLabel *homeTitleLabel;
//@property (nonatomic, strong) UIButton *homeShareButton;
@property (nonatomic, strong) AnimLabel *homeTopicsLabel;
@property (nonatomic, strong) UIButton *homeTopicsButton;
@property (nonatomic, strong) UIImageView *homeNewTopics;

@property (nonatomic, strong) UIButton *homeTotalTodayButton;
@property (nonatomic, strong) MoneyView *homeMoneyView;

@property (nonatomic, strong) UIImageView *chartTitleBgImageView;
@property (nonatomic, strong) UILabel *chartTitleLabel;
@property (nonatomic, strong) UIButton *chartDailyMonthlyButton;
@property (nonatomic, strong) MoneyView *chartMoneyView;

@property (nonatomic, strong) UIImageView *detailTitleBgImageView;
@property (nonatomic, strong) UILabel *detailTitleLabel;
@property (nonatomic, strong) MoneyView *detailMoneyView;

@property (nonatomic, assign) BOOL animating;

@property (nonatomic, strong) NSTimer *timer;
// topics
@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *topics;
@property (strong, nonatomic) NSString *newsId;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.homeViewController = [[HomeViewController alloc] init];
        [self.homeViewController setDelegate:self];
        [self addChildViewController:self.homeViewController];
        
        self.chartViewController = [[ChartViewController alloc] init];
        [self.chartViewController setDelegate:self];
        [self addChildViewController:self.chartViewController];
        
        self.detailViewController = [[DetailViewController alloc] init];
        [self.detailViewController setDelegate:self];
        [self addChildViewController:self.detailViewController];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hanldeHomeDataUpdateNotification:) name:HomeDataUpdateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hanldeChartDataUpdateNotification:) name:ChartDataUpdateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hanldeDetailDataUpdateNotification:) name:DetailDataUpdateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleThemeChangeNotification:) name:ThemeChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDailyMonthlySwitchNotification:) name:DailyMonthlySwitchNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView
{
    [super loadView];
    
    UIImage *topBgImage = [UIImage imageNamed:@"bgtop" themeType:CurrentThemeType];
    self.topBgImageView = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(topBgImage, (SCREEN_WIDTH - topBgImage.size.width) / 2, 0)];
    [self.topBgImageView setImage:topBgImage];
    [self.view addSubview:self.topBgImageView];
    
    UIImage *centerBarImage = [UIImage imageNamed:@"bgtop2"];
    self.centerBarImageView = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(centerBarImage, 0, 144.0)];
    [self.centerBarImageView setImage:centerBarImage];
    [self.view addSubview:self.centerBarImageView];
    
//    [self beginAppearanceTransition:YES animated:NO];
    [self.homeViewController.view setFrame:self.view.bounds];
    [self.view addSubview:self.homeViewController.view];
//    [self endAppearanceTransition];
    
    [self.view bringSubviewToFront:self.centerBarImageView];
    [self setCurrentViewController:self.homeViewController];
    
    [self showHomeTopView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    [leftSwipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:leftSwipeGestureRecognizer];
    
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    [rightSwipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipeGestureRecognizer];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
    [self.timer fire];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setLabel) name:@"setLabel" object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self performSelector:@selector(loadTopics) withObject:nil afterDelay:0.0];
}

- (void)handleTimer:(NSTimer *)timer
{
    [LogUtils saveRunningLog:[NSString stringWithFormat:@"起動中チェック：%@\n", [[NSDate date] localStringWithFormat:DB_DATE_YMDHMS]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
//    if (!DEBUG_MODE) {
//        // Notification
//        NSString *body = [AppManager pushMessageForKey:MSGMemoryWarning];
//        [AppManager addLocalNotification:body];
//    }
}

#pragma mark - Private

- (void)showHomeTopView
{
    if (!self.homeTopView) {
        self.homeTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 170.0)];
        [self.view addSubview:self.homeTopView];
        
        UIImage *titleBgImage = [UIImage imageNamed:@"wakubg" themeType:CurrentThemeType];
        self.homeTitleBgImageView = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(titleBgImage, 20.0, 40.0)];
        [self.homeTitleBgImageView setUserInteractionEnabled:YES];
        [self.homeTitleBgImageView setImage:titleBgImage];
        [self.homeTopView addSubview:self.homeTitleBgImageView];
        
        self.homeTopicsLabel = [[AnimLabel alloc] initWithFrame:CGRectMake(0.0, 0, 230.0, self.homeTitleBgImageView.height)];
        [self.homeTopicsLabel setText:@""];
        [self.homeTitleBgImageView addSubview:self.homeTopicsLabel];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showNews)];
        [self.homeTopicsLabel addGestureRecognizer:tapGesture];
        
//        self.homeTitleLabel = [[AnimLabel alloc] initWithFrame:CGRectMake(0.0, 0, 230.0, self.homeTitleBgImageView.height)];
//        [self.homeTitleLabel setText:@""];
        //[self.homeTitleBgImageView addSubview:self.homeTitleLabel];
        
//        UIImage *shareImage = [UIImage imageNamed:@"share" themeType:CurrentThemeType];
//        self.homeShareButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self.homeShareButton setFrame:CGRectOffsetFromImage(shareImage, 234.0, (self.homeTitleBgImageView.height - shareImage.size.height) / 2)];
//        [self.homeShareButton setImage:shareImage forState:UIControlStateNormal];
//        [self.homeShareButton addTarget:self action:@selector(shareButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [self.homeTitleBgImageView addSubview:self.homeShareButton];
        UIImage *topicsImage = [UIImage imageNamed:@"btn_topics" themeType:CurrentThemeType];
        self.homeTopicsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.homeTopicsButton setFrame:CGRectMake(220, 0, 60, 31)];
        [self.homeTopicsButton setImage:topicsImage forState:UIControlStateNormal];
        [self.homeTopicsButton addTarget:self action:@selector(topicsButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.homeTitleBgImageView addSubview:self.homeTopicsButton];
        
        self.homeNewTopics = [[UIImageView alloc] initWithFrame:CGRectMake(265, -5, 20, 20)];
        self.homeNewTopics.image = [UIImage imageNamed:@"newIcon"];
        self.homeNewTopics.hidden = YES;
        [self.homeTitleBgImageView addSubview:self.homeNewTopics];
        
        UIImage *totalTodayImage = nil;
        if (self.homeViewController.homeType == HomeTypeTotal) {
            totalTodayImage = [UIImage imageNamed:@"total" themeType:CurrentThemeType];
        } else {
            totalTodayImage = [UIImage imageNamed:@"today" themeType:CurrentThemeType];
        }
        self.homeTotalTodayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.homeTotalTodayButton setFrame:CGRectOffsetFromImage(totalTodayImage, 19.0, 88.0)];
        [self.homeTotalTodayButton setImage:totalTodayImage forState:UIControlStateNormal];
        [self.homeTotalTodayButton addTarget:self action:@selector(totalTodayButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.homeTopView addSubview:self.homeTotalTodayButton];
        
        self.homeMoneyView = [[MoneyView alloc] initWithFrame:CGRectMake(72.0, 90.0, 232.0, 42.0)];
        [self.homeMoneyView setMoney:0 withThemeType:CurrentThemeType];
        [self.homeTopView addSubview:self.homeMoneyView];
    }
    CGFloat x = 0;
    if (self.currentTopView == self.chartTopView) {
        x = SCREEN_WIDTH;
    } else {
        x = - SCREEN_WIDTH;
    }
    [self transitionFromView:self.currentTopView toView:self.homeTopView fromEndPositionX:-x];
}

- (void)showChartTopView
{
    if (!self.chartTopView) {
        self.chartTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 170.0)];
        [self.view addSubview:self.chartTopView];
        
        UIImage *titleBgImage = [UIImage imageNamed:@"wakubg2" themeType:CurrentThemeType];
        self.chartTitleBgImageView = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(titleBgImage, 20.0, 40.0)];
        [self.chartTitleBgImageView setUserInteractionEnabled:YES];
        [self.chartTitleBgImageView setImage:titleBgImage];
        [self.chartTopView addSubview:self.chartTitleBgImageView];
        
        self.chartTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 0, 270.0, self.chartTitleBgImageView.height)];
        [self.chartTitleLabel setBackgroundColor:[UIColor clearColor]];
        [self.chartTitleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [self.chartTitleLabel setTextColor:[UIColor whiteColor]];
        [self.chartTitleLabel setText:@"0時間0分残業しています。"];
        [self.chartTitleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.chartTitleBgImageView addSubview:self.chartTitleLabel];
        
        UIImage *dailyMonthlyImage = nil;
        if (self.chartViewController.chartType == ChartTypeMonthly) {
            dailyMonthlyImage = [UIImage imageNamed:@"monthly" themeType:CurrentThemeType];
        } else {
            dailyMonthlyImage = [UIImage imageNamed:@"daily" themeType:CurrentThemeType];
        }
        self.chartDailyMonthlyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.chartDailyMonthlyButton setFrame:CGRectOffsetFromImage(dailyMonthlyImage, 19.0, 88.0)];
        [self.chartDailyMonthlyButton setImage:dailyMonthlyImage forState:UIControlStateNormal];
        [self.chartDailyMonthlyButton addTarget:self action:@selector(dailyMonthlyButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.chartTopView addSubview:self.chartDailyMonthlyButton];
        
        self.chartMoneyView = [[MoneyView alloc] initWithFrame:CGRectMake(72.0, 90.0, 232.0, 42.0)];
        [self.chartMoneyView setMoney:0 withThemeType:CurrentThemeType];
        [self.chartTopView addSubview:self.chartMoneyView];
    }
    [self transitionFromView:self.currentTopView toView:self.chartTopView fromEndPositionX:SCREEN_WIDTH];
}

- (void)showDetailTopView
{
    if (!self.detailTopView) {
        self.detailTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 170.0)];
        [self.detailTopView setUserInteractionEnabled:NO];
        [self.view addSubview:self.detailTopView];
        
        UIImage *titleBgImage = [UIImage imageNamed:@"wakubg2" themeType:CurrentThemeType];
        self.detailTitleBgImageView = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(titleBgImage, 20.0, 40.0)];
        [self.detailTitleBgImageView setImage:titleBgImage];
        [self.detailTopView addSubview:self.detailTitleBgImageView];
        
        self.detailTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 0, 270.0, self.detailTitleBgImageView.height)];
        [self.detailTitleLabel setBackgroundColor:[UIColor clearColor]];
        [self.detailTitleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [self.detailTitleLabel setTextColor:[UIColor whiteColor]];
        [self.detailTitleLabel setText:@"0時間0分残業しています。"];
        [self.detailTitleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.detailTitleBgImageView addSubview:self.detailTitleLabel];
        
        self.detailMoneyView = [[MoneyView alloc] initWithFrame:CGRectMake(72.0, 90.0, 232.0, 42.0)];
        [self.detailMoneyView setMoney:0 withThemeType:CurrentThemeType];
        [self.detailTopView addSubview:self.detailMoneyView];
    }
    [self transitionFromView:self.currentTopView toView:self.detailTopView fromEndPositionX:-SCREEN_WIDTH];
}

- (void)totalTodayButtonDidClicked:(UIButton *)button
{
    if (self.homeViewController.homeType == HomeTypeTotal) {
        [self.homeViewController setHomeType:HomeTypeToday];
        [button setImage:[UIImage imageNamed:@"today" themeType:CurrentThemeType] forState:UIControlStateNormal];
        
        if ([[[AppManager sharedInstance] currentDay] money] < 1) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"今日の残業代はまだ発生してないです。8時間以上仕事したり、22時以降に仕事したり、休日出勤すると発生します。" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
        }
    } else {
        [self.homeViewController setHomeType:HomeTypeTotal];
        [button setImage:[UIImage imageNamed:@"total" themeType:CurrentThemeType] forState:UIControlStateNormal];
    }
    [self.homeViewController reloadTotalTodayData];
}

- (void)dailyMonthlyButtonDidClicked:(UIButton *)button
{
    [button setEnabled:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1ull * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [button setEnabled:YES];
    });
    if (self.chartViewController.chartType == ChartTypeMonthly) {
        [self.chartViewController setChartType:ChartTypeDaily];
        [button setImage:[UIImage imageNamed:@"daily" themeType:CurrentThemeType] forState:UIControlStateNormal];
    } else {
        [self.chartViewController setChartType:ChartTypeMonthly];
        [button setImage:[UIImage imageNamed:@"monthly" themeType:CurrentThemeType] forState:UIControlStateNormal];
    }
    [self.chartViewController resetDate];
    [self.chartViewController reloadData];
}

- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)recognizer
{
    if (!self.animating) {
        switch (recognizer.direction) {
            case UISwipeGestureRecognizerDirectionLeft:
                if (self.currentViewController == self.homeViewController) {
                    [self forwardToDetailView];
                } else if (self.currentViewController == self.chartViewController) {
                    [self forwardToHomeView];
                }
                
                break;
            case UISwipeGestureRecognizerDirectionRight:
                if (self.currentViewController == self.homeViewController) {
                    [self forwardToChartView];
                } else if (self.currentViewController == self.detailViewController) {
                    [self forwardToHomeView];
                }
                
                break;
            default:
                break;
        }
    }
}

- (void)transitionFromView:(UIView *)fromView toView:(UIView *)toView fromEndPositionX:(CGFloat)positionX
{
    [self setAnimating:YES];
    
    [toView setFrame:CGRectMake(-positionX, 0, toView.width, toView.height)];
    
    [UIView animateWithDuration:TRANSITION_DURATION animations:^{
        [toView setFrame:CGRectMake(0, 0, toView.width, toView.height)];
        [fromView setFrame:CGRectMake(positionX, 0, fromView.width, fromView.height)];
    } completion:^(BOOL finished) {
        [self.view bringSubviewToFront:toView];
        [self setCurrentTopView:toView];
        [self setAnimating:NO];
    }];
    
//    [UIView animateWithDuration:TRANSITION_DURATION animations:^{
//        [fromView setAlpha:0.0];
//    } completion:^(BOOL finished) {
//        [fromView setHidden:YES];
//        [toView setAlpha:0.0];
//        [toView setHidden:NO];
//        [UIView animateWithDuration:TRANSITION_DURATION animations:^{
//            [toView setAlpha:1.0];
//        } completion:^(BOOL finished) {
//            [self.view bringSubviewToFront:toView];
//            [self setCurrentTopView:toView];
//            [self setAnimating:NO];
//        }];
//    }];
}

- (void)shareButtonDidClicked:(UIButton *)button
{
    [button setEnabled:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1ull * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [button setEnabled:YES];
    });
    [ShareViewController showInController:self.navigationController];
}

- (void)forwardToHomeView
{
    UIViewController *fromViewController = self.currentViewController;
    UIViewController *toViewController = self.homeViewController;
    
    CGFloat x = 0;
    if (fromViewController == self.chartViewController) {
        x = SCREEN_WIDTH;
    } else {
        x = - SCREEN_WIDTH;
    }
    [self transitionFromViewController:fromViewController toViewController:toViewController fromEndPositionX:-x];
    [self showHomeTopView];
}

- (void)forwardToDetailView
{
    UIViewController *fromViewController = self.currentViewController;
    UIViewController *toViewController = self.detailViewController;
    
    [self transitionFromViewController:fromViewController toViewController:toViewController fromEndPositionX:-SCREEN_WIDTH];
    [self showDetailTopView];
}

- (void)forwardToChartView
{
    UIViewController *fromViewController = self.currentViewController;
    UIViewController *toViewController = self.chartViewController;
    
    [self transitionFromViewController:fromViewController toViewController:toViewController fromEndPositionX:SCREEN_WIDTH];
    [self showChartTopView];
}

- (void)transitionFromViewController:(UIViewController *)fromViewController
                    toViewController:(UIViewController *)toViewController
                    fromEndPositionX:(CGFloat)positionX
{
    [toViewController.view setFrame:CGRectMake(-positionX, 0, fromViewController.view.width, fromViewController.view.height)];
    
    [self transitionFromViewController:fromViewController
                      toViewController:toViewController
                              duration:TRANSITION_DURATION
                               options:UIViewAnimationOptionCurveEaseInOut
                            animations:^{
                                [self.view bringSubviewToFront:self.centerBarImageView];
                                [toViewController.view setFrame:CGRectMake(0, 0, toViewController.view.width, toViewController.view.height)];
                                [fromViewController.view setFrame:CGRectMake(positionX, 0, fromViewController.view.width, fromViewController.view.height)];
                            }
                            completion:^(BOOL finished) {
                                [fromViewController.view removeFromSuperview];
                                [self setCurrentViewController:toViewController];
                            }];
}

#pragma mark - HomeViewControllerDelegate

- (void)forwardToChartViewFromHomeView:(HomeViewController *)homeViewController
{
    [self forwardToChartView];
}

- (void)homeViewController:(HomeViewController *)homeViewController forwardToDetailViewWithShowType:(DetailShowType)detailShowType
{
    [self.detailViewController setDetailShowType:detailShowType];
    [self forwardToDetailView];
}

#pragma mark - ChartViewControllerDelegate

- (void)forwardToHomeViewFromChartView:(ChartViewController *)chartViewController
{
    [self forwardToHomeView];
}

- (void)chartViewController:(ChartViewController *)chartViewController forwardToDetailViewOnDate:(NSDate *)date
{
    [self.detailViewController setDetailShowType:DetailShowTypeChart];
    [self.detailViewController setSelectedDate:date];
    [self forwardToDetailView];
}

- (void)forwardToHomeViewFromHomeView:(HomeViewController *)homeViewController
{
    [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
    } completion:^(BOOL finished) {
        UIViewController *fromViewController = self.currentViewController;
        UIViewController *toViewController = self.homeViewController;
        
        [toViewController.view setFrame:CGRectMake(0, 0, toViewController.view.width, toViewController.view.height)];
        [self.view addSubview:toViewController.view];
        [fromViewController.view removeFromSuperview];
        [self setCurrentViewController:toViewController];
        
        [self.view bringSubviewToFront:self.centerBarImageView];
        
        [self showHomeTopView];
    }];
}

#pragma mark - DetailViewControllerDelegate

- (void)forwardToHomeViewFromDetailView:(DetailViewController *)detailViewController
{
    [self forwardToHomeView];
}

#pragma mark - Notification

// Home
- (void)hanldeHomeDataUpdateNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    [self performSelectorOnMainThread:@selector(processHomeDataUpdate:) withObject:userInfo waitUntilDone:NO];
}

- (void)processHomeDataUpdate:(NSDictionary *)userInfo
{
    NSNumber *money = userInfo[DataUpdateKeyMoney];
    [self.homeMoneyView setMoney:[money integerValue] withThemeType:CurrentThemeType];
    
    NSNumber *hour = userInfo[DataUpdateKeyHour];
    if ([hour doubleValue] >= 10) {
        NSInteger type = arc4random() % 9;
        [Master saveValue:[NSString stringWithFormat:@"%d", (int)type] forKey:MSTKeyHomeMsgType];
//        [self.homeTitleLabel setText:[AppManager homeMessageForHour:[hour doubleValue]]];
    } else {
//        [self.homeTitleLabel setText:@""];
    }
}

// Chart
- (void)hanldeChartDataUpdateNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    [self performSelectorOnMainThread:@selector(processChartDataUpdate:) withObject:userInfo waitUntilDone:NO];
}

- (void)processChartDataUpdate:(NSDictionary *)userInfo
{
    NSNumber *money = userInfo[DataUpdateKeyMoney];
    [self.chartMoneyView setMoney:[money integerValue] withThemeType:CurrentThemeType];
    
    NSNumber *hour = userInfo[DataUpdateKeyHour];
    [self.chartTitleLabel setText:[self stringForHour:[hour doubleValue]]];
}

// Detail
- (void)hanldeDetailDataUpdateNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    [self performSelectorOnMainThread:@selector(processDetailDataUpdate:) withObject:userInfo waitUntilDone:NO];
}

- (void)processDetailDataUpdate:(NSDictionary *)userInfo
{
    NSNumber *money = userInfo[DataUpdateKeyMoney];
    [self.detailMoneyView setMoney:[money integerValue] withThemeType:CurrentThemeType];
    
    NSNumber *hour = userInfo[DataUpdateKeyHour];
    [self.detailTitleLabel setText:[self stringForHour:[hour doubleValue]]];
}

// Time message
- (NSString *)stringForHour:(double)hour
{
    NSInteger h = floor(hour);
    NSInteger m = (hour - h) * 60;
    return [NSString stringWithFormat:@"%d時間%d分残業しています。", (int)h, (int)m];
}

- (void)handleThemeChangeNotification:(NSNotification *)notification
{
    UIImage *topBgImage = [UIImage imageNamed:@"bgtop" themeType:CurrentThemeType];
    [self.topBgImageView setImage:topBgImage];
    
    UIImage *titleBgImage1 = [UIImage imageNamed:@"wakubg" themeType:CurrentThemeType];
    [self.homeTitleBgImageView setImage:titleBgImage1];
    
//    UIImage *shareImage = [UIImage imageNamed:@"share" themeType:CurrentThemeType];
//    [self.homeShareButton setImage:shareImage forState:UIControlStateNormal];
    UIImage *topicsImage = [UIImage imageNamed:@"btn_topics" themeType:CurrentThemeType];
    [self.homeTopicsButton setImage:topicsImage forState:UIControlStateNormal];
    
    UIImage *totalTodayImage = nil;
    if (self.homeViewController.homeType == HomeTypeTotal) {
        totalTodayImage = [UIImage imageNamed:@"total" themeType:CurrentThemeType];
    } else {
        totalTodayImage = [UIImage imageNamed:@"today" themeType:CurrentThemeType];
    }
    [self.homeTotalTodayButton setImage:totalTodayImage forState:UIControlStateNormal];
    
    [self.homeMoneyView setMoney:self.homeMoneyView.money withThemeType:CurrentThemeType];
    
    UIImage *titleBgImage2 = [UIImage imageNamed:@"wakubg2" themeType:CurrentThemeType];
    [self.chartTitleBgImageView setImage:titleBgImage2];
    
    UIImage *dailyMonthlyImage = nil;
    if (self.chartViewController.chartType == ChartTypeMonthly) {
        dailyMonthlyImage = [UIImage imageNamed:@"monthly" themeType:CurrentThemeType];
    } else {
        dailyMonthlyImage = [UIImage imageNamed:@"daily" themeType:CurrentThemeType];
    }
    [self.chartDailyMonthlyButton setImage:dailyMonthlyImage forState:UIControlStateNormal];
    
    [self.chartMoneyView setMoney:self.chartMoneyView.money withThemeType:CurrentThemeType];
    
    UIImage *titleBgImage3 = [UIImage imageNamed:@"wakubg2" themeType:CurrentThemeType];
    [self.detailTitleBgImageView setImage:titleBgImage3];
    
    [self.detailMoneyView setMoney:self.detailMoneyView.money withThemeType:CurrentThemeType];
}

- (void)handleDailyMonthlySwitchNotification:(NSNotification *)notification
{
    UIImage *dailyMonthlyImage = nil;
    if (self.chartViewController.chartType == ChartTypeMonthly) {
        dailyMonthlyImage = [UIImage imageNamed:@"monthly" themeType:CurrentThemeType];
    } else {
        dailyMonthlyImage = [UIImage imageNamed:@"daily" themeType:CurrentThemeType];
    }
    [self.chartDailyMonthlyButton setImage:dailyMonthlyImage forState:UIControlStateNormal];
}

- (void)topicsButtonDidClicked:(UIButton *)button
{
    TopicsListViewController *controller = [[TopicsListViewController alloc] init];
    NSDictionary *parameters = [[GAIDictionaryBuilder createEventWithCategory:@"残トピボタン押下" action:nil label:nil value:nil] build];
    [[[GAI sharedInstance] defaultTracker] send:parameters];
    [self.navigationController pushViewController:controller animated:YES];
    if (_time != nil && ![@"" isEqualToString:_time]) {
        [[NSUserDefaults standardUserDefaults] setValue:_time forKey:KEY_TOPICS_TIME];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(void)loadTopics {
    AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
    NSDictionary* params = @{@"uuid" : OTUUID};
    [manager POST:@"/news/latest" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        BaseResponse *response = [MTLJSONAdapter modelOfClass:BaseResponse.class fromJSONDictionary:responseObject error:&error];
        if (!error && response.error == ErrorNone) {
            NSString *topics = responseObject[@"news_title"];
            NSString *date = responseObject[@"update_date"];
            NSString *newsId = responseObject[@"news_id"];
            [self setTopics:topics time:date newsId:newsId];
        } else if (response.error == ErrorUUIDNotFound) {
            [[AppManager sharedInstance] requestUUID];
            [self setTopics:@"" time:@"" newsId:@""];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppManager requestDidFailed:error];
        [self setTopics:@"" time:@"" newsId:@""];
    }];
}

-(void)setTopics: (NSString *)topics time:(NSString *)time newsId:(NSString *)newsId {
    if ([@"" isEqualToString:topics]) {
        topics = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_TOPICS];
        newsId = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_NEWS_ID];
        [self.homeTopicsLabel setText:topics];
        _topics = topics;
        _newsId = newsId;
    } else {
        [[NSUserDefaults standardUserDefaults] setValue:topics forKey:KEY_TOPICS];
        [[NSUserDefaults standardUserDefaults] setValue:newsId forKey:KEY_NEWS_ID];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.homeTopicsLabel setText:topics];
        _topics = topics;
        _newsId = newsId;
    }
    
    if ([@"" isEqualToString:time]) {
//        self.homeNewTopics.hidden = YES;
    } else {
        NSString *oldTimeStr = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_TOPICS_TIME];
        if (oldTimeStr == nil || [@"" isEqualToString:oldTimeStr]) {
            self.homeNewTopics.hidden = NO;
//            [[NSUserDefaults standardUserDefaults] setValue:time forKey:KEY_TOPICS_TIME];
//            [[NSUserDefaults standardUserDefaults] synchronize];
            self.time = time;
            
        } else {
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *oldTime = [formatter dateFromString:oldTimeStr];
            NSDate *newTime = [formatter dateFromString:time];
            NSComparisonResult result = [newTime compare:oldTime];
            if (result == NSOrderedDescending) {
                self.homeNewTopics.hidden = NO;
//                [[NSUserDefaults standardUserDefaults] setValue:time forKey:KEY_TOPICS_TIME];
//                [[NSUserDefaults standardUserDefaults] synchronize];
                self.time = time;
            } else {
                self.homeNewTopics.hidden = YES;
            }
        }
    }
}

-(void) setLabel {
    if (_topics != nil && ![@"" isEqualToString:_topics]) {
        [self.homeTopicsLabel setText:_topics];
    }
}

-(void) showNews {
    if (_newsId != nil && ![@"" isEqualToString:_newsId]) {
        TopicsDetailViewController *controller = [[TopicsDetailViewController alloc] init];
        controller.newsId = _newsId;
        NSDictionary *parameters = [[GAIDictionaryBuilder createEventWithCategory:@"ティッカータップ" action:_newsId label:nil value:nil] build];
        [[[GAI sharedInstance] defaultTracker] send:parameters];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
