//
//  TutorialView.m
//  Overtime
//
//  Created by Xu Shawn on 1/23/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "TutorialView.h"
#import <AVFoundation/AVFoundation.h>

#define ANIM_IMAGEVIEW1 @"ANIM_IMAGEVIEW1"
#define ANIM_IMAGEVIEW2 @"ANIM_IMAGEVIEW2"

@implementation TutorialView

- (id)initWithFrame:(CGRect)frame tutorialType:(TutorialType)tutorialType
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setTutorialType:tutorialType];
        [self setBackgroundColor:[UIColor clearColor]];
        [self addContentView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addContentView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    [self.scrollView setPagingEnabled:YES];
    [self.scrollView setDelegate:self];
    [self.scrollView setKeyboardDismissMode:UIScrollViewKeyboardDismissModeOnDrag];
    [self addSubview:self.scrollView];
    
    switch (self.tutorialType) {
        case TutorialTypeSetting: {
            [self addImageWithBaseName:@"tutorial_setting" endIndex:5];
            [self.scrollView setContentSize:CGSizeMake(self.scrollView.width * 3, 0)];
            break;
        }
        case TutorialTypeHome: {
            [self addImageWithBaseName:@"tutorial_home" endIndex:6];
            break;
        }
        case TutorialTypeChart: {
            [self addImageWithBaseName:@"tutorial_graph" endIndex:1];
            break;
        }
        case TutorialTypeDetail: {
            [self addImageWithBaseName:@"tutorial_detail" endIndex:1];
            break;
        }
        default:
            break;
    }
    
    if (self.pageCount > 1) {
        UIImage *leftImage = [UIImage imageNamed:@"tutorial_left"];
        UIImage *leftImageOff = [UIImage imageNamed:@"tutorial_left_off"];
        self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.leftButton setFrame:CGRectOffsetFromImage(leftImage, 8.0, (self.height - leftImage.size.height) / 2)];
        [self.leftButton setImage:leftImage forState:UIControlStateNormal];
        [self.leftButton setImage:leftImageOff forState:UIControlStateHighlighted];
        [self.leftButton addTarget:self action:@selector(leftButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.leftButton];
        
        UIImage *rightImage = [UIImage imageNamed:@"tutorial_right"];
        UIImage *rightImageOff = [UIImage imageNamed:@"tutorial_right_off"];
        self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.rightButton setFrame:CGRectOffsetFromImage(rightImage, self.width - 8.0 - rightImage.size.width, (self.height - rightImage.size.height) / 2)];
        [self.rightButton setImage:rightImage forState:UIControlStateNormal];
        [self.rightButton setImage:rightImageOff forState:UIControlStateHighlighted];
        [self.rightButton addTarget:self action:@selector(rightButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.rightButton];
        
        [self.leftButton setHighlighted:YES];
        [self.leftButton setEnabled:NO];
        
        UIImage *pageBgImage = [UIImage imageNamed:@"pagecontrol_bg"];
        self.pageControlBg = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(pageBgImage, (self.width - pageBgImage.size.width) / 2, self.height - 45.0)];
        [self.pageControlBg setImage:pageBgImage];
        [self addSubview:self.pageControlBg];
        
        self.pageControl = [[CustomPageControl alloc] initWithFrame:self.pageControlBg.bounds];
        if (self.tutorialType == TutorialTypeSetting) {
            [self.pageControl setNumberOfPages:self.pageCount + 1];
        } else {
            [self.pageControl setNumberOfPages:self.pageCount];
        }
        [self.pageControl setCurrentPage:0];
        [self.pageControlBg addSubview:self.pageControl];
    }
}

- (void)handleEnterForegroundNotification:(NSNotification *)notification
{
    [self.moviewPlayerController play];
//    [self.scrollView removeFromSuperview];
//    [self addContentView];
}

- (void)leftButtonDidClicked:(UIButton *)button
{
    CGFloat offsetX = self.scrollView.contentOffset.x;
    if (offsetX >= 320.0) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.scrollView setContentOffset:CGPointMake(offsetX - 320.0, 0)];
        } completion:^(BOOL finished) {
            [self updateButtonStatus];
            NSInteger pageNo = floor((self.scrollView.contentOffset.x - self.scrollView.width / 2) / self.scrollView.width) + 1;
            [self.pageControl setCurrentPage:pageNo];
        }];
    }
}

- (void)rightButtonDidClicked:(UIButton *)button
{
    CGFloat offsetX = self.scrollView.contentOffset.x;
    if (offsetX < self.scrollView.width * (self.pageCount - 1)) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.scrollView setContentOffset:CGPointMake(offsetX + 320.0, 0)];
        } completion:^(BOOL finished) {
            // To do
            [self.leftButton setHidden:NO];
            [self.rightButton setHidden:NO];
            if (!IS_RETINA4) {
                [self.pageControlBg setHidden:NO];
            }
            [self updateButtonStatus];
            NSInteger pageNo = floor((self.scrollView.contentOffset.x - self.scrollView.width / 2) / self.scrollView.width) + 1;
            [self.pageControl setCurrentPage:pageNo];
        }];
    } else {
        if (self.tutorialType == TutorialTypeSetting) {
            [self hide];
        }
    }
}

