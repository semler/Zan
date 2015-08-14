//
//  RLSNSViewController.m
//  Overtime
//
//  Created by Ryuukou on 4/2/15.
//  Copyright (c) 2015年 Bravesoft. All rights reserved.
//

#import "RLSNSViewController.h"
#import "RLSNSTutorialViewController.h"
#import "AchievementViewController.h"
#import "RLSNSTableViewCell.h"
#import "SNSReasonResponse.h"
#import "SNSReportReason.h"
#import "BaseResponse.h"
#import "SNSResponse.h"
#import "SNSFriend.h"
#import "SNSSelf.h"
#import "KeyboardView.h"
#import "SVPullToRefresh.h"

#define LAST_MURMUR_DATE  @"SNS_SUPPORT_DATE"
#define MURMUR_COUNT  @"MURMUR_COUNT"
#define PAGE_COUNT 20

@interface RLSNSViewController () <UITableViewDataSource, UITableViewDelegate,
SNSTableViewCellDelegate,UIActionSheetDelegate,KeyboardBarDelegate>
{
    UIView *_maskView;
}

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UIImageView *avatarView;
@property (nonatomic, weak) IBOutlet UIButton *supportButton;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *supportCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet UIView *tableHeaderView;
@property (nonatomic, weak) IBOutlet UIImageView *tableBackView;

@property (nonatomic, strong) SNSSelf *myProfile;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) NSArray *reportReasons;
@property (nonatomic, strong) SNSFriend *reportFriend;
@property (nonatomic, assign) NSInteger murmurCount;
@property (nonatomic, assign) BOOL tutorial;

@property (nonatomic, assign) BOOL requesting;
@property (nonatomic, assign) NSInteger pageNo;
@property (nonatomic, assign) BOOL hasMore;

@end

#define SNSCell  @"CellID"
#define ActionSheetOperation 1
#define ActionSheetReason 2

@implementation RLSNSViewController
@synthesize murmurCount = _murmurCount;

#pragma mark - View Life Cycle

- (id)initWithTutorial:(BOOL)tutorial
{
    self = [super init];
    if (self) {
        _tutorial = tutorial;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    self.dataSource = [NSMutableArray array];
    self.pageNo = 1;
    
    // test code
//    NSString *testFilePath = [[NSBundle mainBundle] pathForResource:@"SNStest" ofType:@"txt"];
//    NSData *data = [[NSData alloc] initWithContentsOfFile:testFilePath];
//    NSDictionary *testDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//    SNSResponse *response = [MTLJSONAdapter modelOfClass:SNSResponse.class fromJSONDictionary:testDic error:nil];
//    self.dataSource = [NSMutableArray arrayWithArray:response.friends];
    
    _maskView = [[UIView alloc] initWithFrame:self.view.frame];
    _maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    
    KeyboardView *view = (KeyboardView *)self.view;
    view.delegate = self;
    view.keyboardBarType = KeyboardBarTypeSNS;
    //title
    self.titleLabel.text = [NSString stringWithFormat:@"%@会社の\n%@", MASTER(MSTKeyCompany), MASTER(MSTKeyCareer)];
    // Message
    self.textView.text = MASTER(MSTKeyMessage);
    
    // table view
    self.tableView.tableHeaderView = self.tableHeaderView;
    self.tableView.backgroundView = self.tableBackView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"RLSNSTableViewCell" bundle:nil]
         forCellReuseIdentifier:SNSCell];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    __weak RLSNSViewController *weakSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        if (weakSelf.hasMore) {
            [weakSelf requestSNSData:NO];
        } else {
            [weakSelf.tableView setShowsInfiniteScrolling:NO];
        }
    }];
    [self.tableView.infiniteScrollingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    
    NSString *imageName = [NSString stringWithFormat:@"sns_btn_murmur%ld", (long)self.murmurCount];
    [self.supportButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    if (self.murmurCount == 0) {
        self.supportButton.enabled = NO;
    }

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestSNSData:YES];
}

#pragma mark - Property

- (void)setMurmurCount:(NSInteger)murmurCount
{
    _murmurCount = murmurCount;
    [Master saveValue:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] forKey:MSTKeyLastMurMurDate];
    [Master saveValue:[NSString stringWithFormat:@"%d",murmurCount] forKey:MSTKeyMurMurCount];
}

