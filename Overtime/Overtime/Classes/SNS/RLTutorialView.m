//
//  RLTutorialView.m
//  Overtime
//
//  Created by Ryuukou on 21/1/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import "RLTutorialView.h"
#import "CustomPicker.h"
#import "SNSCompanyResponse.h"
#import "SNSJobResponse.h"
#import "SNSSelf.h"

@interface RLTutorialView () <CustomPickerDelegate,UITextViewDelegate>

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *textViewPlaceHolder;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *genderButton;
@property (nonatomic, strong) UIButton *careerButton;
@property (nonatomic, strong) UIButton *firmButton;
@property (nonatomic, assign) BOOL canGoNext;
@property (nonatomic, strong) NSMutableDictionary *inputParams;

@property (nonatomic, strong) NSArray *companyList;
@property (nonatomic, strong) NSArray *jobList;

@end

#define SELECT_TEXT_1  @"性別を選択"
#define SELECT_TEXT_2  @"職種を選択"
#define SELECT_TEXT_3  @"どんな会社かを選択"
#define TEXTVIEW_PLACEHOLDER  @"残業への気持ちを30文字以内でどうぞ"

@implementation RLTutorialView

- (instancetype)initWithFrame:(CGRect)frame index:(NSUInteger)index tutorial:(BOOL)tutorial
{
    self = [super initWithFrame:frame];
    if (self) {
        _index = index;
        _tutorial = tutorial;
        _inputParams = [NSMutableDictionary dictionary];
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.backgroundImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"sns_turorial_0%d",(int)index + 1]];
        [self addSubview:_backgroundImageView];
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.tag = index;
        [_button addTarget:self
                    action:@selector(tapHandle:)
          forControlEvents:UIControlEventTouchUpInside];
        [self loadViewForIndex];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadNextButton
{
    UIImage *buttonImage = [UIImage imageNamed:@"btn-flick"];
    [self.button setBackgroundImage:buttonImage
                           forState:UIControlStateNormal];
    self.button.frame = CGRectMake((self.width - buttonImage.size.width)/2,
                                   (IS_RETINA4 ? 520 : 435),
                                   buttonImage.size.width,
                                   buttonImage.size.height);
    [self addSubview:self.button];
}

- (void)loadJumpArrow
{
    UIImage *arrowImage = [UIImage imageNamed:@"down_arrow"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:arrowImage];
    imageView.frame = CGRectMake(278, 270 - arrowImage.size.height,
                                 arrowImage.size.width,
                                 arrowImage.size.height);
    [self addSubview:imageView];
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionAutoreverse |
                                UIViewAnimationOptionRepeat |
                                UIViewAnimationOptionCurveLinear
                     animations:^{
                         imageView.frame = CGRectMake(278, 280 - arrowImage.size.height,
                                                      arrowImage.size.width,
                                                      arrowImage.size.height);
                     }
                     completion:NULL];
}

- (void)loadRedArrow
{
    UIImage *arrowImage = [UIImage imageNamed:@"arrow_red"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:arrowImage];
    imageView.frame = CGRectMake(250, 270 - arrowImage.size.height,
                                 arrowImage.size.width,
                                 arrowImage.size.height);
    [self addSubview:imageView];
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionAutoreverse |
                                UIViewAnimationOptionRepeat |
                                UIViewAnimationOptionCurveLinear
                     animations:^{
                         imageView.frame = CGRectMake(250, 280 - arrowImage.size.height,
                                                      arrowImage.size.width,
                                                      arrowImage.size.height);
                     }
                     completion:NULL];
}

- (void)loadSettingButton
{
    UIImage *buttonImage = [UIImage imageNamed:@"btn_your_setting"];
    [self.button setBackgroundImage:buttonImage
                           forState:UIControlStateNormal];
    self.button.frame = CGRectMake((self.width - buttonImage.size.width)/2,
                                   (IS_RETINA4 ? 520 : 435),
                                   buttonImage.size.width,
                                   buttonImage.size.height);
    [self addSubview:self.button];
}

- (void)loadConfirmButton
{
    UIImage *buttonImage = [UIImage imageNamed:@"btn_confirm"];
    [self.button setBackgroundImage:buttonImage
                           forState:UIControlStateNormal];
    self.button.frame = CGRectMake((self.width - buttonImage.size.width)/2,
                                   (IS_RETINA4 ? 508 : 423),
                                   buttonImage.size.width,
                                   buttonImage.size.height);
    [self addSubview:self.button];
}

