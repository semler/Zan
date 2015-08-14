//
//  TutorialCalcViewController.h
//  Overtime
//
//  Created by xuxiaoteng on 12/25/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "BaseViewController.h"

@class TutorialCalcViewController;

@protocol TutorialCalcViewControllerDelegate <NSObject>

- (void)tutorialCalcViewController:(TutorialCalcViewController *)tutorialCalcViewController calculateDidFinished:(double)money;

@end

@interface TutorialCalcViewController : BaseViewController

@property (nonatomic, weak) id<TutorialCalcViewControllerDelegate> delegate;

@end