- (NSInteger)murmurCount
{
    NSInteger count;
    NSTimeInterval interval = [MASTER(MSTKeyLastMurMurDate) doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    if (!date || ![date isToday]) {
        if (self.tutorial) {
            count = 1;
        } else {
            count = 2;
        }
        [Master saveValue:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] forKey:MSTKeyLastMurMurDate];
        [Master saveValue:[NSString stringWithFormat:@"%d",count] forKey:MSTKeyMurMurCount];
    } else {
        count = [MASTER(MSTKeyMurMurCount) integerValue];
    }
    return count;
}

#pragma mark - NSNotification

- (void)handleEnterForegroundNotification:(NSNotification *)notification
{
    // Refresh
    [self requestSNSData:YES];
    
    // Murmur count
    NSString *imageName = [NSString stringWithFormat:@"sns_btn_murmur%ld", (long)self.murmurCount];
    [self.supportButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    if (self.murmurCount == 0) {
        self.supportButton.enabled = NO;
    }
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 117;
}

#pragma mark - Table View Data Source

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RLSNSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SNSCell forIndexPath:indexPath];
    SNSFriend *friendInfo = self.dataSource[indexPath.row];
    cell.friendInfo = friendInfo;
    cell.delegate = self;
    cell.row = indexPath.row;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

#pragma mark - Table View Celle Delegate

- (void)snsTableViewCellSupportHandle:(RLSNSTableViewCell *)cell
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
    NSDictionary *params = @{@"uuid" : MASTER(MSTKeyUUID), @"other_user_id" : cell.friendInfo.userID};
    [manager POST:@"/user/like" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        BaseResponse *response = [MTLJSONAdapter modelOfClass:BaseResponse.class fromJSONDictionary:responseObject error:&error];
        if (!error && response.error == ErrorNone) {
            SNSFriend *friendInfo = cell.friendInfo;
            friendInfo.isSupported = YES;
            friendInfo.supportCount = responseObject[@"like_num"];
//            self.dataSource[cell.row] = friendInfo;
            [self.tableView reloadData];
            
            if ([[AppManager sharedInstance] taskValidFromTag:TASK_SNS_LIKE]) {
                [self requestTaskComplete:TASK_SNS_LIKE];
            } else {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
        } else if ([responseObject[@"error"] integerValue] == ErrorUUIDNotFound) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            // Save uuid flag
            [Master saveValue:@"" forKey:MSTKeyUserLogined];
            // Relogin
            [[AppManager sharedInstance] requestUUID];
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppManager requestDidFailed:error];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}

- (void)snsTableViewCellReportHandle:(RLSNSTableViewCell *)cell
{
    self.reportFriend = cell.friendInfo;
    [self showOperationInActionSheet];
}

#pragma mark - Keyboard Bar Delegate

- (void)keyboardBar:(KeyboardBar *)keyboardBar
   inputDidFinished:(NSString *)text
{
    if (![self.textView.text isEqualToString:text]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
        NSDictionary *parameters = @{@"uuid": MASTER(MSTKeyUUID),@"message" : text};
        [manager POST:@"/user/message" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSError *error = nil;
            BaseResponse *response = [MTLJSONAdapter modelOfClass:BaseResponse.class fromJSONDictionary:responseObject error:&error];
            if (!error && response.error == ErrorNone) {
                self.murmurCount -= 1;
                self.textView.text = text;
                self.myProfile.message = text;
                self.myProfile.lastUpdateDate = [NSDate date];
                self.myProfile.supportCount = @"0";
                [self loadMyProfile:self.myProfile];
                
                NSDictionary *mineDic = [MTLJSONAdapter JSONDictionaryFromModel:self.myProfile error:nil];
                self.timeLabel.text = mineDic[@"message_last_updated"];
                [Master saveValue:text forKey:MSTKeyMessage];
                
                NSString *imageName = [NSString stringWithFormat:@"sns_btn_murmur%ld", (long)self.murmurCount];
                [self.supportButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
                if (self.murmurCount == 0) {
                    self.supportButton.enabled = NO;
                }
                if ([[AppManager sharedInstance] taskValidFromTag:TASK_SNS_MURMUR]) {
                    [self requestTaskComplete:TASK_SNS_MURMUR];
                } else {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }
            } else if ([responseObject[@"error"] integerValue] == ErrorUUIDNotFound) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                // Save uuid flag
                [Master saveValue:@"" forKey:MSTKeyUserLogined];
                // Relogin
                [[AppManager sharedInstance] requestUUID];
            } else {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [AppManager requestDidFailed:error];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
    }
    [self hideKeyboard];
}

#pragma mark - Task

- (void)requestTaskComplete:(NSString *)taskTag
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
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppManager requestDidFailed:error];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

#pragma mark - Action Sheet Actions

- (void)alertAction:(SNSReportReason *)reason
{
    if (self.reportFriend) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
        NSDictionary *param = @{@"uuid" : MASTER(MSTKeyUUID),
                                @"other_user_id" : self.reportFriend.userID,
                                @"reason_id" : @(reason.reasonID),
                                @"reason_content" : self.reportFriend.message};
        [manager POST:@"/user/report" parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            // report message success
            if ([responseObject[@"error"] integerValue] == ErrorNone) {
                self.reportFriend = nil;
            } else if ([responseObject[@"error"] integerValue] == ErrorUUIDNotFound) {
                // Save uuid flag
                [Master saveValue:@"" forKey:MSTKeyUserLogined];
                // Relogin
                [[AppManager sharedInstance] requestUUID];
            }
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            self.reportFriend = nil;
            [AppManager requestDidFailed:error];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == ActionSheetReason) {
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            SNSReportReason *reason = self.reportReasons[buttonIndex];
            [self alertAction:reason];
        }
    } else if (actionSheet.tag == ActionSheetOperation) {
        if (buttonIndex == 0) {
            [self requestReportReason];
        } else if (buttonIndex == 1) {
            [self blockUser];
        }
    }
}

