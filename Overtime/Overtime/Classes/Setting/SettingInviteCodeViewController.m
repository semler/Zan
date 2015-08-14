//
//  SettingInviteCodeViewController.m
//  Overtime
//
//  Created by xuxiaoteng on 3/6/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import "SettingInviteCodeViewController.h"
#import "BaseResponse.h"

@interface SettingInviteCodeViewController ()

@property (nonatomic, strong) UITextView *myCodeTextView;

@end

@implementation SettingInviteCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configHeaderImage:@"setting_header" andBgImage:@"bg"];
    [self configBackButton];
    [self configSubTitle:@"紹介コードを友達におくる"];
    UIImage *lineImage = [UIImage imageNamed:@"separator_line"];
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(lineImage, 0, 56.0)];
    [lineImageView setImage:lineImage];
    [self.contentView addSubview:lineImageView];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(26, CGRectGetMaxY(lineImageView.frame) + 10, self.view.width - 52, 55.0)];
    tipLabel.text = @"下のコードをSNSから友達に送って広めてほしいんです。\nそうです。必死なんです。";
    tipLabel.numberOfLines = 3;
    tipLabel.font = [UIFont boldSystemFontOfSize:14.0];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:tipLabel];

    
    UILabel *myCodeTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(tipLabel.frame),
                                                                        CGRectGetMaxY(tipLabel.frame) + 15,
                                                                        CGRectGetWidth(tipLabel.frame),
                                                                        20)];
    myCodeTipLabel.text = @"自分のコードで紹介する";
    myCodeTipLabel.font = tipLabel.font;
    myCodeTipLabel.textAlignment = tipLabel.textAlignment;
    myCodeTipLabel.backgroundColor = [UIColor clearColor];
    myCodeTipLabel.textColor = tipLabel.textColor;
    [self.contentView addSubview:myCodeTipLabel];
    
    _myCodeTextView = [[UITextView alloc] initWithFrame:CGRectMake((self.view.width - 160) / 2, CGRectGetMaxY(tipLabel.frame) + 15, 160, 40)];
    _myCodeTextView.font = [UIFont boldSystemFontOfSize:17.0];
    _myCodeTextView.editable = NO;
    _myCodeTextView.backgroundColor = [UIColor whiteColor];
    _myCodeTextView.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_myCodeTextView];
    
    CGFloat iconSize = 70.0;
    
    UIButton *fbButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [fbButton setImage:[UIImage imageNamed:@"facebook_icon"] forState:UIControlStateNormal];
    [fbButton setFrame:CGRectMake(45.0, _myCodeTextView.bottom + 20.0, iconSize, iconSize)];
    [fbButton addTarget:self action:@selector(fbButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:fbButton];
    
    UIButton *twButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [twButton setImage:[UIImage imageNamed:@"twitter_icon"] forState:UIControlStateNormal];
    [twButton setFrame:CGRectMake(fbButton.right + 10.0, _myCodeTextView.bottom + 20.0, iconSize, iconSize)];
    [twButton addTarget:self action:@selector(twButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:twButton];
    
    UIButton *lineButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [lineButton setImage:[UIImage imageNamed:@"line_icon"] forState:UIControlStateNormal];
    [lineButton setFrame:CGRectMake(twButton.right + 10.0, _myCodeTextView.bottom + 20.0, iconSize, iconSize)];
    [lineButton addTarget:self action:@selector(lineButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:lineButton];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
    NSDictionary *params = @{@"uuid" : MASTER(MSTKeyUUID)};
    [manager POST:@"/user/code" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        BaseResponse *response = [MTLJSONAdapter modelOfClass:BaseResponse.class fromJSONDictionary:responseObject error:&error];
        if (response.error == ErrorNone) {
            NSString *code = responseObject[@"code"];
            self.myCodeTextView.text = code;
        } else if (response.error == ErrorUUIDNotFound) {
            // Save uuid flag
            [Master saveValue:@"" forKey:MSTKeyUserLogined];
            // Relogin
            [[AppManager sharedInstance] requestUUID];
        }
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [AppManager requestDidFailed:error];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Event

- (void)fbButtonDidClicked:(UIButton *)button
{
    NSString *shareText = [NSString stringWithFormat:INVITE_TEXT, self.myCodeTextView.text, @"http://goo.gl/mA7JPP"];
    [ShareUtils shareTextToFacebook:shareText];
}

- (void)twButtonDidClicked:(UIButton *)button
{
    NSString *shareText = [NSString stringWithFormat:INVITE_TEXT, self.myCodeTextView.text, @"http://goo.gl/UsY7Ad"];
    [ShareUtils shareTextToTwitter:shareText];
}

- (void)lineButtonDidClicked:(UIButton *)button
{
    NSString *shareText = [NSString stringWithFormat:INVITE_TEXT, self.myCodeTextView.text, @"http://goo.gl/2HVoMo"];
    [ShareUtils shareTextToLine:shareText];
}

@end
