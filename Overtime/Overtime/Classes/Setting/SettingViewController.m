//
//  SettingViewController.m
//  Overtime
//
//  Created by Xu Shawn on 3/6/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingCell.h"
#import "CheckViewController.h"
#import "SettingChangeViewController.h"
#import "SettingInOutViewController.h"
#import "SettingPushViewController.h"
#import "SettingQAViewController.h"
#import "SettingChargeViewController.h"
#import "SettingLegalViewController.h"
#import "SettingInviteViewController.h"
#import "SettingInviteCodeViewController.h"
#import "WebViewController.h"
#import "AchievementViewController.h"
#import "CustomPicker.h"

#import <MessageUI/MessageUI.h>

@interface SettingViewController () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, CustomPickerDelegate>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *kyaraArray;

@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if ([[AppManager sharedInstance] oldUser]) {
            _dataArray = @[@[@"設定内容変更", @"プッシュ通知設定", @"応援キャラ設定"], @[@"Q＆A", @"残業代計算方法について", @"利用規約", @"ご意見箱", @"レビューを書く"]];
        } else {
            if ([MASTER(MSTKeyInvited) boolValue]) {
                _dataArray = @[@[@"設定内容変更", @"プッシュ通知設定", @"応援キャラ設定", @"紹介コードを友達に送る"], @[@"Q＆A", @"残業代計算方法について", @"利用規約", @"ご意見箱", @"レビューを書く"]];
            } else {
                _dataArray = @[@[@"設定内容変更", @"プッシュ通知設定", @"応援キャラ設定", @"紹介コードを友達に送る", @"紹介コード入力画面"], @[@"Q＆A", @"残業代計算方法について", @"利用規約", @"ご意見箱", @"レビューを書く"]];
            }
        }
        
        _kyaraArray = @[@"ランダム", @"秘書", @"オペレーター", @"王様", @"妹"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self configHeaderImage:@"setting_header" andBgImage:@"bg"];
    [self configBackButton];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0, self.contentView.width, self.contentView.height - 10.0) style:UITableViewStyleGrouped];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView registerClass:[SettingCell class] forCellReuseIdentifier:CCIdentifier];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setBackgroundView:nil];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setRowHeight:52.0];
    [self.tableView setSectionHeaderHeight:0];
    [self.tableView setSectionFooterHeight:0];
    [self.tableView setShowsHorizontalScrollIndicator:NO];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [self.contentView addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)recordButtonDidClicked:(UIButton *)button
{
    if ([MFMailComposeViewController canSendMail]) {
        
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        [hud setRemoveFromSuperViewOnHide:YES];
        [hud showAnimated:YES whileExecutingBlock:^{
            NSMutableString *record = [NSMutableString string];
            [record appendString:@"打刻表\n\n\n"];
            [record appendString:@"日付,曜日,出勤時刻,出勤打刻種別,退勤時刻,退勤打刻種別,メモ\n"];
            
            Day *currentDay = [[AppManager sharedInstance] currentDay];
            
            NSArray *yearArray = [[[AppManager sharedInstance] era] yearArray];
            for (Year *year in yearArray) {
                for (Month *month in year.monthArray) {
                    for (Day *day in month.dayArray) {
                        NSDate *startDate = [day.start_date localDateWithFormat:DB_DATE_YMDHMS];
                        NSDate *endDate = [day.end_date localDateWithFormat:DB_DATE_YMDHMS];
                        
                        [record appendFormat:@"%@,", [startDate localStringWithFormat:@"yyyy-M-d"]];
                        [record appendFormat:@"%@,", [startDate localWeekdayString]];

                        NSString *startTime = [startDate displayTime];
                        if (startTime.length > 0) {
                            // Start time
                            [record appendFormat:@"%@,", startTime];
                            
                            // Start date modify
                            if (day.startTime.start_type.length > 0) {
                                if (day.start_type == RecordTypeGPS) {
                                    [record appendString:@"GPS,"];
                                } else if (day.start_type == RecordTypeAuto) {
                                    [record appendString:@"-,"];
                                } else {
                                    NSString *modifyDate;
                                    if (day.start_modify_date.length > 0) {
                                        modifyDate = day.start_modify_date;
                                    } else {
                                        modifyDate = day.startTime.update_date;
                                    }
                                    [record appendFormat:@"%@修正,", modifyDate];
                                }
                            } else {
                                [record appendString:@"-,"];
                            }
                        } else {
                            [record appendString:@"未取得,-,"];
                        }
                        
                        // End date
                        if ([currentDay.ymdDate isEqualToString:day.ymdDate] &&
                            [[AppManager sharedInstance] isWorking]) {
                            [record appendString:@",,"];
                        } else {
                            NSString *endTime = [endDate displayTime];
                            if (endTime.length > 0) {
                                // End time
                                [record appendFormat:@"%@,", endTime];
                                
                                // End date modify
                                if (day.endTime.end_type.length > 0) {
                                    if (day.end_type == RecordTypeGPS) {
                                        [record appendString:@"GPS,"];
                                    } else if (day.end_type == RecordTypeAuto) {
                                        [record appendString:@"-,"];
                                    } else {
                                        NSString *modifyDate;
                                        if (day.end_modify_date.length > 0) {
                                            modifyDate = day.end_modify_date;
                                        } else {
                                            modifyDate = day.endTime.update_date;
                                        }
                                        [record appendFormat:@"%@修正,", modifyDate];
                                    }
                                } else {
                                    [record appendString:@"-,"];
                                }
                            } else {
                                [record appendString:@"未取得,-,"];
                            }
                        }
                        
                        // Memo
                        [record appendFormat:@"%@\n", (day.memo_txt.length > 0 ? day.memo_txt : @"")];
                    }
                }
            }
            DLog(@"%@", record);
            NSData *csvData = [record dataUsingEncoding:NSShiftJISStringEncoding];
            
            [self performSelectorOnMainThread:@selector(presentMailController:) withObject:csvData waitUntilDone:NO];
        }];
    }
}

