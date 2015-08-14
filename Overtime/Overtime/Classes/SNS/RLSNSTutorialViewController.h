//
//  RLSNSTuturialViewController.h
//  Overtime
//
//  Created by Ryuukou on 21/1/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SNSSelf;
@interface RLSNSTutorialViewController : UIViewController

@property (nonatomic, weak) UIViewController *homeVC;
@property (nonatomic, strong) SNSSelf *myProfile;

- (instancetype)initWithTutorial:(BOOL)tutorial;

@end
