//
//  SettingPushViewController.m
//  Overtime
//
//  Created by Xu Shawn on 4/4/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "SettingPushViewController.h"
#import "SettingChangeCell.h"
#import "HolidayViewController.h"
#import "CustomPicker.h"

@interface SettingPushViewController () <UITableViewDataSource, UITableViewDelegate, SettingChangeCellDelegate, CustomPickerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *titleArray;
@property (nonatomic, copy) NSString *pickerMSTKey;

@end

@implementation SettingPushViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _titleArray = [NSMutableArray array];
        [_titleArray addObject:@[@"出勤打刻時", @"退勤打刻時", @"残業開始時", @"残業終了時"]];
        [_titleArray addObject:@[@"残業代が貯まった時", @"通知する金額"]];
        [_titleArray addObject:@[@"前日の打刻確認", @"通知する時刻", @"通知する曜日"]];
        
        [[[DBUtils sharedDBUtils] dbo] beginTransaction];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configHeaderImage:@"setting_header" andBgImage:@"bg"];
    [self configBackButton];
    [self configSubTitle:@"プッシュ通知設定"];
    
    UIImage *lineImage = [UIImage imageNamed:@"separator_line"];
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(lineImage, 0, 56.0)];
    [lineImageView setImage:lineImage];
    [self.contentView addSubview:lineImageView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, lineImageView.bottom, self.contentView.width, self.contentView.height - lineImageView.bottom - 10.0) style:UITableViewStyleGrouped];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView registerClass:[SettingChangeCell class] forCellReuseIdentifier:CCIdentifier];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setBackgroundView:nil];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setRowHeight:51.0];
    [self.tableView setShowsHorizontalScrollIndicator:NO];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [self.tableView setSectionHeaderHeight:0];
    [self.tableView setSectionFooterHeight:0];
    [self.contentView addSubview:self.tableView];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 8.0)];
    [self.tableView setTableHeaderView:headerView];
    
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 105.0)];
    
    UIImage *saveImage = [UIImage imageNamed:@"save_change"];
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setFrame:CGRectOffsetFromImage(saveImage, (tableFooterView.width - saveImage.size.width) / 2.0, (tableFooterView.height - saveImage.size.height) / 2.0)];
    [saveButton setImage:saveImage forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [tableFooterView addSubview:saveButton];
    
    [self.tableView setTableFooterView:tableFooterView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)baseBackButtonDidClicked:(UIButton *)button
{
    [[[DBUtils sharedDBUtils] dbo] rollback];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveButtonDidClicked:(UIButton *)button
{
    [[[DBUtils sharedDBUtils] dbo] commit];
    
    [AppManager cancelLastConfirmNotification];
    
    if ([MASTER(MSTKeyLastConfirm) integerValue] == 1) {
        [AppManager addLastConfirmNotification];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.titleArray[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return 36.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = nil;
    
    if (section != 0) {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 36.0)];
        
        UIImage *lineImage = [UIImage imageNamed:@"separator_line"];
        UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(lineImage, 0, (headerView.height - lineImage.size.height) / 2.0)];
        [lineImageView setImage:lineImage];
        [headerView addSubview:lineImageView];
    }
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingChangeCell *cell = [tableView dequeueReusableCellWithIdentifier:CCIdentifier];
    [cell setDelegate:self];
    
    NSInteger rows = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    
    if (indexPath.row == 0) {
        if (indexPath.section == 3) {
            [cell.imageView setImage:[UIImage imageNamed:@"cell_bg"]];
        } else {
            [cell.imageView setImage:[UIImage imageNamed:@"cell_bg_top"]];
        }
    } else {
        if (indexPath.row != rows - 1) {
            [cell.imageView setImage:[UIImage imageNamed:@"cell_bg_center"]];
        } else {
            [cell.imageView setImage:[UIImage imageNamed:@"cell_bg_bottom"]];
        }
    }
    NSArray *titleArray = self.titleArray[indexPath.section];
    [cell.textLabel setText:titleArray[indexPath.row]];

    // Master data
    NSDictionary *masterDic = [[AppManager sharedInstance] masterDic];
    
    switch (indexPath.section) {
        case 0: {
            [cell.switchButton setHidden:NO];
            
            switch (indexPath.row) {
                case 0: {
                    NSString *switchFlag = masterDic[MSTKeyWorkOn];
                    [cell setSwitchOn:[switchFlag boolValue]];
                    break;
                }
                case 1: {
                    NSString *switchFlag = masterDic[MSTKeyWorkOff];
                    [cell setSwitchOn:[switchFlag boolValue]];
                    break;
                }
                case 2: {
                    NSString *switchFlag = masterDic[MSTKeyOvertimeOn];
                    [cell setSwitchOn:[switchFlag boolValue]];
                    break;
                }
                case 3: {
                    NSString *switchFlag = masterDic[MSTKeyOvertimeOff];
                    [cell setSwitchOn:[switchFlag boolValue]];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 1: {
            switch (indexPath.row) {
                case 0: {
                    [cell.switchButton setHidden:NO];
                    NSString *switchFlag = masterDic[MSTKeyChargeReach];
                    [cell setSwitchOn:[switchFlag boolValue]];
                    break;
                }
                case 1: {
                    [cell.switchButton setHidden:YES];
                    NSString *chargeAmount = masterDic[MSTKeyChargeAmount];
                    if (chargeAmount.length > 0) {
                        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@万円ごと", chargeAmount]];
                    } else {
                        [cell.detailTextLabel setText:@"0万円ごと"];
                    }
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 2: {
            switch (indexPath.row) {
                case 0: {
                    [cell.switchButton setHidden:NO];
                    NSString *switchFlag = masterDic[MSTKeyLastConfirm];
                    [cell setSwitchOn:[switchFlag boolValue]];
                    break;
                }
                case 1: {
                    [cell.switchButton setHidden:YES];
                    NSString *confirmTime = masterDic[MSTKeyConfirmTime];
                    if (confirmTime.length > 0) {
                        [cell.detailTextLabel setText:confirmTime];
                    } else {
                        [cell.detailTextLabel setText:@"--:--"];
                    }
                    break;
                }
                case 2: {
                    [cell.switchButton setHidden:YES];
                    [cell.detailTextLabel setText:[Master weekFromIndex:masterDic[MSTKeyConfirmWeek]]];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0: {
            break;
        }
        case 1: {
            switch (indexPath.row) {
                case 0: {
                    break;
                }
                case 1: {
                    CustomPicker *picker = [CustomPicker sharedInstance];
                    [picker setDelegate:self];
                    [picker setShowResetButton:NO];
                    [picker setPickerType:CustomPickerTypeDefault];
                    
                    NSMutableArray *dataSource = [NSMutableArray array];
                    for (NSInteger i = 1; i <= 50; i++) {
                        [dataSource addObject:[NSString stringWithFormat:@"%d万円ごと", (int)i]];
                    }
                    [picker setDataSource:dataSource];
                    
                    NSString *value = MASTER(MSTKeyChargeAmount);
                    if (value.length > 0) {
                        [picker setSelectedValues:@[[NSString stringWithFormat:@"%@万円ごと", value]]];
                    }
                    
                    [[CustomPicker sharedInstance] showInView:self.view];
                    
                    [self setPickerMSTKey:MSTKeyChargeAmount];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 2: {
            switch (indexPath.row) {
                case 0: {
                    break;
                }
                case 1: {
                    CustomPicker *picker = [CustomPicker sharedInstance];
                    [picker setDelegate:self];
                    [picker setPickerType:CustomPickerTypeTime];
                    [picker setShowResetButton:NO];
                    NSString *value = MASTER(MSTKeyConfirmTime);
                    if (value.length > 0) {
                        [picker setSelectedValues:@[value]];
                    }
                    [[CustomPicker sharedInstance] showInView:self.view];
                    
                    [self setPickerMSTKey:MSTKeyConfirmTime];
                    break;
                }
                case 2: {
                    HolidayViewController *holidayViewController = [[HolidayViewController alloc] initWithSettingType:SettingTypeReEdit holidayType:HolidayTypeNotice];
                    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:holidayViewController];
                    [navigationController setNavigationBarHidden:YES];
                    [self presentViewController:navigationController animated:YES completion:NULL];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (void)settingChangeCell:(SettingChangeCell *)cell switchDidClicked:(BOOL)switchOn
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSArray *titleArray = self.titleArray[indexPath.section];
    
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    [Master saveValue:[cell switchOnString] forKey:MSTKeyWorkOn];
                    break;
                }
                case 1: {
                    [Master saveValue:[cell switchOnString] forKey:MSTKeyWorkOff];
                    break;
                }
                case 2: {
                    [Master saveValue:[cell switchOnString] forKey:MSTKeyOvertimeOn];
                    break;
                }
                case 3: {
                    [Master saveValue:[cell switchOnString] forKey:MSTKeyOvertimeOff];
                    break;
                }
                default:
                    break;
            }
            
            // Log tracker
            NSString *message = [NSString stringWithFormat:@"PUSH_%@", titleArray[indexPath.row]];
            NSDictionary *parameters = [[GAIDictionaryBuilder createEventWithCategory:OTUUID
                                                                               action:message
                                                                                label:[cell switchOnGAString]
                                                                                value:nil] build];
            [[[GAI sharedInstance] defaultTracker] send:parameters];
            
            break;
        }
        case 1: {
            switch (indexPath.row) {
                case 0: {
                    [Master saveValue:[cell switchOnString] forKey:MSTKeyChargeReach];
                    
                    // Log tracker
                    NSString *message = [NSString stringWithFormat:@"PUSH_%@", titleArray[indexPath.row]];
                    NSDictionary *parameters = [[GAIDictionaryBuilder createEventWithCategory:OTUUID
                                                                                       action:message
                                                                                        label:[cell switchOnGAString]
                                                                                        value:nil] build];
                    [[[GAI sharedInstance] defaultTracker] send:parameters];
                    break;
                }
                case 1: {
                    
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 2: {
            switch (indexPath.row) {
                case 0: {
                    [Master saveValue:[cell switchOnString] forKey:MSTKeyLastConfirm];
                    
                    // Log tracker
                    NSString *message = [NSString stringWithFormat:@"PUSH_%@", titleArray[indexPath.row]];
                    NSDictionary *parameters = [[GAIDictionaryBuilder createEventWithCategory:OTUUID
                                                                                       action:message
                                                                                        label:[cell switchOnGAString]
                                                                                        value:nil] build];
                    [[[GAI sharedInstance] defaultTracker] send:parameters];
                    break;
                }
                case 1: {
                    
                    break;
                }
                case 2: {
                    
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - CustomPickerDelegate

- (void)customPicker:(CustomPicker *)picker didSelectDone:(id)value
{
    if ([self.pickerMSTKey isEqualToString:MSTKeyChargeAmount]) {
        NSString *amount = [value substringToIndex:([value length] - 4)];
        [Master saveValue:amount forKey:MSTKeyChargeAmount];
        [Master saveValue:amount forKey:MSTKeyNextChargeAmount];
        
//        NSInteger alertMoney = [amount integerValue];
//        NSInteger nextAlertMoney = [MASTER(MSTKeyNextChargeAmount) integerValue];
//        
//        if (alertMoney > nextAlertMoney) {
//            [Master saveValue:amount forKey:MSTKeyNextChargeAmount];
//        }
    } else {
        [Master saveValue:value forKey:self.pickerMSTKey];
    }
    
    [self.tableView reloadData];
}

@end
