//
//  DetailViewController.h
//  Overtime
//
//  Created by Xu Shawn on 2/24/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "BaseViewController.h"
#import "MoneyView.h"

@class DetailViewController;

typedef NS_ENUM(NSInteger, DetailShowType) {
    DetailShowTypeDefault,
    DetailShowTypeChart,
    DetailShowTypeStart,
    DetailShowTypeEnd
};

@protocol DetailViewControllerDelegate <NSObject>

- (void)forwardToHomeViewFromDetailView:(DetailViewController *)detailViewController;

@end

@interface DetailViewController : BaseViewController

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UIButton *previousButton;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;
@property (nonatomic, weak) id<DetailViewControllerDelegate> delegate;
@property (nonatomic, assign) DetailShowType detailShowType;
@property (nonatomic, strong) NSDate *selectedDate;

@end
