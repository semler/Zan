//
//  HomeViewController.h
//  Overtime
//
//  Created by Xu Shawn on 2/17/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "BaseViewController.h"
#import "DetailViewController.h"
#import "MoneyView.h"

typedef NS_ENUM(NSInteger, HomeType) {
    HomeTypeTotal,
    HomeTypeToday
};

@class HomeViewController;

@protocol HomeViewControllerDelegate <NSObject>

- (void)homeViewController:(HomeViewController *)homeViewController forwardToDetailViewWithShowType:(DetailShowType)detailShowType;
- (void)forwardToChartViewFromHomeView:(HomeViewController *)homeViewController;
- (void)forwardToHomeViewFromHomeView:(HomeViewController *)homeViewController;

@end

@interface HomeViewController : BaseViewController

@property (nonatomic, strong) IBOutlet UIImageView *bgImageView;
@property (nonatomic, strong) IBOutlet UIImageView *smallClockImageView;
@property (nonatomic, strong) IBOutlet UILabel *stateLabel;
@property (nonatomic, strong) IBOutlet UILabel *totalTimeLabel;
@property (nonatomic, strong) IBOutlet UIButton *startButton;
@property (nonatomic, strong) IBOutlet UIButton *endButton;
@property (nonatomic, assign) HomeType homeType;

@property (nonatomic, weak) id<HomeViewControllerDelegate> delegate;

- (void)reloadTotalTodayData;

@end