#pragma mark - Method

- (void)hideKeyboard
{
    [_maskView removeFromSuperview];
    [self.view resignFirstResponder];
    [self enableUserInterface:YES];
}

- (void)enableUserInterface:(BOOL)enabled
{
    if (enabled) {
        [self.tableView setUserInteractionEnabled:YES];
        [self.supportButton setUserInteractionEnabled:YES];
    } else {
        [self.tableView setUserInteractionEnabled:NO];
        [self.supportButton setUserInteractionEnabled:NO];
    }
}

- (void)loadMyProfile:(SNSSelf *)profile
{
    NSDictionary *mineDic = [MTLJSONAdapter JSONDictionaryFromModel:profile error:nil];;
    self.textView.text = profile.message;
    self.timeLabel.text = mineDic[@"message_last_updated"];
    self.supportCountLabel.text = profile.supportCount;
    profile.level = [[AppManager sharedInstance] level];
    NSString *name = [AppManager avatarNameBySex:profile.sex levelType:profile.level];
    self.avatarView.image = [UIImage imageNamed:name];
    //title
    self.titleLabel.text = [NSString stringWithFormat:@"%@会社の\n%@", MASTER(MSTKeyCompany), MASTER(MSTKeyCareer)];
}

- (void)blockUser
{
    if (self.reportFriend) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
        NSDictionary *param = @{@"uuid" : MASTER(MSTKeyUUID),
                                @"other_user_id" : self.reportFriend.userID};
        [manager POST:@"/user/block" parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject[@"error"] integerValue] == ErrorNone) {
                if ([self.dataSource containsObject:self.reportFriend]) {
                    [self.dataSource removeObject:self.reportFriend];
                }
                self.reportFriend = nil;
                [self.tableView reloadData];
            } else if ([responseObject[@"error"] integerValue] == ErrorUUIDNotFound) {
                // Save uuid flag
                [Master saveValue:@"" forKey:MSTKeyUserLogined];
                // Relogin
                [[AppManager sharedInstance] requestUUID];
            }
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            self.reportFriend = nil;
            [AppManager requestDidFailed:error];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
    }
}

- (void)showOperationInActionSheet
{
    if (IOS8_OR_LATER) {
        UIAlertController *sheet = [UIAlertController alertControllerWithTitle:nil
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        [sheet addAction:[UIAlertAction actionWithTitle:@"このコメントを通報する"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                    [self requestReportReason];
                                                }]];
        [sheet addAction:[UIAlertAction actionWithTitle:@"このユーザーの表⽰をブロックする"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                    [self blockUser];
                                                }]];
        [sheet addAction:[UIAlertAction actionWithTitle:@"キャンセル"
                                                  style:UIAlertActionStyleCancel
                                                handler:nil]];
        [self presentViewController:sheet animated:YES completion:nil];
    } else {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"キャンセル" destructiveButtonTitle:nil otherButtonTitles:@"このコメントを通報する", @"このユーザーの表⽰をブロックする", nil];
        sheet.tag = ActionSheetOperation;
        [sheet showInView:self.view];
    }
}

