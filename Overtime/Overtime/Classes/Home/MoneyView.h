//
//  MoneyView.h
//  Overtime
//
//  Created by Xu Shawn on 2/18/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "BaseView.h"

@interface MoneyView : BaseView

@property (nonatomic, assign) NSInteger money;
@property (nonatomic, assign) ThemeType themeType;

- (void)setMoney:(NSInteger)money withThemeType:(ThemeType)themeType;

@end
