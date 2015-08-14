//
//  PaymentMonthViewController.h
//  Overtime
//
//  Created by Xu Shawn on 3/26/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "BaseViewController.h"

@interface PaymentMonthViewController : BaseViewController

@property (nonatomic, assign) SettingType settingType;

- (id)initWithSettingType:(SettingType)settingType;

@end