- (void)showReasonsInActionSheet
{
    if (IOS8_OR_LATER) {
        UIAlertController *sheet = [UIAlertController alertControllerWithTitle:nil
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        for (int i = 0; i < self.reportReasons.count; i ++) {
            SNSReportReason *reason = self.reportReasons[i];
            [sheet addAction:[UIAlertAction actionWithTitle:reason.reasonContent
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) {
                                                        [self alertAction:reason];
            }]];
        }
        [sheet addAction:[UIAlertAction actionWithTitle:@"キャンセル"
                                                  style:UIAlertActionStyleCancel
                                                handler:nil]];
        [self presentViewController:sheet animated:YES completion:nil];
    } else {
        UIActionSheet *sheet = [[UIActionSheet alloc] init];
        sheet.delegate = self;
        sheet.tag = ActionSheetReason;
        [sheet setTitle:@""];
        for (int i = 0; i < self.reportReasons.count; i ++) {
            SNSReportReason *reason = self.reportReasons[i];
            [sheet addButtonWithTitle:reason.reasonContent];
        }
        sheet.cancelButtonIndex = -1;
        [sheet showInView:self.view];
    }
}

- (void)requestReportReason
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
    NSDictionary *param = @{@"uuid" : MASTER(MSTKeyUUID)};
    [manager POST:@"/report/reasons" parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        SNSReasonResponse *response = [MTLJSONAdapter modelOfClass:SNSReasonResponse.class fromJSONDictionary:responseObject error:&error];
        if (!error && response.error == ErrorNone) {
            self.reportReasons = response.reasons;
            [self showReasonsInActionSheet];
        } else if (response.error == ErrorUUIDNotFound) {
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

- (void)requestSNSData:(BOOL)animation
{
    if (!self.requesting) {
        [self setRequesting:YES];
        
        if (animation) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
        
        AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
        NSDictionary *param = @{@"uuid": MASTER(MSTKeyUUID),
                                @"level": @([AppManager sharedInstance].level),
                                @"page": @(self.pageNo),
                                @"limit": @(PAGE_COUNT)};
        [manager POST:@"/user/friends" parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self setRequesting:NO];
            NSError *error = nil;
            SNSResponse *response = [MTLJSONAdapter modelOfClass:SNSResponse.class fromJSONDictionary:responseObject error:&error];
            if (!error && response.error == ErrorNone) {
                self.myProfile = response.myProfile;
                [self loadMyProfile:self.myProfile];
                
                if (self.pageNo == 1) {
                    [self.dataSource removeAllObjects];
                }
                self.pageNo++;
                [self.dataSource addObjectsFromArray:response.friends];
                [self.tableView reloadData];
                
                if (response.friends.count < PAGE_COUNT) {
                    self.hasMore = NO;
                } else {
                    self.hasMore = YES;
                }
                [self.tableView.infiniteScrollingView stopAnimating];
            } else if (response.error == ErrorUUIDNotFound) {
                // Save uuid flag
                [Master saveValue:@"" forKey:MSTKeyUserLogined];
                // Relogin
                [[AppManager sharedInstance] requestUUID];
            }
            if (animation) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self setRequesting:NO];
            if (animation) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }
            [AppManager requestDidFailed:error];
        }];
    }
}

- (IBAction)updateData:(id)sender
{
    [self setPageNo:1];
    [self requestSNSData:YES];
}

- (IBAction)sendMurmur:(id)sender
{
    [self showKeyboard];
}

- (void)showKeyboard
{
    if (!self.view.isFirstResponder) {
        KeyboardView *View = (KeyboardView *)self.view;
        [View setInitialText:self.textView.text];
        [self.view addSubview:_maskView];
        [self.view becomeFirstResponder];
        [self enableUserInterface:NO];
    }
}

- (IBAction)goSetting:(id)sender
{
    RLSNSTutorialViewController *tutorialVC = [[RLSNSTutorialViewController alloc] initWithTutorial:NO];
    [self.navigationController pushViewController:tutorialVC animated:YES];
}

- (IBAction)goHome:(id)sender
{
    [self.navigationController popToViewController:self.homeVC animated:YES];
}

- (IBAction)scrollToTop:(id)sender
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