- (void)presentMailController:(NSData *)csvData
{
    MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] init];
    [composeViewController setMailComposeDelegate:self];
    [composeViewController setSubject:@"俺の打刻レポート"];
    [composeViewController setMessageBody:@"「俺の残業代がこんなに少ないわけがない。」アプリであなたが打刻した記録を一覧にして添付ファイルでレポートします。 CSV形式のファイルが開ける環境のメールアドレスに送って確認しましょう。 ※添付ファイルの打刻記録は位置情報を基にした概算記録です。あなたの職場で採用されている打刻情報とは一致はしないため正確性のあくまでも参考情報としてご確認ください。 ※添付ファイルの打刻記録は、一切の法的根拠を保証するものではありません。" isHTML:NO];
    [composeViewController addAttachmentData:csvData mimeType:@"text/csv" fileName:@"orezan.csv"];
    [self.navigationController presentViewController:composeViewController animated:YES completion:NULL];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    
    if (section <= 1) {
        rows = [[self.dataArray objectAtIndex:section] count];
    }
    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section <= 1) {
        return 15.0;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0;
    switch (section) {
        case 0:
            height = 50.0;
            break;
        case 1:
            height = 50.0;
            break;
        case 2:
            height = 160.0;
            break;
        case 3:
            height = 28.0;
            break;
        default:
            break;
    }
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat height = [self tableView:tableView heightForHeaderInSection:section];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, height)];
    
    switch (section) {
        case 0: {
            UIImage *iconImage = [UIImage imageNamed:@"setting_setting"];
            UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10.0, iconImage.size.width, iconImage.size.height)];
            [iconImageView setImage:iconImage];
            [headerView addSubview:iconImageView];
            break;
        }
        case 1: {
            UIImage *lineImage = [UIImage imageNamed:@"separator_line"];
            UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, lineImage.size.width, lineImage.size.height)];
            [lineImageView setImage:lineImage];
            [headerView addSubview:lineImageView];
            
            UIImage *iconImage = [UIImage imageNamed:@"setting_help"];
            UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, lineImageView.bottom + 10.0, iconImage.size.width, iconImage.size.height)];
            [iconImageView setImage:iconImage];
            [headerView addSubview:iconImageView];
            break;
        }
        case 2: {
            UIImage *lineImage = [UIImage imageNamed:@"separator_line"];
            UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, lineImage.size.width, lineImage.size.height)];
            [lineImageView setImage:lineImage];
            [headerView addSubview:lineImageView];
            
            UIImage *iconImage = [UIImage imageNamed:@"setting_mail"];
            UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, lineImageView.bottom + 10.0, iconImage.size.width, iconImage.size.height)];
            [iconImageView setImage:iconImage];
            [headerView addSubview:iconImageView];
            
            UIImage *recordImage = [UIImage imageNamed:@"setting_record_button"];
            UIButton *recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [recordButton setFrame:CGRectOffsetFromImage(recordImage, (SCREEN_WIDTH - recordImage.size.width) / 2, iconImageView.bottom + 5.0)];
            [recordButton setImage:recordImage forState:UIControlStateNormal];
            [recordButton addTarget:self action:@selector(recordButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
            [headerView addSubview:recordButton];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(17.0, recordButton.bottom + 5.0, headerView.width - 17.0 * 2, 32.0)];
            [label setText:@"※CSVファイルで出退勤時刻を書き出し、メール送信\n  することができます。"];
            [label setTextColor:[UIColor grayColor]];
            [label setNumberOfLines:0];
            [label setFont:[UIFont systemFontOfSize:12.0]];
            [headerView addSubview:label];
            break;
        }
        case 3: {
            UIImage *lineImage = [UIImage imageNamed:@"separator_line"];
            UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, lineImage.size.width, lineImage.size.height)];
            [lineImageView setImage:lineImage];
            [headerView addSubview:lineImageView];
            
            NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, lineImageView.bottom + 15.0, headerView.width, 15.0)];
            [label setText:[NSString stringWithFormat:@"アプリVer %@", version]];
            [label setTextColor:[UIColor grayColor]];
            [label setFont:[UIFont systemFontOfSize:12.0]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [headerView addSubview:label];
            break;
        }
        default:
            break;
    }

    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:CCIdentifier];

    NSArray *dataArray = [self.dataArray objectAtIndex:indexPath.section];
    
    if (indexPath.row == 0) {
        if (indexPath.row != dataArray.count - 1) {
            [cell.imageView setImage:[UIImage imageNamed:@"cell_bg_top"]];
        } else {
            [cell.imageView setImage:[UIImage imageNamed:@"cell_bg"]];
        }
    } else {
        if (indexPath.row != dataArray.count - 1) {
            [cell.imageView setImage:[UIImage imageNamed:@"cell_bg_center"]];
        } else {
            [cell.imageView setImage:[UIImage imageNamed:@"cell_bg_bottom"]];
        }
    }
    [cell.titleLabel setText:dataArray[indexPath.row]];
    
    if (indexPath.section == 0 && indexPath.row == 2) {
        NSInteger kyaraId = [MASTER(MSTKeyKyaraID) integerValue];
        [cell.detailLabel setText:self.kyaraArray[kyaraId]];
        
        if ([MASTER(MSTKeyKyaraNewHidden) integerValue] <= 0) {
            [cell.kyaraNewImageView setHidden:NO];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    SettingChangeViewController *settingChangeViewController = [[SettingChangeViewController alloc] init];
                    [self.navigationController pushViewController:settingChangeViewController animated:YES];
                    break;
                }
                case 1: {
                    SettingPushViewController *settingPushViewController = [[SettingPushViewController alloc] init];
                    [self.navigationController pushViewController:settingPushViewController animated:YES];
                    
//                    SettingInOutViewController *settingInOutViewController = [[SettingInOutViewController alloc] init];
//                    [self.navigationController pushViewController:settingInOutViewController animated:YES];
                    break;
                }
                case 2: {
                    // Kyara new flag
                    NSString *kyaraNewHidden = MASTER(MSTKeyKyaraNewHidden);
                    if ([kyaraNewHidden integerValue] <= 0) {
                        [Master saveValue:@"1" forKey:MSTKeyKyaraNewHidden];
                        [self.tableView reloadData];
                    }
                    
                    CustomPicker *picker = [CustomPicker sharedInstance];
                    [picker setDelegate:self];
                    [picker setShowResetButton:NO];
                    [picker setPickerType:CustomPickerTypeDefault];
                    [picker setDataSource:self.kyaraArray];
                    
                    NSInteger kyaraId = [MASTER(MSTKeyKyaraID) integerValue];
                    NSString *value = self.kyaraArray[kyaraId];
                    [picker setSelectedValues:@[value]];
                    [[CustomPicker sharedInstance] showInView:self.view];
                    break;
                }
                case 3: {
                    SettingInviteCodeViewController *settingInviteCodeVC = [[SettingInviteCodeViewController alloc] init];
                    [self.navigationController pushViewController:settingInviteCodeVC animated:YES];
                    break;
                }
                case 4: {
                    SettingInviteViewController *settingInviteVC = [[SettingInviteViewController alloc] init];
                    [self.navigationController pushViewController:settingInviteVC animated:YES];
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
                    SettingQAViewController *settingQAViewController = [[SettingQAViewController alloc] init];
                    [self.navigationController pushViewController:settingQAViewController animated:YES];
                    break;
                }
                case 1: {
                    SettingChargeViewController *settingChargeViewController = [[SettingChargeViewController alloc] init];
                    [self.navigationController pushViewController:settingChargeViewController animated:YES];
                    break;
                }
                case 2: {
                    SettingLegalViewController *settingLegalViewController = [[SettingLegalViewController alloc] init];
                    [self.navigationController pushViewController:settingLegalViewController animated:YES];
                    break;
                }
                case 3: {
                    WebViewController *webViewController = [[WebViewController alloc] initWithTitle:@"ご意見箱" URLString:SUGGEST_URL webVCType:WebVCTypeSuggest];
                    [self.navigationController pushViewController:webViewController animated:YES];
                    break;
                }
                case 4: {
                    [self addReview];
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

- (void)addReview
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"お喜びの声は是非レビューで叫んでください。\nやっぱり★は５ですよね！" delegate:nil cancelButtonTitle:@"キャンセル" otherButtonTitles:@"Storeへ遷移", nil];
    [alertView setTag:AlertViewTagReview];
    [alertView setDelegate:self];
    [alertView show];
}

