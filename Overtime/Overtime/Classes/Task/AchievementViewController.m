//
//  AchievementViewController.m
//  Overtime
//
//  Created by xuxiaoteng on 2/3/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import "AchievementViewController.h"

@interface AchievementViewController ()

@property (nonatomic, copy) NSString *taskTitle;

@end

@implementation AchievementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.animImageView1 setAlpha:0];
    [self.animImageView2 setAlpha:0];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self.animImageView1 setAlpha:1.0];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    [UIView animateWithDuration:0.5
                          delay:0.2
                        options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self.animImageView2 setAlpha:1.0];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (!IS_RETINA4) {
        self.animTopConstraint1.constant = 40.0;
        self.animTopConstraint2.constant = 40.0;
        self.titleTopConstraint.constant = 35.0;
        self.congratulationBottomConstraint.constant = 5.0;
    }
}

+ (AchievementViewController *)showInController:(UIViewController *)viewController taskInfo:(Task *)task
{
    if ([[AppManager sharedInstance] oldUser]) {
        return nil;
    }
    AchievementViewController *achievementViewController = [[AchievementViewController alloc] init];
    
    [viewController addChildViewController:achievementViewController];
    [achievementViewController.view setFrame:viewController.view.bounds];
    [viewController.view addSubview:achievementViewController.view];
    [achievementViewController.titleLabel setText:task.task_title];
    [achievementViewController.daysLabel setText:task.task_days];
    [achievementViewController.dateLabel setText:task.task_date];
    [achievementViewController.daysView setDays:[task.task_days integerValue]];
    
    [achievementViewController.view setAlpha:0.0];
    [UIView animateWithDuration:0.3 animations:^{
        [achievementViewController.view setAlpha:1.0];
    }];
    return achievementViewController;
}

- (IBAction)closeButtonDidClicked:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.view setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

@end
