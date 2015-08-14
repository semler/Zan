//
//  AchievementViewController.h
//  Overtime
//
//  Created by xuxiaoteng on 2/3/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import "BaseViewController.h"
#import "DaysView.h"
#import "Task.h"

@interface AchievementViewController : BaseViewController

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *daysLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UIImageView *animImageView1;
@property (nonatomic, strong) IBOutlet UIImageView *animImageView2;
@property (nonatomic, strong) IBOutlet DaysView *daysView;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *animTopConstraint1;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *animTopConstraint2;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *titleTopConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *congratulationBottomConstraint;

+ (AchievementViewController *)showInController:(UIViewController *)viewController taskInfo:(Task *)task;

@end