- (void)updateButtonStatus
{
    if (self.scrollView.contentOffset.x <= 0) {
        [self.leftButton setHighlighted:YES];
        [self.leftButton setEnabled:NO];
    } else {
        [self.leftButton setHighlighted:NO];
        [self.leftButton setEnabled:YES];
    }
    if (self.scrollView.contentOffset.x + self.scrollView.width >= self.scrollView.contentSize.width) {
        [self.rightButton setHighlighted:YES];
        [self.rightButton setEnabled:NO];
    } else {
        [self.rightButton setHighlighted:NO];
        [self.rightButton setEnabled:YES];
    }
    if (self.tutorialType == TutorialTypeSetting) {
        [self.rightButton setHighlighted:NO];
        [self.rightButton setEnabled:YES];
    }
}

- (void)addImageWithBaseName:(NSString *)baseName endIndex:(NSInteger)endIndex
{
    [self addImageWithBaseName:baseName fromIndex:1 endIndex:endIndex];
}

- (void)didMoveToSuperview
{
    [self.moviewPlayerController setRepeatMode:MPMovieRepeatModeOne];
}

- (void)addImageWithBaseName:(NSString *)baseName fromIndex:(NSInteger)fromIndex endIndex:(NSInteger)endIndex
{
    [self setPageCount:endIndex - fromIndex + 1];
    CGFloat offsetX = 0;
    for (NSInteger i = fromIndex; i <= endIndex; i++) {
        NSString *imageName = [baseName stringByAppendingFormat:@"%ld", (long)i];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX, 0, self.scrollView.width, self.scrollView.height)];
        [imageView setImage:[UIImage imageNamed:imageName]];
        [imageView setContentMode:UIViewContentModeCenter];
        [self.scrollView addSubview:imageView];
        
        if (self.tutorialType == TutorialTypeSetting) {
            if (i == 3) {
                self.tutorialCalcViewController = [[TutorialCalcViewController alloc] init];
                [self.tutorialCalcViewController.view setFrame:imageView.frame];
                [self.tutorialCalcViewController setDelegate:self];
                [self.scrollView addSubview:self.tutorialCalcViewController.view];
            } else if (i == 4) {
                self.moneyView = [[MoneyView alloc] initWithFrame:CGRectMake(40.0, IS_RETINA4 ? 207.0 : 162.0, 200.0, 32.0)];
                [self.moneyView setMoney:0 withThemeType:ThemeTypeBlue];
                self.moneyView.clipsToBounds = YES;
                [imageView addSubview:self.moneyView];
            } else if (i == endIndex) {
                NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tutorial_setting" ofType:@"mp4"]];
                self.moviewPlayerController = [[MPMoviePlayerController alloc] initWithContentURL:fileURL];
                [self.moviewPlayerController.view setFrame:CGRectMake(34.0, 119.0, 255.0, 247.0)];
                [self.moviewPlayerController setShouldAutoplay:YES];
                [self.moviewPlayerController setControlStyle:MPMovieControlStyleNone];
                [self.moviewPlayerController setRepeatMode:MPMovieRepeatModeOne];
                [self.moviewPlayerController prepareToPlay];
                [self.moviewPlayerController play];
                [imageView addSubview:self.moviewPlayerController.view];
                
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
                
                
//                UIImage *closeImage = [UIImage imageNamed:@"tutorial_legal_button"];
//                UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//                [closeButton setFrame:CGRectOffsetFromImage(closeImage, imageView.width - closeImage.size.width - 5.0, imageView.height - closeImage.size.height - 5.0)];
//                [closeButton setImage:closeImage forState:UIControlStateNormal];
//                [closeButton addTarget:self action:@selector(closeButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
//                [imageView addSubview:closeButton];
//                [imageView setUserInteractionEnabled:YES];

//                UIImage *pOnImage = [UIImage imageNamed:@"tutorial_setting1_p_on"];
//                UIImageView *pOnImageView = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(pOnImage, 38.0 - pOnImage.size.width / 2, 175.0 - pOnImage.size.height)];
//                [pOnImageView setImage:pOnImage];
//                [imageView addSubview:pOnImageView];
                
//                CGMutablePathRef path = CGPathCreateMutable();
//                CGPathMoveToPoint(path, NULL, pOnImageView.center.x, pOnImageView.center.y);
//                CGPathAddLineToPoint(path, NULL, 182.0, 270.0 - pOnImage.size.height / 2.0);
//                CGPathAddLineToPoint(path, NULL, pOnImageView.center.x, pOnImageView.center.y);
//                CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
//                [animation setDelegate:self];
//                [animation setPath:path];
//                [animation setDuration:2];
//                [animation setRepeatCount:HUGE_VALF];
//                CFRelease(path);
//                
//                [pOnImageView.layer addAnimation:animation forKey:@"Move"];
                
//                [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
//                    [pOnImageView setFrame:CGRectMake(182.0 - pOnImage.size.width / 2, 270.0 - pOnImage.size.height, pOnImageView.width, pOnImageView.height)];
//                } completion:^(BOOL finished) {
//                    [self.timer invalidate];
//                }];
//
//                self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(handleTimer:) userInfo:@{ANIM_IMAGEVIEW1: imageView, ANIM_IMAGEVIEW2: pOnImageView} repeats:YES];
                
            }
        }
        if (self.tutorialType != TutorialTypeSetting) {
            BOOL showCloseButton = NO;
            if ([[NSUserDefaults standardUserDefaults] boolForKey:TutorialRedisplay]) {
                showCloseButton = YES;
            } else {
                if (i == endIndex) {
                    showCloseButton = YES;
                }
            }
            if (showCloseButton) {
                UIImage *closeImage = [UIImage imageNamed:@"tutorial_close_button"];
                UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
                
                if (i == 2 && self.tutorialType == TutorialTypeHome) {
                    [closeButton setFrame:CGRectOffsetFromImage(closeImage, imageView.width - closeImage.size.width - 5.0, 25.0)];
                } else {
                    [closeButton setFrame:CGRectOffsetFromImage(closeImage, imageView.width - closeImage.size.width - 5.0, imageView.height - closeImage.size.height - 5.0)];
                }
                [closeButton setImage:closeImage forState:UIControlStateNormal];
                [closeButton addTarget:self action:@selector(closeButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
                [imageView addSubview:closeButton];
                [imageView setUserInteractionEnabled:YES];
            }
        }
        
        offsetX += self.scrollView.width;
    }
    [self.scrollView setContentSize:CGSizeMake(offsetX, 0)];
}

