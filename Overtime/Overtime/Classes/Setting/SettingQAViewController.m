//
//  SettingQAViewController.m
//  Overtime
//
//  Created by Xu Shawn on 4/4/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "SettingQAViewController.h"
#import "SettingQACell.h"

@interface SettingQAViewController () <UITableViewDataSource, UITableViewDelegate, SettingQACellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) NSInteger selectedRow;

@end

@implementation SettingQAViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"QA" ofType:@"plist"]];
        _dataArray = [NSArray arrayWithContentsOfURL:fileURL];
        
        _selectedRow = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configHeaderImage:@"setting_header" andBgImage:@"setting_qa_bg"];
    [self configBackButton];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 58.0, self.contentView.width, IS_RETINA4 ? 387.0 : 307.0) style:UITableViewStylePlain];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView registerClass:[SettingQACell class] forCellReuseIdentifier:CCIdentifier];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setShowsHorizontalScrollIndicator:NO];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [self.contentView addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    NSDictionary *dic = self.dataArray[indexPath.row];
    NSString *titleText = dic[@"Title"];
    CGSize titleSize = [titleText sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(270.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    
    height = titleSize.height + 20.0;
    
    if (height < 51.0) {
        height = 51.0;
    }
    
    if (indexPath.row == self.selectedRow) {
        NSString *detailText = dic[@"Detail"];
        CGSize detailSize = [detailText sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(290.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        height += detailSize.height + 20.0;
    } else {
        height += 2.0;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingQACell *cell = [tableView dequeueReusableCellWithIdentifier:CCIdentifier];
    [cell setDelegate:self];
    if (self.selectedRow == indexPath.row) {
        [cell.imageView setImage:[UIImage imageNamed:@"setting_qa_cell_bg2"]];
        [cell.detailButton setImage:[UIImage imageNamed:@"setting_qa_minus"] forState:UIControlStateNormal];
        [cell.detailImageView setHidden:NO];
        [cell.detailTextLabel setHidden:NO];
    } else {
        [cell.imageView setImage:[UIImage imageNamed:@"setting_qa_cell_bg1"]];
        [cell.detailButton setImage:[UIImage imageNamed:@"setting_qa_plus"] forState:UIControlStateNormal];
        [cell.detailImageView setHidden:YES];
        [cell.detailTextLabel setHidden:YES];
    }
    
    NSDictionary *dic = self.dataArray[indexPath.row];
    [cell.textLabel setText:dic[@"Title"]];
    [cell.detailTextLabel setText:dic[@"Detail"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [tableView beginUpdates];
    
    if (self.selectedRow == indexPath.row) {
        [self setSelectedRow:-1];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:self.selectedRow inSection:0];
        [self setSelectedRow:indexPath.row];
        [tableView reloadRowsAtIndexPaths:@[lastIndexPath, indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [tableView endUpdates];

    if (self.dataArray.count == indexPath.row + 1) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

@end
