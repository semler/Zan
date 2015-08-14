//
//  BaseViewController.m
//  ExileTribeMile
//
//  Created by Xu Shawn on 11/18/13.
//  Copyright (c) 2013 Bravesoft. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        // To do temp title
        NSString *className = [[self class] description];
        NSString *title = [className substringToIndex:[className rangeOfString:@"ViewController"].location];
        [self setTitle:title];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setWantsFullScreenLayout:YES];
    
    [self.view setBackgroundColor:[UIColor blackColor]];

    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
//    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
//        [self setAutomaticallyAdjustsScrollViewInsets:NO];
//    }
//    // Background image
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"header_back"] forBarMetrics:UIBarMetricsDefault];
}

- (void)buttonDidClicked:(UIButton *)button
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)configSilerHeader
{
    UIImage *silverHeadImage = [UIImage imageNamed:@"silver_head"];
    UIImageView *silverHeadImageView = [[UIImageView alloc] initWithFrame:CGRectFromImage(silverHeadImage)];
    [silverHeadImageView setImage:silverHeadImage];
    [self.view addSubview:silverHeadImageView];
}

- (void)configBackButton
{
    UIImage *backImage = [UIImage imageNamed:@"back"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectOffsetFromImage(backImage, 5.0, 38.0)];
    [backButton setImage:backImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(baseBackButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}

- (void)configDismissButton
{
    UIImage *backImage = [UIImage imageNamed:@"back"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectOffsetFromImage(backImage, 5.0, 38.0)];
    [backButton setImage:backImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(baseDismissButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}

- (void)configCancelButton
{
    UIImage *backImage = [UIImage imageNamed:@"cancel"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectOffsetFromImage(backImage, 5.0, 38.0)];
    [backButton setImage:backImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(baseDismissButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}

- (void)configCloseButton
{
    UIImage *backImage = [UIImage imageNamed:@"btn_close"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectOffsetFromImage(backImage, 5.0, 38.0)];
    [backButton setImage:backImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(baseDismissButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}

- (void)baseBackButtonDidClicked:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)baseDismissButtonDidClicked:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)configHeaderImage:(NSString *)headerName
{
    UIImage *headerImage = [UIImage imageNamed:headerName];
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectFromImage(headerImage)];
    [headerImageView setImage:headerImage];
    [self.view addSubview:headerImageView];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, headerImageView.bottom, SCREEN_WIDTH, SCREEN_HEIGHT - headerImageView.bottom)];
    [self.view addSubview:self.contentView];
}

- (void)configHeaderImage:(NSString *)headerName andBgImage:(NSString *)bgName
{
    UIImage *headerImage = [UIImage imageNamed:headerName];
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectFromImage(headerImage)];
    [headerImageView setImage:headerImage];
    [self.view addSubview:headerImageView];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, headerImageView.bottom, SCREEN_WIDTH, SCREEN_HEIGHT - headerImageView.bottom)];
    [self.view addSubview:self.contentView];

    UIImage *bgImage = [UIImage imageNamed:bgName];
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectFromImage(bgImage)];
    [bgImageView setImage:bgImage];
    [self.contentView addSubview:bgImageView];
}

- (void)configHeaderTitle:(NSString *)title
{
    [self configHeaderTitle:title separatorLine:YES];
}

- (void)configHeaderTitle:(NSString *)title separatorLine:(BOOL)separatorLine
{
    UIImage *headerImage = [UIImage imageNamed:@"header_bg"];
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(headerImage, 0, 26.0)];
    [headerImageView setImage:headerImage];
    [self.view addSubview:headerImageView];
    
    [self configSilerHeader];
    
    CGFloat offsetY = headerImageView.bottom;
    
    if (separatorLine) {
        UIImage *lineImage = [UIImage imageNamed:@"separator_line"];
        UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, headerImageView.bottom, lineImage.size.width, lineImage.size.height)];
        [lineImageView setImage:lineImage];
        [self.view addSubview:lineImageView];
        
        offsetY = lineImageView.bottom;
    }
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, SCREEN_WIDTH, SCREEN_HEIGHT - offsetY)];
    [self.view addSubview:self.contentView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 4.0, headerImageView.width, headerImageView.height - 4.0)];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont boldSystemFontOfSize:20.0]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:title];
    [label setTextAlignment:NSTextAlignmentCenter];
    [headerImageView addSubview:label];
}

- (void)configSubTitle:(NSString *)subTitle
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 58.0)];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont boldSystemFontOfSize:18.0]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:subTitle];
    [label setTextAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:label];
}

- (void)configImage:(NSString *)imageName
{
    [self configImage:imageName offsetX:0 offsetY:0];
}

- (void)configImage:(NSString *)imageName offsetX:(CGFloat)x offsetY:(CGFloat)y
{
    UIImage *bgImage = [UIImage imageNamed:imageName];
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, bgImage.size.width, bgImage.size.height)];
    [bgImageView setImage:bgImage];
    [self.view addSubview:bgImageView];
}

@end
