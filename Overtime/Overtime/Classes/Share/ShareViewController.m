//
//  ShareViewController.m
//  Overtime
//
//  Created by xuxiaoteng on 2/26/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import "ShareViewController.h"
#import "AchievementViewController.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage *bgImage = [UIImage imageNamed:@"share_bg"];
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectFromImage(bgImage)];
    [bgImageView setUserInteractionEnabled:YES];
    [bgImageView setImage:bgImage];
    [self.view addSubview:bgImageView];
    
    UIImage *twitterImage = [UIImage imageNamed:@"share_twitter"];
    UIButton *twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [twitterButton setFrame:CGRectOffsetFromImage(twitterImage, (self.view.width - twitterImage.size.width) / 2.0, 133.0)];
    [twitterButton setImage:twitterImage forState:UIControlStateNormal];
    [twitterButton addTarget:self action:@selector(twitterButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:twitterButton];
    
    UIImage *facebookImage = [UIImage imageNamed:@"share_facebook"];
    UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [facebookButton setFrame:CGRectOffsetFromImage(facebookImage, (self.view.width - facebookImage.size.width) / 2.0, 205.0)];
    [facebookButton setImage:facebookImage forState:UIControlStateNormal];
    [facebookButton addTarget:self action:@selector(facebookButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:facebookButton];
    
    UIImage *lineImage = [UIImage imageNamed:@"share_line"];
    UIButton *lineButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [lineButton setFrame:CGRectOffsetFromImage(lineImage, (self.view.width - lineImage.size.width) / 2.0, 275.0)];
    [lineButton setImage:lineImage forState:UIControlStateNormal];
    [lineButton addTarget:self action:@selector(lineButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lineButton];
    
    UIImage *cancelImage = [UIImage imageNamed:@"share_cancel"];
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setFrame:CGRectOffsetFromImage(cancelImage, (self.view.width - cancelImage.size.width) / 2.0, 358.0)];
    [cancelButton setImage:cancelImage forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (ShareViewController *)showInController:(UIViewController *)viewController
{
    ShareViewController *shareViewController = [[ShareViewController alloc] init];
    UIView *sView = viewController.view;
    
    [viewController addChildViewController:shareViewController];
    [sView addSubview:shareViewController.view];
    [shareViewController.view setFrame:CGRectMake(0, sView.height, sView.width, sView.height)];
    
    [UIView animateWithDuration:0.3 animations:^{
        [shareViewController.view setTop:0];
    }];
    return shareViewController;
}

#pragma mark - Private

- (void)twitterButtonDidClicked:(UIButton *)button
{
    NSString *shareText = [[AppManager sharedInstance] shareTextWithURL:@"http://goo.gl/udUci0"];
    [self shareTextToTwitter:shareText taskTag:TASK_TW_SHARE];
}

- (void)facebookButtonDidClicked:(UIButton *)button
{
    NSString *shareText = [[AppManager sharedInstance] shareTextWithURL:@"http://goo.gl/og6lAA"];
    [self shareTextToFacebook:shareText taskTag:TASK_FB_SHARE];
}

- (void)lineButtonDidClicked:(UIButton *)button
{
    NSString *shareText = [[AppManager sharedInstance] shareTextWithURL:@"http://goo.gl/pPsMIA"];
    [self shareTextToLine:shareText taskTag:TASK_LINE_SHARE];
}

- (void)shareTextToFacebook:(NSString *)text taskTag:(NSString *)taskTag
{
    SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [composeViewController setInitialText:text];
    
    SLComposeViewControllerCompletionHandler completionHandler = ^(SLComposeViewControllerResult result) {
        if (result == SLComposeViewControllerResultDone) {
            [self requestTaskComplete:taskTag];
        }
    };
    [composeViewController setCompletionHandler:completionHandler];
    [self presentViewController:composeViewController animated:YES completion:nil];
}

- (void)shareTextToTwitter:(NSString *)text taskTag:(NSString *)taskTag
{
    SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [composeViewController setInitialText:text];
    
    SLComposeViewControllerCompletionHandler completionHandler = ^(SLComposeViewControllerResult result) {
        if (result == SLComposeViewControllerResultDone) {
            [self requestTaskComplete:taskTag];
        }
    };
    [composeViewController setCompletionHandler:completionHandler];
    [self presentViewController:composeViewController animated:YES completion:nil];
}

- (void)shareTextToLine:(NSString *)text taskTag:(NSString *)taskTag
{
    if ([ShareUtils isLineInstalled]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"line://msg/text/%@", [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
        [self requestTaskComplete:taskTag];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"LINEアプリがインストールされていません。" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"戻る", nil];
        [alertView show];
    }
}

- (void)cancelButtonDidClicked:(UIButton *)button
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.view setTop:self.view.bottom];
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

#pragma mark - Request

- (void)requestTaskComplete:(NSString *)taskTag
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppManager requestDidFailed:error];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}

@end
