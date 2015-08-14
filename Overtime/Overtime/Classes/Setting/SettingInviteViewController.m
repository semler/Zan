//
//  SettingInviteViewController.m
//  Overtime
//
//  Created by Ryuukou on 12/2/15.
//  Copyright (c) 2015年 Bravesoft. All rights reserved.
//

#import "SettingInviteViewController.h"
#import "BaseResponse.h"
#import "AchievementViewController.h"

@interface SettingInviteViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *codeTextField;

@end

@implementation SettingInviteViewController

#pragma mark - View Life Cycle

- (void)loadView
{
    [super loadView];

    [self configHeaderImage:@"setting_header" andBgImage:@"bg"];
    [self configBackButton];
    [self configSubTitle:@"紹介コード入力画面"];
    UIImage *lineImage = [UIImage imageNamed:@"separator_line"];
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(lineImage, 0, 56.0)];
    [lineImageView setImage:lineImage];
    [self.contentView addSubview:lineImageView];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(26, CGRectGetMaxY(lineImageView.frame) + 10, self.view.width - 52, 40)];
    tipLabel.text = @"友達から教えてもらった紹介コードを入力してください。イイことがあるようです。";
    tipLabel.numberOfLines = 2;
    tipLabel.font = [UIFont boldSystemFontOfSize:14.0];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:tipLabel];
    
    _codeTextField = [[UITextField alloc] initWithFrame:CGRectMake((self.view.width - 160) / 2, CGRectGetMaxY(tipLabel.frame) + 15, 160, 40)];
    _codeTextField.keyboardType = UIKeyboardTypeASCIICapable;
    _codeTextField.returnKeyType = UIReturnKeyDone;
    _codeTextField.delegate = self;
    _codeTextField.backgroundColor = [UIColor whiteColor];
    _codeTextField.font = [UIFont boldSystemFontOfSize:17.0];
    _codeTextField.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_codeTextField];
    
    UIImage *sendImage = [UIImage imageNamed:@"button_blue"];
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = CGRectMake((self.view.width - sendImage.size.width) / 2,
                                  CGRectGetMaxY(_codeTextField.frame) + 10,
                                  sendImage.size.width,
                                  sendImage.size.height);
    [sendButton setBackgroundImage:sendImage forState:UIControlStateNormal];
    [sendButton setTitle:@"送信する" forState:UIControlStateNormal];
    sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    [sendButton addTarget:self action:@selector(sendCode) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:sendButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Touch Delegate

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Actions

- (void)sendCode
{
    if (self.codeTextField.text.length != 0) {
        if (![MASTER(MSTKeyInvited) boolValue]) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
            NSDictionary *params = @{@"uuid" : MASTER(MSTKeyUUID), @"code" : self.codeTextField.text};
            [manager POST:@"/user/checkcode" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSError *error = nil;
                BaseResponse *response = [MTLJSONAdapter modelOfClass:BaseResponse.class fromJSONDictionary:responseObject error:&error];
                
                if (response.error == ErrorNone) {
                    Task *task = [[AppManager sharedInstance] taskFromTag:TASK_INVITED];
                    [task setTask_date:[[NSDate date] localStringWithFormat:DB_DATE_YMDHMS]];
                    [TaskUtils handleTaskComplete:task];
                    [AchievementViewController showInController:self taskInfo:task];
                    
                    // Invite flag
                    [Master saveValue:@"1" forKey:MSTKeyInvited];
                    
//                    title = @"紹介コード入力成功！";
//                    message = @"あなたとお友達の残業実績を\n30日多く保存できるように\nなりました！";
                } else if ([responseObject[@"error"] integerValue] == ErrorUUIDNotFound) {
                    // Save uuid flag
                    [Master saveValue:@"" forKey:MSTKeyUserLogined];
                    // Relogin
                    [[AppManager sharedInstance] requestUUID];
                } else {
                    NSString *title = @"紹介コード入力失敗！";
                    NSString *message = @"お友達に再度コードを教えてもらっ\nて、あなたが既に利用していないか\nも確認してみてください。";
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                    message:message
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [AppManager requestDidFailed:error];
            }];
        } else {
            NSString *message = @"ごめんなさい！紹介コードのご利用は１回までです。";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

@end
