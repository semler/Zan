//
//  SettingChangeViewController.m
//  Overtime
//
//  Created by Xu Shawn on 4/4/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "SettingChangeViewController.h"
#import "SettingChangeCell.h"
#import "LocationViewController.h"
#import "RestViewController.h"
#import "HolidayViewController.h"
#import "SettingHolidayViewController.h"
#import "PaymentViewController.h"

@interface SettingChangeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *titleArray;

@end

@implementation SettingChangeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _titleArray = [NSMutableArray array];
        [_titleArray addObject:@[@"勤務地"]];
        [_titleArray addObject:@[@"休憩時間1", @"休憩時間2"]];
        [_titleArray addObject:@[@"休日", @"法定内/法定外休日設定"]];
        [_titleArray addObject:@[@"時給"]];

        [[AppManager sharedInstance]  setSettingNeedReload:NO];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configHeaderImage:@"setting_header" andBgImage:@"bg"];
    [self configBackButton];
    [self configSubTitle:@"設定内容変更"];
    [self setModalPresentationStyle:UIModalPresentationPageSheet];
    
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
    [self.tableView setSectionFooterHeight:0];
    [self.contentView addSubview:self.tableView];
    
    [self.contentView bringSubviewToFront:lineImageView];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 8.0)];
    [self.tableView setTableHeaderView:headerView];
    
//    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 105.0)];
//    
//    UIImage *saveImage = [UIImage imageNamed:@"save_change"];
//    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [saveButton setFrame:CGRectOffsetFromImage(saveImage, (tableFooterView.width - saveImage.size.width) / 2.0, (tableFooterView.height - saveImage.size.height) / 2.0)];
//    [saveButton setImage:saveImage forState:UIControlStateNormal];
//    [saveButton addTarget:self action:@selector(saveButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [tableFooterView addSubview:saveButton];
//    
//    [self.tableView setTableFooterView:tableFooterView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableArray *locationArray = [NSMutableArray array];
    for (NSInteger i = 0; i < [[AppManager sharedInstance] areaArray].count; i++) {
        [locationArray addObject:@"勤務地"];
    }
    [self.titleArray replaceObjectAtIndex:0 withObject:locationArray];
    
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
    // Database area
    NSMutableArray *areaArray = [[AppManager sharedInstance] areaArray];
    [areaArray removeAllObjects];
    [areaArray addObjectsFromArray:[Area allArea]];
    
    if ([[AppManager sharedInstance] settingNeedReload]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SettingDidupdateNotification object:nil];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addLocationButtonDidClicked:(UIButton *)button
{
    if ([[[AppManager sharedInstance] areaArray] count] < 2) {
        Area *area = [Area area];
        LocationViewController *locationViewController = [[LocationViewController alloc] initWithSettingType:SettingTypeAdd areaModal:area];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:locationViewController];
        [navigationController setNavigationBarHidden:YES];
        [self presentViewController:navigationController animated:YES completion:NULL];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"勤務地は2つしか設定できません。"
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
        [alertView show];
    }
}

- (void)saveButtonDidClicked:(UIButton *)button
{
    
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.titleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.titleArray[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 60.0;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 60.0)];
        
        UIImage *addImage = [UIImage imageNamed:@"location_add_button"];
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addButton setFrame:CGRectMake(10.0, 9.0, addImage.size.width, addImage.size.height)];
        [addButton setImage:addImage forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(addLocationButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:addButton];
        
        return footerView;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingChangeCell *cell = [tableView dequeueReusableCellWithIdentifier:CCIdentifier];
    
    NSInteger rows = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    
    if (indexPath.row == 0) {
        if ((indexPath.section == 0 && [[[AppManager sharedInstance] areaArray] count] == 1) ||
            (indexPath.section != 0 && [self.titleArray[indexPath.section] count] == 1)) {
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
            Area *area = [[[AppManager sharedInstance] areaArray] objectAtIndex:indexPath.row];
            if (area.name.length > 0) {
                [cell.detailTextLabel setText:area.name];
            } else {
                [cell.detailTextLabel setText:@"-"];
            }
            break;
        }
        case 1: {
            switch (indexPath.row) {
                case 0: {
                    [cell.detailTextLabel setText:[Master restTime1]];
                    break;
                }
                case 1: {
                    [cell.detailTextLabel setText:[Master restTime2]];
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
                    [cell.detailTextLabel setText:[Master weekFromIndex:masterDic[MSTKeyHoliday]]];
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
        case 3: {
            [cell.detailTextLabel setText:[Master formattedMoney:masterDic[MSTKeyPaymentHour]]];
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
            Area *area = [[[AppManager sharedInstance] areaArray] objectAtIndex:indexPath.row];
            LocationViewController *locationViewController = [[LocationViewController alloc] initWithSettingType:SettingTypeReEdit areaModal:area];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:locationViewController];
            [navigationController setNavigationBarHidden:YES];
            [self presentViewController:navigationController animated:YES completion:NULL];
            break;
        }
        case 1: {
            RestViewController *restViewController = [[RestViewController alloc] initWithSettingType:SettingTypeReEdit];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:restViewController];
            [navigationController setNavigationBarHidden:YES];
            [self presentViewController:navigationController animated:YES completion:NULL];
            break;
        }
        case 2: {
            switch (indexPath.row) {
                case 0: {
                    HolidayViewController *holidayViewController = [[HolidayViewController alloc] initWithSettingType:SettingTypeReEdit];
                    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:holidayViewController];
                    [navigationController setNavigationBarHidden:YES];
                    [self presentViewController:navigationController animated:YES completion:NULL];
                    break;
                }
                case 1: {
                    NSString *weekend = [Master valueForKey:MSTKeyHoliday];
                    NSArray *weekArray = [weekend componentsSeparatedByString:@","];
                    if (weekArray.count == 2) {
                        SettingHolidayViewController *settingHolidayViewController = [[SettingHolidayViewController alloc] init];
                        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingHolidayViewController];
                        [navigationController setNavigationBarHidden:YES];
                        [self presentViewController:navigationController animated:YES completion:NULL];
                    } else {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"休日が週1日の場合は、法定内、法定外の設定は不要です。" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                        [alertView show];
                    }
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 3: {
            PaymentViewController *paymentViewController = [[PaymentViewController alloc] initWithSettingType:SettingTypeReEdit];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:paymentViewController];
            [navigationController setNavigationBarHidden:YES];
            [self presentViewController:navigationController animated:YES completion:NULL];
            break;
        }
        default:
            break;
    }
}

@end
