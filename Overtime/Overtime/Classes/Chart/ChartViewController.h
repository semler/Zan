//
//  ChartViewController.h
//  Overtime
//
//  Created by Xu Shawn on 2/24/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "BaseViewController.h"
#import "MoneyView.h"

typedef NS_ENUM(NSInteger, ChartType) {
    ChartTypeDaily,
    ChartTypeMonthly
};

@class ChartViewController;

@protocol ChartViewControllerDelegate <NSObject>

- (void)forwardToHomeViewFromChartView:(ChartViewController *)chartViewController;
- (void)chartViewController:(ChartViewController *)chartViewController forwardToDetailViewOnDate:(NSDate *)date;

@end

@interface ChartViewController : BaseViewController

@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, weak) id<ChartViewControllerDelegate> delegate;
@property (nonatomic, assign) ChartType chartType;

- (void)reloadData;
- (void)resetDate;

@end
