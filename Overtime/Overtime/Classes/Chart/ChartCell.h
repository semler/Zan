//
//  ChartCell.h
//  Overtime
//
//  Created by Xu Shawn on 3/6/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChartCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *bgImageView;
@property (nonatomic, strong) IBOutlet UILabel *dayLabel;
@property (nonatomic, strong) IBOutlet UILabel *weekLabel;
@property (nonatomic, strong) UIImageView *chartImageView;
@property (nonatomic, strong) UILabel *moneyLabel;
@property (nonatomic, assign) double money;
@property (nonatomic, assign) double maxMoney;
@property (nonatomic, strong) NSDate *date;

- (void)startAnimation;
- (void)setMoneyText:(NSString *)moneyText;

@end