- (void)loadSettingInput
{
    // 40x93
    UIImage *textBgImage = [UIImage imageNamed:@"text_bg_big"];
    UIImageView *textBgView = [[UIImageView alloc] initWithImage:textBgImage];
    textBgView.frame = CGRectMake(40, (IS_RETINA4 ? 130:93), textBgImage.size.width, textBgImage.size.height);
    [self addSubview:textBgView];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(CGRectGetMinX(textBgView.frame) + 10,
                                                                           CGRectGetMinY(textBgView.frame) + 9,
                                                                           215, CGRectGetHeight(textBgView.frame) - 18)];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.delegate = self;
    self.textView.returnKeyType = UIReturnKeyDone;
    self.textView.textColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textChanged:)
                                                 name:UITextViewTextDidChangeNotification object:nil];
    [self addSubview:self.textView];
    
    if (!self.tutorial) {
        [self.textView setEditable:NO];
        [self.textView setTextColor:[UIColor grayColor]];
    }
    
    self.textViewPlaceHolder = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(textBgView.frame) + 14,
                                                                         CGRectGetMinY(textBgView.frame) + 9,
                                                                         234, CGRectGetHeight(textBgView.frame) - 18)];
    self.textViewPlaceHolder.text = TEXTVIEW_PLACEHOLDER;
    self.textViewPlaceHolder.textColor = [UIColor whiteColor];
    self.textViewPlaceHolder.font = [UIFont systemFontOfSize:12.0f];
    [self addSubview:self.textViewPlaceHolder];
    
    UIImage *selectBgImage = [UIImage imageNamed:@"text_bg_small"];
    self.genderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.genderButton setBackgroundImage:selectBgImage
                            forState:UIControlStateNormal];
    self.genderButton.frame = CGRectMake(CGRectGetMinX(textBgView.frame),
                                    (IS_RETINA4 ? 220:191),
                                    selectBgImage.size.width,
                                    selectBgImage.size.height);
    self.genderButton.tag = 1;
    [self.genderButton setTitle:SELECT_TEXT_1 forState:UIControlStateNormal];
    self.genderButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.genderButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    self.genderButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.genderButton addTarget:self
                     action:@selector(inputButtonHandle:)
           forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.genderButton];

    self.careerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.careerButton setBackgroundImage:selectBgImage
                            forState:UIControlStateNormal];
    self.careerButton.frame = CGRectMake(CGRectGetMinX(textBgView.frame),
                                    (IS_RETINA4 ? 300:270),
                                    selectBgImage.size.width,
                                    selectBgImage.size.height);
    self.careerButton.tag = 2;
    [self.careerButton setTitle:SELECT_TEXT_2 forState:UIControlStateNormal];
    self.careerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.careerButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    self.careerButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.careerButton addTarget:self
                     action:@selector(inputButtonHandle:)
           forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.careerButton];
    
    self.firmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.firmButton setBackgroundImage:selectBgImage
                            forState:UIControlStateNormal];
    self.firmButton.frame = CGRectMake(CGRectGetMinX(textBgView.frame),
                                    (IS_RETINA4 ? 375: 350),
                                    selectBgImage.size.width,
                                    selectBgImage.size.height);
    self.firmButton.tag = 3;
    [self.firmButton setTitle:SELECT_TEXT_3 forState:UIControlStateNormal];
    self.firmButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.firmButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    self.firmButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.firmButton addTarget:self
                     action:@selector(inputButtonHandle:)
           forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.firmButton];
}

- (void)loadPreviousInputData
{
    if ([MASTER(MSTKeyFirstLaunch) length] != 0) {
        NSString *message = MASTER(MSTKeyMessage);
        if (message.length != 0) {
            self.textView.text = message;
            self.textViewPlaceHolder.hidden = YES;
        } else {
            self.textViewPlaceHolder.hidden = NO;
        }
        [self.genderButton setTitle:MASTER(MSTKeyGender) forState:UIControlStateNormal];
        [self.careerButton setTitle:MASTER(MSTKeyCareer) forState:UIControlStateNormal];
        [self.firmButton setTitle:MASTER(MSTKeyCompany) forState:UIControlStateNormal];
        self.inputParams[@"uuid"] = MASTER(MSTKeyUUID);
        self.inputParams[@"message"] = MASTER(MSTKeyMessage);
        self.inputParams[@"sex"] = @([MASTER(MSTKeyGenderID) integerValue]);
        self.inputParams[@"company_id"] = @([MASTER(MSTKeyCompanyID) integerValue]);
        self.inputParams[@"job_id"] = @([MASTER(MSTKeyCareerID) integerValue]);
    }
}

- (void)loadSupportButton
{
    UIImage *buttonImage = [UIImage imageNamed:@"ouen"];
    [self.button setBackgroundImage:buttonImage
                           forState:UIControlStateNormal];
    self.button.frame = CGRectMake(249,
                                   284,
                                   buttonImage.size.width,
                                   buttonImage.size.height);
    [self addSubview:self.button];
}

