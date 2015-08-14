//
//  WebViewController.m
//  Overtime
//
//  Created by xuxiaoteng on 2/3/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import "WebViewController.h"
#import "AchievementViewController.h"
#import "SettingInviteViewController.h"
#import "SettingInviteCodeViewController.h"

@interface WebViewController () <UIWebViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, copy) NSString *headerTitle;
@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, copy) NSString *taskTag;
@property (nonatomic, assign) WebVCType webVCType;

@end

@implementation WebViewController

- (id)initWithTitle:(NSString *)title URLString:(NSString *)urlString webVCType:(WebVCType)webVCType
{
    self = [super init];
    if (self) {
        _headerTitle = title;
        _urlString = urlString;
        _webVCType = webVCType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (self.webVCType == WebVCTypeTask) {
        [self configHeaderTitle:self.headerTitle separatorLine:NO];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
    } else {
        [self configHeaderTitle:self.headerTitle separatorLine:YES];
    }
    [self configBackButton];
    
    [self.contentView setBackgroundColor:[UIColor blackColor]];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.contentView.bounds];
    [self.webView setBackgroundColor:[UIColor blackColor]];
    [self.webView setDelegate:self];
    [self.webView setScalesPageToFit:YES];
    [self.webView setOpaque:NO];
    [self.webView.scrollView setBounces:NO];
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
    [mutableRequest setValue:MASTER(MSTKeyUUID) forHTTPHeaderField:@"uuid"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [mutableRequest setValue:version forHTTPHeaderField:@"version"];
    [self.webView loadRequest:mutableRequest];
    [self.contentView addSubview:self.webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)baseBackButtonDidClicked:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
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
            if (self.webVCType == WebVCTypeTask) {
                [self.webView reload];
            }
        } else if ([responseObject[@"error"] integerValue] == ErrorUUIDNotFound) {
            // Save uuid flag
            [Master saveValue:@"" forKey:MSTKeyUserLogined];
            // Relogin
            [[AppManager sharedInstance] requestUUID];
        } else {
            if (![taskTag isEqualToString:TASK_SUGGEST]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:responseObject[@"error_message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alertView show];
            }
        }
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppManager requestDidFailed:error];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
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

- (void)addReview:(NSString *)taskTag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"お喜びの声は是非レビューで叫んでください。\nやっぱり★は５ですよね！" delegate:nil cancelButtonTitle:@"キャンセル" otherButtonTitles:@"Storeへ遷移", nil];
    [alertView setTag:AlertViewTagReview];
    [alertView setDelegate:self];
    [alertView show];
}

- (void)followOrezanTwitterBot:(NSString *)taskTag
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // Create an account store object.
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    // Create an account type that ensures Twitter accounts are retrieved.
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    // Request access from the user to use their Twitter accounts.
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            // Get the list of Twitter accounts.
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            
            if (accountsArray.count > 0) {
                SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/create.json"] parameters:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Orezan_bot", @"true", nil] forKeys:[NSArray arrayWithObjects:@"screen_name", @"follow", nil]]];
                [request setAccount:[accountsArray lastObject]];
                [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        
                        BOOL result = NO;
                        if (responseData) {
                            NSError *jsonError = nil;
                            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&jsonError];
                            if ([[responseDictionary allKeys] containsObject:@"following"]) {
                                result = YES;
                                [self requestTaskComplete:taskTag];
                            }
                        }
                        if (!result) {
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"フォローが失敗してしまいました。" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                            [alertView show];
                        }
                    });
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Twitterアカウントがありません" message:@"Twitterアカウントが設定されていません。Twitterアカウントは\"設定\"で作成／追加できます。" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alertView show];
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"端末の設定から、Twitterの権限を許可してみてくださいね。" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alertView show];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            });
        }
    }];
}

- (void)forwardToSNS
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ForwardToSNSNotification object:nil];
}

- (void)forwardToInvite
{
    SettingInviteViewController *settingInviteVC = [[SettingInviteViewController alloc] init];
    [self.navigationController pushViewController:settingInviteVC animated:YES];
}

- (void)forwardToInviteCode
{
    SettingInviteCodeViewController *settingInviteCodeVC = [[SettingInviteCodeViewController alloc] init];
    [self.navigationController pushViewController:settingInviteCodeVC animated:YES];
}

- (void)forwardToSuggestion
{
    WebViewController *webViewController = [[WebViewController alloc] initWithTitle:@"ご意見箱" URLString:SUGGEST_URL webVCType:WebVCTypeSuggest];
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)downloadNewApp
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_URL]];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == AlertViewTagReview) {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:REVIEW_URL]];
            [self requestTaskComplete:self.taskTag];
        }
    }
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSLog(@"%@", request.URL.absoluteString);
        
        if (self.webVCType == WebVCTypeTask) {
            if ([request.URL.scheme isEqualToString:@"orezan"]) {
                NSString *taskTag = request.URL.host;
                self.taskTag = taskTag;
                
                if ([taskTag isEqualToString:TASK_INVITED]) {
                    [self forwardToInvite];
                } else if ([taskTag isEqualToString:TASK_INVITE]) {
                    [self forwardToInviteCode];
                } else if ([taskTag isEqualToString:TASK_SNS_LIKE] || [taskTag isEqualToString:TASK_SNS_MURMUR] || [taskTag isEqualToString:TASK_SNS_PROFILE]) {
                    [self forwardToSNS];
                } else if ([taskTag isEqualToString:TASK_SUGGEST]) {
                    [self forwardToSuggestion];
                } else if ([taskTag isEqualToString:TASK_FB_SHARE]) {
                    NSString *shareText = [[AppManager sharedInstance] shareTextWithURL:@"http://goo.gl/og6lAA"];
                    [self shareTextToFacebook:shareText taskTag:taskTag];
                } else if ([taskTag isEqualToString:TASK_TW_SHARE]) {
                    NSString *shareText = [[AppManager sharedInstance] shareTextWithURL:@"http://goo.gl/udUci0"];
                    [self shareTextToTwitter:shareText taskTag:taskTag];
                } else if ([taskTag isEqualToString:TASK_LINE_SHARE]) {
                    NSString *shareText = [[AppManager sharedInstance] shareTextWithURL:@"http://goo.gl/pPsMIA"];
                    [self shareTextToLine:shareText taskTag:taskTag];
                } else if ([taskTag isEqualToString:TASK_ADD_REVIEW]) {
                    [self addReview:taskTag];
                } else if ([taskTag isEqualToString:TASK_TW_FOLLOW]) {
                    [self followOrezanTwitterBot:taskTag];
                } else if ([taskTag isEqualToString:TASK_APP_VERSION]) {
                    [self downloadNewApp];
                }
                return NO;
            }
        }
    }
    if (navigationType == UIWebViewNavigationTypeFormSubmitted && self.webVCType == WebVCTypeSuggest) {
        [self requestTaskComplete:TASK_SUGGEST];
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
