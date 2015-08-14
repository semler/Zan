//
//  CheckViewController.m
//  Overtime
//
//  Created by Xu Shawn on 3/6/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "CheckViewController.h"
#import "MainViewController.h"
#import "LocationViewController.h"
#import "RestViewController.h"
#import "HolidayViewController.h"
#import "PaymentViewController.h"

@interface CheckViewController ()

@end

@implementation CheckViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self configBackButton];
    
    [self.scrollView addSubview:self.contentView];
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.width, self.contentView.height)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark - Private

- (void)reloadData
{
    NSDictionary *masterDic = [[AppManager sharedInstance] masterDic];
    
    Area *area = [[[AppManager sharedInstance] areaArray] lastObject];
    [self.locationLabel setText:area.name];
    [self.rest1Label setText:[Master restTime1]];
    [self.rest2Label setText:[Master restTime2]];
    [self.holidayLabel setText:[Master weekFromIndex:masterDic[MSTKeyHoliday]]];
    [self.paymentLabel setText:[Master formattedMoney:masterDic[MSTKeyPaymentHour]]];
}

- (IBAction)locationButtonDidClicked:(id)sender
{
    Area *area = [[[AppManager sharedInstance] areaArray] lastObject];
    LocationViewController *locationViewController = [[LocationViewController alloc] initWithSettingType:SettingTypeEdit areaModal:area];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:locationViewController];
    [navigationController setNavigationBarHidden:YES];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

- (IBAction)restButtonDidClicked:(id)sender
{
    RestViewController *restViewController = [[RestViewController alloc] initWithSettingType:SettingTypeEdit];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:restViewController];
    [navigationController setNavigationBarHidden:YES];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

- (IBAction)holidayButtonDidClicked:(id)sender
{
    HolidayViewController *holidayViewController = [[HolidayViewController alloc] initWithSettingType:SettingTypeEdit];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:holidayViewController];
    [navigationController setNavigationBarHidden:YES];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

- (IBAction)paymentButtonDidClicked:(id)sender
{
    PaymentViewController *paymentViewController = [[PaymentViewController alloc] initWithSettingType:SettingTypeEdit];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:paymentViewController];
    [navigationController setNavigationBarHidden:YES];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

