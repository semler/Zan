//
//  SettingLegalViewController.m
//  Overtime
//
//  Created by Xu Shawn on 4/4/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "SettingLegalViewController.h"
#import "LegalCell.h"

@interface SettingLegalViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *dataList;

@end

@implementation SettingLegalViewController

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
    [self configHeaderImage:@"setting_header" andBgImage:@"setting_legal_bg"];
    [self configBackButton];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 60.0, SCREEN_WIDTH, (IS_RETINA4 ? 385.0 : 297.0)) style:UITableViewStylePlain];
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView registerNib:[UINib nibWithNibName:LegalCellIdentifier bundle:nil] forCellReuseIdentifier:LegalCellIdentifier];
    if ([tableView respondsToSelector:@selector(setEstimatedRowHeight:)]) {
        [tableView setEstimatedRowHeight:80.0];
    }
    [self.contentView addSubview:tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
