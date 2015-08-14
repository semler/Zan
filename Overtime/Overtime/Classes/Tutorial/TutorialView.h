//
//  TutorialView.h
//  Overtime
//
//  Created by Xu Shawn on 1/23/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CustomPageControl.h"
#import "TutorialCalcViewController.h"
#import "MoneyView.h"

typedef enum {
    TutorialTypeSetting,
    TutorialTypeHome,
    TutorialTypeChart,
    TutorialTypeDetail
} TutorialType;

@interface TutorialView : UIView <UIScrollViewDelegate, TutorialCalcViewControllerDelegate>

@property (nonatomic, assign) TutorialType tutorialType;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, assign) NSInteger pageCount;
@property (nonatomic, strong) CustomPageControl *pageControl;
@property (nonatomic, strong) UIImageView *pageControlBg;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) MPMoviePlayerController *moviewPlayerController;
@property (nonatomic, strong) TutorialCalcViewController *tutorialCalcViewController;
@property (nonatomic, strong) MoneyView *moneyView;

- (id)initWithFrame:(CGRect)frame tutorialType:(TutorialType)tutorialType;
+ (TutorialView *)showWithTutorialType:(TutorialType)tutorialType;
+ (TutorialView *)showInView:(UIView *)view tutorialType:(TutorialType)tutorialType;
- (void)updateButtonStatus;

@end