- (IBAction)doneButtonDidClicked:(id)sender
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud setRemoveFromSuperViewOnHide:YES];
    [hud showAnimated:YES whileExecutingBlock:^{
        // Cancel last
        [AppManager cancelLastConfirmNotification];
        // Last confirm
        [AppManager addLastConfirmNotification];
        
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
    
    UINavigationController *navigationController = self.navigationController;
    // Save memory
    [navigationController popToRootViewControllerAnimated:NO];
    // Main page
    MainViewController *mainViewController = [[MainViewController alloc] init];
    [navigationController pushViewController:mainViewController animated:YES];
}

//// 端末登録
//- (void)entryTerminalInfo
//{
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//
//    AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
//    
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    // 端末アプリ/センターアプリ種別
//    [params setObject:DIV forKey:@"div"];
//    // サービスID
//    [params setObject:SID forKey:@"sid"];
//    // ユーザID
//    [params setObject:UID forKey:@"uid"];
//    // 端末ID
//    [params setObject:[[AppManager sharedInstance] UDID] forKey:@"mid"];
//    // 端末認証用パスワード
//    [params setObject:DEVICE_PWD forKey:@"pwd"];
//    // 端末固有ID
//    [params setObject:[[AppManager sharedInstance] UDID] forKey:@"ownid"];
//    // 端末有効化フラグ
//    [params setObject:@"1" forKey:@"upd"];
//    // 端末識別フラグ
//    [params setObject:@"1" forKey:@"tmflg"];
//    
//    DLog(@"EntryTerminalInfo: %@", params);
//    [manager POST:@"EntryTerminalInfo" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        DLog(@"EntryTerminalInfo: %@", responseObject);
//        
//        NSDictionary *status = responseObject[@"status"];
//        
//        if ([status[@"returnCode"] integerValue] == 0) {
//            [self entryAreaInfo];
//        } else {
//            NSDictionary *errorInfo = status[@"errorInfo"];
//            if ([errorInfo[@"errMsgId"] isEqualToString:@"E116505"]) {
//                [self entryAreaInfo];
//            } else {
//                [AppManager requestDidFailedWithResult:responseObject];
//            }
//            DLog(@"%@", status[@"errorInfo"][@"errMsg"]);
//        }
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        DLog(@"%@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
//        [AppManager requestDidFailed:error];
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//    }];
//}
//
//// エリア情報登録
//- (void)entryAreaInfo
//{
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    
//    AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
//    
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    // 端末アプリ/センターアプリ種別
//    [params setObject:DIV forKey:@"div"];
//    // サービスID
//    [params setObject:SID forKey:@"sid"];
//    // 企業ID
//    [params setObject:CID forKey:@"cid"];
//    // ユーザID
//    [params setObject:UID forKey:@"uid"];
//    // 端末ID
//    [params setObject:[[AppManager sharedInstance] UDID] forKey:@"mid"];
//    // エリアID
//    [params setObject:[[AppManager sharedInstance] aid] forKey:@"aid"];
//    // エリア情報種別
//    [params setObject:@"4" forKey:@"atp"];
//    // ポリゴン情報
//    [params setObject:@"" forKey:@"geom"];
//    // 緯度
//    [params setObject:[NSString stringWithFormat:@"%f", [AppManager sharedInstance].latitude] forKey:@"lat"];
//    // 経度
//    [params setObject:[NSString stringWithFormat:@"%f", [AppManager sharedInstance].longitude] forKey:@"lon"];
//    // 半径
//    [params setObject:[NSString stringWithFormat:@"%d", [AppManager sharedInstance].radius] forKey:@"rad"];
//    // 説明
//    [params setObject:[AppManager sharedInstance].place forKey:@"msg"];
//    // IN精度閾値
//    [params setObject:@"1" forKey:@"inlv"];
//    // IN確定回数閾値
//    [params setObject:@"2" forKey:@"infnum"];
//    // IN確定時間閾値
//    [params setObject:@"1" forKey:@"inftim"];
//    // IN最低回数閾値
//    [params setObject:@"1" forKey:@"inmitim"];
//    // OUT精度閾値
//    [params setObject:@"1" forKey:@"outlv"];
//    // OUT確定回数閾値
//    [params setObject:@"2" forKey:@"outfnum"];
//    // OUT確定時間閾値
//    [params setObject:@"1" forKey:@"outftim"];
//    // OUT最低回数閾値
//    [params setObject:@"1" forKey:@"outmitim"];
//    // 有効期間(開始)
//    [params setObject:@"" forKey:@"vst"];
//    // 有効期間(終了)
//    [params setObject:@"" forKey:@"vet"];
//    // TIMEOUT閾値
//    [params setObject:@"" forKey:@"tout"];
//    
//    DLog(@"EntryAreaInfo: %@", params);
//    [manager POST:@"EntryAreaInfo" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        DLog(@"EntryAreaInfo: %@", responseObject);
//        
//        NSDictionary *status = responseObject[@"status"];
//        
//        if ([status[@"returnCode"] integerValue] == 0) {
//            [self entryNotifyConditionWithNtmg:@"1"];
//        } else {
//            DLog(@"%@", status[@"errorInfo"][@"errMsg"]);
//            [AppManager requestDidFailedWithResult:responseObject];
//        }
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"%@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
//        [AppManager requestDidFailed:error];
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//    }];
//}
//
//- (void)deleteAreaInfo
//{
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    
//    AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
//    
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    // 端末アプリ/センターアプリ種別
//    [params setObject:DIV forKey:@"div"];
//    // サービスID
//    [params setObject:SID forKey:@"sid"];
//    // 企業ID
//    [params setObject:CID forKey:@"cid"];
//    // ユーザID
//    [params setObject:UID forKey:@"uid"];
//    // 削除対象エリアID
//    [params setObject:[[AppManager sharedInstance] aid] forKey:@"daid"];
//    
//    DLog(@"DeleteAreaInfo: %@", params);
//    [manager POST:@"DeleteAreaInfo" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        DLog(@"DeleteAreaInfo: %@", responseObject);
//        
//        NSDictionary *status = responseObject[@"status"];
//        
//        if ([status[@"returnCode"] integerValue] == 0) {
//            
//        } else {
//            DLog(@"%@", status[@"errorInfo"][@"errMsg"]);
//            [AppManager requestDidFailedWithResult:responseObject];
//        }
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"%@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
//        [AppManager requestDidFailed:error];
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//    }];
//}
//
//- (void)entryNotifyConditionWithNtmg:(NSString *)ntmg
//{
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    
//    AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
//    
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    // 端末アプリ/センターアプリ種別
//    [params setObject:DIV forKey:@"div"];
//    // サービスID
//    [params setObject:SID forKey:@"sid"];
//    // 企業ID
//    [params setObject:CID forKey:@"cid"];
//    // ユーザID
//    [params setObject:UID forKey:@"uid"];
//    // 端末ID
//    [params setObject:[[AppManager sharedInstance] UDID] forKey:@"mid"];
//    // エリアID
//    [params setObject:[[AppManager sharedInstance] aid] forKey:@"aid"];
//    // 通知条件種別
//    [params setObject:@"4" forKey:@"ntp"];
//    // 通知タイミング 1:IN 2:OUT
//    [params setObject:ntmg forKey:@"ntmg"];
//    // 通知曜日
//    [params setObject:@"0,1,2,3,4,5,6" forKey:@"nwk"];
//    // 通知開始時間(hhmm形式)
//    [params setObject:@"0000" forKey:@"nstm"];
//    // 通知終了時間(hhmm形式)
//    [params setObject:@"2359" forKey:@"netm"];
//    // 通知開始期間(YYYYMMDDhhmm形式)
//    [params setObject:@"201401010000" forKey:@"nsvd"];
//    // 通知終了期間(YYYYMMDDhhmm形式)
//    [params setObject:@"202012312359" forKey:@"nevd"];
//    // 再通知禁止日数
//    [params setObject:@"0" forKey:@"notnd"];
//    // 通知先URL
//    [params setObject:@"http://overtime.dev.vc/" forKey:@"nurl"];
//    
//    DLog(@"EntryNotifyCondition: %@", params);
//    [manager POST:@"EntryNotifyCondition" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        DLog(@"EntryNotifyCondition: %@", responseObject);
//        
//        NSDictionary *status = responseObject[@"status"];
//        
//        if ([status[@"returnCode"] integerValue] == 0) {
//            NSDictionary *result = responseObject[@"result"];
//            if ([ntmg isEqualToString:@"1"]) {
//                [[AppManager sharedInstance] setNidIn:result[@"nid"]];
//                [self entryNotifyConditionWithNtmg:@"2"];
//            } else if ([ntmg isEqualToString:@"2"]) {
//                [[AppManager sharedInstance] setNidOut:result[@"nid"]];
//                
//                MainViewController *mainViewController = [[MainViewController alloc] init];
//                [self.navigationController pushViewController:mainViewController animated:YES];
//            }
//            
//        } else {
//            DLog(@"%@", status[@"errorInfo"][@"errMsg"]);
//            [AppManager requestDidFailedWithResult:responseObject];
//        }
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"%@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
//        [AppManager requestDidFailed:error];
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//    }];
//}
//
//- (void)deleteNotifyCondition
//{
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    
//    AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
//    
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    // 端末アプリ/センターアプリ種別
//    [params setObject:DIV forKey:@"div"];
//    // サービスID
//    [params setObject:SID forKey:@"sid"];
//    // 企業ID
//    [params setObject:CID forKey:@"cid"];
//    // ユーザID
//    [params setObject:UID forKey:@"uid"];
//    // 削除対象通知条件ID
//    [params setObject:[[AppManager sharedInstance] nidIn] forKey:@"dnid"];
//    
//    DLog(@"DeleteNotifyCondition: %@", params);
//    [manager POST:@"DeleteNotifyCondition" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        DLog(@"DeleteNotifyCondition: %@", responseObject);
//        
//        NSDictionary *status = responseObject[@"status"];
//        
//        if ([status[@"returnCode"] integerValue] == 0) {
//            
//        } else {
//            DLog(@"%@", status[@"errorInfo"][@"errMsg"]);
//            [AppManager requestDidFailedWithResult:responseObject];
//        }
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        DLog(@"%@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
//        [AppManager requestDidFailed:error];
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//    }];
//}
//
//- (void)searchNotifyConditionList
//{
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    
//    AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
//    
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    // 端末アプリ/センターアプリ種別
//    [params setObject:DIV forKey:@"div"];
//    // サービスID
//    [params setObject:SID forKey:@"sid"];
//    // 企業ID
//    [params setObject:CID forKey:@"cid"];
//    // ユーザID
//    [params setObject:UID forKey:@"uid"];
//    // 端末認証用パスワード
//    [params setObject:DEVICE_PWD forKey:@"pwd"];
//    // 端末固有ID
//    [params setObject:[[AppManager sharedInstance] UDID] forKey:@"ownid"];
//    // 取得対象通知条件種別
//    [params setObject:@"4" forKey:@"tntp"];
//    // 取得対象通知条件レベル
//    [params setObject:@"0" forKey:@"tnlv"];
//    // 取得対象企業ID
//    [params setObject:CID forKey:@"tcid"];
//    // 取得対象ユーザID
//    [params setObject:UID forKey:@"tuid"];
//    // 取得対象端末ID
//    [params setObject:[[AppManager sharedInstance] UDID] forKey:@"tmid"];
//    // 取得対象通知条件ID
//    [params setObject:[[AppManager sharedInstance] nidIn] forKey:@"tnid"];
//    // 取得開始位置
//    [params setObject:@"1" forKey:@"offset"];
//    // 取得件数
//    [params setObject:@"10" forKey:@"limit"];
//    
//    DLog(@"SearchNotifyConditionList: %@", params);
//    [manager POST:@"SearchNotifyConditionList" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        DLog(@"SearchNotifyConditionList: %@", responseObject);
//        
//        NSDictionary *status = responseObject[@"status"];
//        
//        if ([status[@"returnCode"] integerValue] == 0) {
//            
//        } else {
//            DLog(@"%@", status[@"errorInfo"][@"errMsg"]);
//            [AppManager requestDidFailedWithResult:responseObject];
//        }
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        DLog(@"%@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
//        [AppManager requestDidFailed:error];
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//    }];
//}

@end