- (void)loadViewForIndex
{
    switch (self.index) {
        case 0: {
            self.canGoNext = YES;
            [self loadNextButton];
            break;
        }
        case 1: {
            self.canGoNext = YES;
            [self loadNextButton];
            break;
        }
        case 2: {
            self.canGoNext = YES;
            [self loadJumpArrow];
            [self loadNextButton];
            break;
        }
        case 3:
            self.canGoNext = YES;
            [self loadRedArrow];
            [self loadSupportButton];
            break;
        case 4:
            self.canGoNext = YES;
            [self loadJumpArrow];
            [self loadSettingButton];
            break;
        case 5:
            [self loadSettingInput];
            [self loadPreviousInputData];
            [self loadConfirmButton];
            break;
        case 6:
            self.canGoNext = YES;
            [self loadNextButton];
            break;
        default:
            break;
    }
}

- (void)loadCompanyList
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
    [manager POST:@"company/list" parameters:@{@"uuid" : MASTER(MSTKeyUUID)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        [hud hide:YES];
        SNSCompanyResponse *response = [MTLJSONAdapter modelOfClass:SNSCompanyResponse.class fromJSONDictionary:responseObject error:&error];
        if (!error && response.error == ErrorNone) {
            
        } else if (response.error == ErrorUUIDNotFound) {
            // Save uuid flag
            [Master saveValue:@"" forKey:MSTKeyUserLogined];
            // Relogin
            [[AppManager sharedInstance] requestUUID];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hide:YES];
        [AppManager requestDidFailed:error];
    }];
}

- (void)loadJobList
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
    [manager POST:@"user/jobs" parameters:@{@"uuid" : MASTER(MSTKeyUUID)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        [hud hide:YES];
        SNSJobResponse *response = [MTLJSONAdapter modelOfClass:SNSJobResponse.class fromJSONDictionary:responseObject error:&error];
        if (!error && response.error == ErrorNone) {
            
        } else if (response.error == ErrorUUIDNotFound) {
            // Save uuid flag
            [Master saveValue:@"" forKey:MSTKeyUserLogined];
            // Relogin
            [[AppManager sharedInstance] requestUUID];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hide:YES];
        [AppManager requestDidFailed:error];
    }];
}

