//
//  LegalViewController.m
//  Overtime
//
//  Created by Xu Shawn on 3/5/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "LegalViewController.h"
#import "MainViewController.h"
#import "LegalCell.h"

@interface LegalViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *dataList;

@end

@implementation LegalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.dataList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Legal" ofType:@"plist"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self configImage:@"legal_bg"];
    [self configBackButton];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 93.0, SCREEN_WIDTH, (IS_RETINA4 ? 354.0 : 267.0)) style:UITableViewStylePlain];
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView registerNib:[UINib nibWithNibName:LegalCellIdentifier bundle:nil] forCellReuseIdentifier:LegalCellIdentifier];
    if ([tableView respondsToSelector:@selector(setEstimatedRowHeight:)]) {
        [tableView setEstimatedRowHeight:80.0];
    }
    [self.view addSubview:tableView];
    
    UIImage *nextImage = [UIImage imageNamed:@"legal_button"];
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setFrame:CGRectOffsetFromImage(nextImage, (SCREEN_WIDTH - nextImage.size.width) / 2, SCREEN_HEIGHT - 93.0)];
    [nextButton setImage:nextImage forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)nextButtonDidClicked:(UIButton *)button
{    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud setRemoveFromSuperViewOnHide:YES];
    [hud showAnimated:YES whileExecutingBlock:^{
        // Cancel last
        [AppManager cancelLastConfirmNotification];
        // Last confirm
        [AppManager addLastConfirmNotification];
        // Rest time1
        [Master saveValue:@"12:00" forKey:MSTKeyRestStart1];
        [Master saveValue:@"13:00" forKey:MSTKeyRestEnd1];
        
        // Config geo fence
        if ([GFUtils configGeoFence:[[AppManager sharedInstance] areaArray]]) {
            [self performSelectorOnMainThread:@selector(forwardToMainView) withObject:nil waitUntilDone:NO];
        }
    }];
}

- (void)forwardToMainView
{
    // Log tracker
    NSDictionary *parameters = [[GAIDictionaryBuilder createEventWithCategory:@"チュートリアル"
                                                                       action:@"完了"
                                                                        label:nil
                                                                        value:nil] build];
    [[[GAI sharedInstance] defaultTracker] send:parameters];
    // Main page
    MainViewController *mainViewController = [[MainViewController alloc] init];
    [self.navigationController pushViewController:mainViewController animated:YES];
}

#pragma mark - UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IOS8_OR_LATER) {
        return UITableViewAutomaticDimension;
    } else {
        NSDictionary *info = self.dataList[indexPath.row];
        NSString *title = info[@"Title"];
        NSString *detail = info[@"Detail"];
        
        CGFloat titleHeight = [title heightWithWidth:280.0 andFont:[UIFont boldSystemFontOfSize:14.0]];
        CGFloat detailHeight = [detail heightWithWidth:280.0 andFont:[UIFont systemFontOfSize:13.0]];
        return titleHeight + detailHeight + 35.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LegalCell *legalCell = [tableView dequeueReusableCellWithIdentifier:LegalCellIdentifier];
    
    NSDictionary *info = self.dataList[indexPath.row];
    [legalCell.titleLabel setText:info[@"Title"]];
    [legalCell.detailLabel setText:info[@"Detail"]];
    
    if (indexPath.row == self.dataList.count - 1) {
        [legalCell.lineImageView setHidden:YES];
    }
    
    return legalCell;
}

@end