- (void)closeButtonDidClicked:(UIButton *)button
{
    [self hide];
}

- (void)hide
{
    [self.timer invalidate];

    [UIView transitionWithView:self duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self setHidden:YES];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (self.tutorialType == TutorialTypeSetting) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TutorialSettingDidFinishedNotification object:nil];
        } else if (self.tutorialType == TutorialTypeHome) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TutorialHomeDidFinishedNotification object:nil];
        }
    }];
}

+ (TutorialView *)showWithTutorialType:(TutorialType)tutorialType
{
    return [self showInView:[[UIApplication sharedApplication] windows][0] tutorialType:tutorialType];
}

+ (TutorialView *)showInView:(UIView *)view tutorialType:(TutorialType)tutorialType
{
    TutorialView *tutorialView = [[TutorialView alloc] initWithFrame:view.bounds tutorialType:tutorialType];
    [view addSubview:tutorialView];
    return tutorialView;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.tutorialType == TutorialTypeSetting) {
        if (self.pageControl.currentPage == self.pageCount - 1) {
            if (scrollView.contentOffset.x > scrollView.width * self.pageCount - 290.0) {
                [self performSelector:@selector(hide) withObject:nil afterDelay:0.3];
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.pageCount > 1) {
        NSInteger pageNo = floor((scrollView.contentOffset.x - scrollView.width / 2) / scrollView.width) + 1;
        [self.pageControl setCurrentPage:pageNo];
        
        if (self.tutorialType == TutorialTypeHome) {
            if (pageNo == 1) {
                [self.pageControlBg setTop:40.0];
            } else {
                [self.pageControlBg setTop:self.height - 45.0];
            }
        } else if (self.tutorialType == TutorialTypeSetting) {
            if (pageNo == 2) {
                [self.leftButton setHidden:YES];
                [self.rightButton setHidden:YES];
                if (!IS_RETINA4) {
                    [self.pageControlBg setHidden:YES];
                }
            } else {
                [self.leftButton setHidden:NO];
                [self.rightButton setHidden:NO];
                if (!IS_RETINA4) {
                    [self.pageControlBg setHidden:NO];
                }
            }
        }
        [self updateButtonStatus];
    }
}

#pragma mark - NSTimer

- (void)handleTimer:(NSTimer *)timer
{
    NSDictionary *userInfo = [timer userInfo];
    UIImageView *imageView1 = userInfo[ANIM_IMAGEVIEW1];
    UIImageView *imageView2 = userInfo[ANIM_IMAGEVIEW2];
    
    static BOOL onoff = NO;
    if (onoff) {
        onoff = NO;
        [imageView1 setImage:[UIImage imageNamed:@"tutorial_setting1"]];
        [imageView2 setImage:[UIImage imageNamed:@"tutorial_setting1_p_on"]];
    } else {
        onoff = YES;
        [imageView1 setImage:[UIImage imageNamed:@"tutorial_setting1_off"]];
        [imageView2 setImage:[UIImage imageNamed:@"tutorial_setting1_p_off"]];
    }
}

#pragma mark - 

- (void)tutorialCalcViewController:(TutorialCalcViewController *)tutorialCalcViewController calculateDidFinished:(double)money
{
    [self rightButtonDidClicked:nil];
    [self.moneyView setMoney:money withThemeType:ThemeTypeBlue];
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.width * 5, self.scrollView.height)];
}

@end
