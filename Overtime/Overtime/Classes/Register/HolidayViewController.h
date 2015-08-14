//
//  HolidayViewController.h
//  Overtime
//
//  Created by Xu Shawn on 3/6/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, HolidayType) {
    HolidayTypeWork,
    HolidayTypeNotice
};

@interface HolidayViewController : BaseViewController

@property (nonatomic, assign) SettingType settingType;
@property (nonatomic, assign) HolidayType holidayType;

- (id)initWithSettingType:(SettingType)settingType;
- (id)initWithSettingType:(SettingType)settingType holidayType:(HolidayType)holidayType;

@end
