//
//  UIViewAdditions.h
//  Omiai
//
//  Created by Shawn Xu on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (UIViewAdditions)

@property(nonatomic) CGFloat left;
@property(nonatomic) CGFloat right;
@property(nonatomic) CGFloat top;
@property(nonatomic) CGFloat bottom;
@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;

- (void) circularBeadWithRadius:(float)radius;
+ (void)animationFadeIn:(UIView *)inView fadeOut:(UIView *)outView;
- (CGFloat)bottomCaseHeightZero;

@end