- (void)inputButtonHandle:(UIButton *)button
{
    [self endEditing:YES];
    CustomPicker *picker = [CustomPicker sharedInstance];
    [picker setDelegate:self];
    [picker setShowResetButton:NO];
    [picker setPickerType:CustomPickerTypeDefault];
    picker.tag = button.tag;
    
    switch (button.tag) {
        case 1: {
            [picker setDataSource:@[@"男性",@"女性"]];
            [[CustomPicker sharedInstance] showInView:self];
            break;
        }
        case 2: {
            // job list
            if (self.jobList.count > 0) {
                NSMutableArray *array = [NSMutableArray array];
                for (int i = 0; i < self.jobList.count; i ++) {
                    SNSJob *company = self.jobList[i];
                    [array addObject:company.jobName];
                }
                [picker setDataSource:array];
                [[CustomPicker sharedInstance] showInView:self];
            } else {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
                AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
                [manager POST:@"user/jobs" parameters:@{@"uuid" : MASTER(MSTKeyUUID)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSError *error = nil;
                    [hud hide:YES];
                    SNSJobResponse *response = [MTLJSONAdapter modelOfClass:SNSJobResponse.class fromJSONDictionary:responseObject error:&error];
                    if (!error && response.error == ErrorNone) {
                        self.jobList = response.jobs;
                        NSMutableArray *array = [NSMutableArray array];
                        for (int i = 0; i < response.jobs.count; i ++) {
                            SNSJob *company = response.jobs[i];
                            [array addObject:company.jobName];
                        }
                        [picker setDataSource:array];
                        [[CustomPicker sharedInstance] showInView:self];
                    } else if (response.error == ErrorUUIDNotFound) {
                        // Save uuid flag
                        [Master saveValue:@"" forKey:MSTKeyUserLogined];
                        // Relogin
                        [[AppManager sharedInstance] requestUUID];
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [hud hide:YES];
                    [AppManager requestDidFailed:error];
                }];
            }
            break;
        }
        case 3: {
            // company list
            if (self.companyList.count > 0) {
                NSMutableArray *array = [NSMutableArray array];
                for (int i = 0; i < self.companyList.count; i ++) {
                    SNSCompany *company = self.companyList[i];
                    [array addObject:company.companyName];
                }
                [picker setDataSource:array];
                [[CustomPicker sharedInstance] showInView:self];
            } else {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
                AFHTTPRequestOperationManager *manager = [AppManager requestOperationManager];
                [manager POST:@"company/list" parameters:@{@"uuid" : MASTER(MSTKeyUUID)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSError *error = nil;
                    [hud hide:YES];
                    SNSCompanyResponse *response = [MTLJSONAdapter modelOfClass:SNSCompanyResponse.class fromJSONDictionary:responseObject error:&error];
                    if (!error && response.error == ErrorNone) {
                        self.companyList = response.companys;
                        NSMutableArray *array = [NSMutableArray array];
                        for (int i = 0; i < response.companys.count; i ++) {
                            SNSCompany *company = response.companys[i];
                            [array addObject:company.companyName];
                        }
                        [picker setDataSource:array];
                        [[CustomPicker sharedInstance] showInView:self];
                    } else if (response.error == ErrorUUIDNotFound) {
                        // Save uuid flag
                        [Master saveValue:@"" forKey:MSTKeyUserLogined];
                        // Relogin
                        [[AppManager sharedInstance] requestUUID];
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [hud hide:YES];
                    [AppManager requestDidFailed:error];
                }];
            }
            break;
        }
        default:
            break;
    }
}

- (BOOL)checkInputs
{
    if (self.textView.text.length != 0 &&
        ![((UIButton *)[self viewWithTag:1]).titleLabel.text isEqualToString:SELECT_TEXT_1] &&
        ![((UIButton *)[self viewWithTag:2]).titleLabel.text isEqualToString:SELECT_TEXT_2] &&
        ![((UIButton *)[self viewWithTag:3]).titleLabel.text isEqualToString:SELECT_TEXT_3]) {
        self.inputParams[@"uuid"] = MASTER(MSTKeyUUID);
        self.inputParams[@"message"] = self.textView.text;
        [Master saveValue:self.textView.text forKey:MSTKeyMessage];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)textViewLimit
{
    return (self.textView.text.length <= 30);
}

- (void)tapHandle:(UIButton *)button
{
    if (![self textViewLimit]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"残業の気持ちは３０文字まで入力できます。"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    } else if (![self checkInputs] && self.index == 5) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"入力に不備があるみたいです"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    } else {
        if ([self.delegate respondsToSelector:@selector(tutorialViewButtonTaped:withObject:)]) {
            [self.delegate tutorialViewButtonTaped:self withObject:self.inputParams];
        }
    }
}

- (void)inputChanged
{
    if ([self.delegate respondsToSelector:@selector(tutorialView:inputChangedWithResult:)]) {
        [self.delegate tutorialView:self inputChangedWithResult:([self textViewLimit] &&[self checkInputs])];
    }
}

#pragma mark - Touch Delegate

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endEditing:YES];
}

#pragma mark - Custom Picker Delegate
- (void)customPicker:(CustomPicker *)picker
       didSelectDone:(id)value
{
    UIButton *button = (UIButton *)[self viewWithTag:picker.tag];
    if (picker.tag == self.firmButton.tag) {
        NSArray *array = [self.companyList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"companyName = %@",value]];
        if (array.count > 0) {
            SNSCompany *company = array[0];
            self.inputParams[@"company_id"] = @(company.companyID);
            [Master saveValue:company.companyName forKey:MSTKeyCompany];
            [Master saveValue:[NSString stringWithFormat:@"%d",company.companyID] forKey:MSTKeyCompanyID];
        }
    } else if (picker.tag == self.careerButton.tag) {
        NSArray *array = [self.jobList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"jobName = %@",value]];
        if (array.count > 0) {
            SNSJob *job = array[0];
            self.inputParams[@"job_id"] = @(job.jobID);
            [Master saveValue:job.jobName forKey:MSTKeyCareer];
            [Master saveValue:[NSString stringWithFormat:@"%d",job.jobID] forKey:MSTKeyCareerID];
        }
    } else if (picker.tag == self.genderButton.tag) {
        [Master saveValue:value forKey:MSTKeyGender];
        if ([value isEqualToString:@"男性"]) {
            self.inputParams[@"sex"] = @(1);
        } else {
            self.inputParams[@"sex"] = @(2);
        }
        [Master saveValue:[self.inputParams[@"sex"] stringValue] forKey:MSTKeyGenderID];
    }
    [button setTitle:value forState:UIControlStateNormal];
    [self inputChanged];
}

#pragma mark - Text View Delegate


- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [[CustomPicker sharedInstance] hide];
    self.textViewPlaceHolder.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (self.textView.text.length == 0) {
        self.textViewPlaceHolder.hidden = NO;
    }
}

- (void)textChanged:(NSNotification *)notification
{
    [self inputChanged];
}

@end
