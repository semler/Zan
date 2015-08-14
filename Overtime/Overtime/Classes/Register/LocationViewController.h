//
//  LocationViewController.h
//  Overtime
//
//  Created by Xu Shawn on 3/6/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "BaseViewController.h"

@interface LocationViewController : BaseViewController

@property (nonatomic, assign) SettingType settingType;

- (id)initWithSettingType:(SettingType)settingType areaModal:(Area *)area;

@end
