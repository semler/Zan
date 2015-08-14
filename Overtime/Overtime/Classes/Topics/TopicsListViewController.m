//
//  TopicsListViewController.m
//  Overtime
//
//  Created by 于　超 on 2015/07/28.
//  Copyright (c) 2015年 Bravesoft. All rights reserved.
//

#import "TopicsListViewController.h"
#import "TopicsListCell.h"
#import "TopicsListData.h"
#import "BaseResponse.h"
#import "TopicsDetailViewController.h"

#define PAGE_COUNT 25.0

@interface TopicsListViewController () <UITableViewDelegate, UITableViewDataSource> {
    UITableView *topicsTableView;
    NSMutableArray *topicsList;
    UILabel *pageLabel;
    UIButton *leftButton;
    UIButton *rightButton;
    int pageNo;
    int totalPage;
    int totalCount;
}

@end

@implementation TopicsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configHeaderImage:@"topics_header" andBgImage:@"bg"];
    [self configBackButton];
    
    topicsTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 89, 300, 400)];
    topicsTableView.backgroundColor = [UIColor clearColor];
    if (IOS8_OR_LATER) {
        topicsTableView.layoutMargins = UIEdgeInsetsZero;
        topicsTableView.separatorInset = UIEdgeInsetsZero;
    } else {
        topicsTableView.separatorInset = UIEdgeInsetsZero;
    }
    topicsTableView.separatorColor = [UIColor colorWithRed:19/255.0 green:1/255.0 blue:4/255.0 alpha:1.0];
    topicsTableView.dataSource = self;
    topicsTableView.delegate = self;
    [self.view addSubview:topicsTableView];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(10, 489, 300, 55)];
    UIImageView *footerBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 55)];
    footerBg.image = [UIImage imageNamed:@"footer_bg"];
    [footerView addSubview:footerBg];
    
    leftButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 35, 35)];
    [leftButton setImage:[UIImage imageNamed:@"leftBtn"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(leftButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    leftButton.enabled = NO;
    rightButton = [[UIButton alloc] initWithFrame:CGRectMake(255, 10, 35, 35)];
    [rightButton setImage:[UIImage imageNamed:@"rightBtn"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    leftButton.enabled = NO;
    [footerView addSubview:leftButton];
    [footerView addSubview:rightButton];
    
    UIImageView *pageView = [[UIImageView alloc] initWithFrame:CGRectMake(96, 12, 108, 31)];
    pageView.image = [UIImage imageNamed:@"page_bg"];
    [footerView addSubview:pageView];
    
    pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 12, 80, 31)];
    [pageLabel setBackgroundColor:[UIColor clearColor]];
    [pageLabel setTextColor:FONT_BLUE1];
    [pageLabel setFont:[UIFont systemFontOfSize:12.0]];
    [pageLabel setNumberOfLines:0];
    [pageLabel setTextAlignment:NSTextAlignmentCenter];
    [footerView addSubview:pageView];
    [footerView addSubview:pageLabel];
    [self.view addSubview:footerView];
    
    pageNo = 1;
    topicsList = [NSMutableArray array];
    
    [self performSelector:@selector(loadTopics) withObject:nil afterDelay:0.0];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView: (UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return topicsList.count;
}

// セル高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cell";
    
    TopicsListData *data = [topicsList objectAtIndex:[indexPath row]];
    TopicsListCell *cell= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[TopicsListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.data = data;
    cell.index = (int)indexPath.row;
//    cell.totalCount = totalCount;
    cell.backgroundColor = [UIColor clearColor];
    [cell initFrame];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
    TopicsListData *data = [topicsList objectAtIndex:[indexPath row]];
    TopicsDetailViewController *controller = [[TopicsDetailViewController alloc] init];
    controller.newsId = data.news_id;
    NSDictionary *parameters = [[GAIDictionaryBuilder createEventWithCategory:@"ニュースタップ" action:data.news_id label:nil value:nil] build];
    [[[GAI sharedInstance] defaultTracker] send:parameters];
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)loadTopics {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
    NSDictionary* params = @{@"page_num" : [NSString stringWithFormat:@"%d", pageNo-1], @"page_count" : [NSString stringWithFormat:@"%d", (int)PAGE_COUNT], @"uuid" : OTUUID};
    [manager POST:@"/news/list" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        BaseResponse *response = [MTLJSONAdapter modelOfClass:BaseResponse.class fromJSONDictionary:responseObject error:&error];
        totalCount = [responseObject[@"total_count"] intValue];
        if (!error && response.error == ErrorNone) {
            [topicsList removeAllObjects];
            for (NSDictionary * dict in responseObject[@"news"]) {
                [topicsList addObject:[[TopicsListData alloc] initWithDict:dict]];
            }
        } else if (response.error == ErrorUUIDNotFound) {
            [[AppManager sharedInstance] requestUUID];
        }
        
        [self reloadPage];
        [topicsTableView reloadData];
        [topicsTableView setContentOffset:CGPointZero];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppManager requestDidFailed:error];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}

-(void)leftButtonPressed {
    if (pageNo > 1) {
        pageNo --;
        [self loadTopics];
    }
    
    [self reloadPage];
}

-(void)rightButtonPressed {
    if (pageNo < totalPage) {
        pageNo ++;
        [self loadTopics];
    }
    
    [self reloadPage];
}

-(void)reloadPage {
    totalPage = ceil(totalCount/PAGE_COUNT);
    NSString *page = [NSString stringWithFormat:@"%d/%d PAGE", pageNo, totalPage];
    pageLabel.text = page;
    if (pageNo == 1) {
        leftButton.enabled = NO;
    } else {
        leftButton.enabled = YES;
    }
    if (pageNo == totalPage) {
        rightButton.enabled = NO;
    } else {
        rightButton.enabled = YES;
    }
}

@end
