//
//  TopicsDetailViewController.m
//  Overtime
//
//  Created by 于　超 on 2015/07/29.
//  Copyright (c) 2015年 Bravesoft. All rights reserved.
//

#import "TopicsDetailViewController.h"
#import "BaseResponse.h"
#import "TopicsDetailData.h"
#import "UIImageView+WebCache.h"
#import "WebViewController.h"
#import "CustomTextView.h"

@interface TopicsDetailViewController () {
    UIImageView *imageview;
    UILabel *title;
    UIImageView *clock;
    UILabel *time;
    UIImageView *pen;
    UILabel *category;
    UIImageView *bg;
    UIImageView *header;
    CustomTextView *textView;
    UIButton *checkButton;
    TopicsDetailData *data;
}
@end

@implementation TopicsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configHeaderImage:@"topics_header" andBgImage:@"bg"];
    [self configBackButton];

    imageview = [[UIImageView alloc] initWithFrame:CGRectMake(10, 85, 300, 180)];
    imageview.contentMode = UIViewContentModeScaleAspectFill;
    imageview.clipsToBounds = YES;
    // 角丸
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:imageview.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(10.0, 10.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = imageview.bounds;
    maskLayer.path = maskPath.CGPath;
    imageview.layer.mask = maskLayer;
    [self.view addSubview:imageview];
    title = [[UILabel alloc] initWithFrame:CGRectMake(20, 190, 280, 60)];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setTextColor:[UIColor whiteColor]];
    [title setFont:[UIFont boldSystemFontOfSize:16.0]];
    [title setNumberOfLines:2];
    [self.view addSubview:title];
    clock = [[UIImageView alloc] initWithFrame:CGRectMake(20, 245, 12, 12)];
    clock.image = [UIImage imageNamed:@"clock"];
    [self.view addSubview:clock];
    time = [[UILabel alloc] initWithFrame:CGRectMake(35, 245, 100, 12)];
    [time setBackgroundColor:[UIColor clearColor]];
    [time setTextColor:[UIColor whiteColor]];
    [time setFont:[UIFont systemFontOfSize:10.0]];
    [time setNumberOfLines:1];
    [self.view addSubview:time];
    pen = [[UIImageView alloc] initWithFrame:CGRectMake(135, 245, 12, 12)];
    pen.image = [UIImage imageNamed:@"penIcon"];
    [self.view addSubview:pen];
    category = [[UILabel alloc] initWithFrame:CGRectMake(150, 245, 100, 12)];
    [category setBackgroundColor:[UIColor clearColor]];
    [category setTextColor:[UIColor whiteColor]];
    [category setFont:[UIFont systemFontOfSize:10.0]];
    [category setNumberOfLines:1];
    [self.view addSubview:category];
    
    bg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 265, 300, 270)];
    bg.image = [UIImage imageNamed:@"cellBg"];
    // 角丸
    UIBezierPath *maskPath2 = [UIBezierPath bezierPathWithRoundedRect:bg.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(10.0, 10.0)];
    CAShapeLayer *maskLayer2 = [[CAShapeLayer alloc] init];
    maskLayer2.frame = bg.bounds;
    maskLayer2.path = maskPath2.CGPath;
    bg.layer.mask = maskLayer2;
    [self.view addSubview:bg];
    
    header = [[UIImageView alloc] initWithFrame:CGRectMake(20, 275, 125, 25)];
    header.image = [UIImage imageNamed:@"zakkuri"];
    [self.view addSubview:header];
    
    textView = [[CustomTextView alloc] initWithFrame:CGRectMake(20, 310, 280, 145)];
    textView.editable = NO;
    textView.backgroundColor = [UIColor clearColor];
    [textView setTextColor:[UIColor whiteColor]];
    [textView setFont:[UIFont systemFontOfSize:16.0]];
    [self.view addSubview:textView];
    
    checkButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 465, 280, 60)];
    [checkButton setImage:[UIImage imageNamed:@"newsBtn"] forState:UIControlStateNormal];
    [checkButton addTarget:self action:@selector(check) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:checkButton];
    
    [self performSelector:@selector(loadDetail) withObject:nil afterDelay:0.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadDetail {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
    NSDictionary* params = @{@"uuid" : OTUUID, @"news_id" : _newsId};
    [manager POST:@"/news/info" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        BaseResponse *response = [MTLJSONAdapter modelOfClass:BaseResponse.class fromJSONDictionary:responseObject error:&error];
        if (!error && response.error == ErrorNone) {
            NSDictionary *news = responseObject[@"news"];
            data = [[TopicsDetailData alloc] initWithDict:news];
        } else if (response.error == ErrorUUIDNotFound) {
            [[AppManager sharedInstance] requestUUID];
        }
        
        [self setData];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppManager requestDidFailed:error];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}

-(void)setData {
    [imageview sd_setImageWithURL:[NSURL URLWithString:data.image] placeholderImage:nil options:SDWebImageDelayPlaceholder];
    title.text = data.title;
    NSString *date = [data.pub_date stringByReplacingOccurrencesOfString:@"-" withString:@"."];
    time.text = date;
    category.text = data.category;
    textView.text = data.content;
}

-(void)check {
    if (data.link != nil) {
        WebViewController *webViewController = [[WebViewController alloc] initWithTitle:@"残業トピックス" URLString:data.link webVCType:WebVCTypeDefault];
        NSDictionary *parameters = [[GAIDictionaryBuilder createEventWithCategory:@"詳細タップ" action:_newsId label:nil value:nil] build];
        [[[GAI sharedInstance] defaultTracker] send:parameters];
        [self.navigationController pushViewController:webViewController animated:YES];
    }
}

@end
