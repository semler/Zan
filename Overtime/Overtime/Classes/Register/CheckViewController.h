//
//  CheckViewController.h
//  Overtime
//
//  Created by Xu Shawn on 3/6/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "BaseViewController.h"

@interface CheckViewController : BaseViewController

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic, strong) IBOutlet UILabel *locationLabel;
@property (nonatomic, strong) IBOutlet UILabel *rest1Label;
@property (nonatomic, strong) IBOutlet UILabel *rest2Label;
@property (nonatomic, strong) IBOutlet UILabel *holidayLabel;
@property (nonatomic, strong) IBOutlet UILabel *paymentLabel;

@end
