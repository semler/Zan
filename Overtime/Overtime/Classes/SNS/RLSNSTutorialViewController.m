//
//  RLSNSTuturialViewController.m
//  Overtime
//
//  Created by Ryuukou on 21/1/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import "RLSNSTutorialViewController.h"
#import "RLTutorialView.h"
#import "RLSNSViewController.h"
#import "AchievementViewController.h"
#import "BaseResponse.h"
#import "SNSSelf.h"
#import "Master.h"
#import "iCloudUtils.h"
#import "Apsalar.h"

@interface RLSNSTutorialViewController () <RLTutorialDelegate,UIScrollViewDelegate>
{
    BOOL _checkResult;
    BOOL _tutorial;
}

@property (nonatomic, strong) UIScrollView *scrollView;

@end

#define MAX_PAGES 7

@implementation RLSNSTutorialViewController

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor blackColor];
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    _scrollView.pagingEnabled = YES;
    _scrollView.contentSize = CGSizeMake(self.view.width * MAX_PAGES, self.view.height);
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (instancetype)initWithTutorial:(BOOL)tutorial
{
    self = [super init];
    if (self) {
        _tutorial = tutorial;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    for (int i = 0; i < MAX_PAGES; i ++) {
        RLTutorialView *view = [[RLTutorialView alloc] initWithFrame:CGRectMake(i * self.view.width, 0, self.view.width, self.view.height) index:i tutorial:_tutorial];
        view.delegate = self;
        [self.scrollView addSubview:view];
    }
    if (_tutorial) {
        _checkResult = NO;
        self.scrollView.contentSize = CGSizeMake((MAX_PAGES - 1) * self.view.width, self.view.height);
    } else {
        _checkResult = YES;
        self.scrollView.scrollEnabled = NO;
        self.scrollView.contentSize = CGSizeMake(2 * self.view.width, self.view.height);
        [self.scrollView setContentOffset:CGPointMake((MAX_PAGES - 2) * self.view.width, 0)];
    }
}

- (void)tutorialViewButtonTaped:(RLTutorialView *)view withObject:(NSDictionary *)params
{
    if (view.index == (MAX_PAGES - 1)) {
        if (_tutorial) {
            [self poptoRoot];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else if (view.index == MAX_PAGES - 2) {
        if (_checkResult && params) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
            [manager POST:@"/user/profile" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSError *error = nil;
                BaseResponse *response = [MTLJSONAdapter modelOfClass:BaseResponse.class fromJSONDictionary:responseObject error:&error];
                if (!error && response.error == ErrorNone) {
                    // Upload database file to iCloud
                    [iCloudUtils uploadFileToiCloud];
                    // Task valid check
                    if (_tutorial && [[AppManager sharedInstance] taskValidFromTag:TASK_SNS_PROFILE]) {
                        [self requestTaskComplete:TASK_SNS_PROFILE atIndex:view.index];
                    } else {
                        self.scrollView.contentSize = CGSizeMake(MAX_PAGES * self.view.width, self.view.height);
                        [self.scrollView scrollRectToVisible:CGRectMake((view.index + 1) * self.view.width, 0,
                                                                        self.view.width, self.view.height) animated:YES];
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    }
                } else if (response.error == ErrorUUIDNotFound) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    // Save uuid flag
                    [Master saveValue:@"" forKey:MSTKeyUserLogined];
                    // Relogin
                    [[AppManager sharedInstance] requestUUID];
                } else {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [AppManager requestDidFailed:error];
            }];
        }
    } else {
        [self.scrollView scrollRectToVisible:CGRectMake((view.index + 1) * self.view.width, 0,
                                                        self.view.width, self.view.height) animated:YES];
    }
}

#pragma mark - Task

- (void)requestTaskComplete:(NSString *)taskTag atIndex:(NSInteger)index
{
    AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
    NSDictionary *parameters = @{@"uuid": MASTER(MSTKeyUUID), @"task_tag": taskTag};
    [manager POST:@"/task/complete" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"error"] integerValue] == ErrorNone) {
            Task *task = [[AppManager sharedInstance] taskFromTag:taskTag];
            [task setTask_date:[[NSDate date] localStringWithFormat:DB_DATE_YMDHMS]];
            [TaskUtils handleTaskComplete:task];
            [AchievementViewController showInController:self taskInfo:task];
        } else if ([responseObject[@"error"] integerValue] == ErrorUUIDNotFound) {
            // Save uuid flag
            [Master saveValue:@"" forKey:MSTKeyUserLogined];
            // Relogin
            [[AppManager sharedInstance] requestUUID];
        }
        self.scrollView.contentSize = CGSizeMake(MAX_PAGES * self.view.width, self.view.height);
        [self.scrollView scrollRectToVisible:CGRectMake((index + 1) * self.view.width, 0,
                                                        self.view.width, self.view.height) animated:YES];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppManager requestDidFailed:error];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)tutorialView:(RLTutorialView *)view
inputChangedWithResult:(BOOL)result
{
    _checkResult = result;
}

- (void)poptoRoot
{
    [Apsalar event:@"チュートリアル終了"];
    [Master saveValue:@"not" forKey:MSTKeyFirstLaunch];
    RLSNSViewController *snsVC = [[RLSNSViewController alloc] initWithTutorial:_tutorial];
    snsVC.homeVC = self.homeVC;
    [self.navigationController pushViewController:snsVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.x >= (MAX_PAGES - 1) * self.view.width) {
        [self performSelector:@selector(poptoRoot) withObject:nil afterDelay:0.2];
    }
}

@end