- (void)requestTaskComplete:(NSString *)taskTag
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
    NSDictionary *parameters = @{@"uuid": MASTER(MSTKeyUUID), @"task_tag": taskTag};
    [manager POST:@"/task/complete" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"error"] integerValue] == ErrorNone) {
            Task *task = [[AppManager sharedInstance] taskFromTag:taskTag];
            [task setTask_date:[[NSDate date] localStringWithFormat:DB_DATE_YMDHMS]];
            [TaskUtils handleTaskComplete:task];
            [AchievementViewController showInController:self taskInfo:task];
        } else if ([responseObject[@"error"] integerValue] == ErrorUUIDNotFound) {
            // Save uuid flag
            [Master saveValue:@"" forKey:MSTKeyUserLogined];
            // Relogin
            [[AppManager sharedInstance] requestUUID];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [AppManager requestDidFailed:error];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == AlertViewTagReview) {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:REVIEW_URL]];
            
            if ([[AppManager sharedInstance] taskValidFromTag:TASK_ADD_REVIEW]) {
                [self requestTaskComplete:TASK_ADD_REVIEW];
            }
        }
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - CustomPickerDelegate

- (void)customPicker:(CustomPicker *)picker didSelectDone:(id)value
{
    NSInteger kyaraId = [self.kyaraArray indexOfObject:value];
    [Master saveValue:[NSString stringWithFormat:@"%d", (int)kyaraId] forKey:MSTKeyKyaraID];
    if (kyaraId > 0) {
        [Master saveValue:[NSString stringWithFormat:@"%d", (int)kyaraId - 1] forKey:MSTKeyPushMsgType];
    }
    [self.tableView reloadData];
}

@end
