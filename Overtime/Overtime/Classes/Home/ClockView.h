//
//  ClockView.h
//  Overtime
//
//  Created by Xu Shawn on 3/31/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "BaseView.h"
#import "ArcView.h"

@interface ClockView : BaseView

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) ArcView *arcView;
@property (nonatomic, strong) UIImageView *handImageView;

- (void)reloadAtStartTime:(NSString *)startTime endTime:(NSString *)endTime;
- (void)updateTheme:(ThemeType)themeType;

@end
