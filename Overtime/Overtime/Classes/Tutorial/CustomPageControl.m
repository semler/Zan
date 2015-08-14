//
//  CustomPageControl.m
//  Overtime
//
//  Created by Xu Shawn on 3/27/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "CustomPageControl.h"

@implementation CustomPageControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        activeImage = [UIImage imageNamed:@"dot_active"];
        inActiveImage = [UIImage imageNamed:@"dot_inactive"];
    }
    return self;
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    [super setCurrentPage:currentPage];
    [self updateDots];
}

- (void)updateDots
{
    for (int i = 0; i < [self.subviews count]; i++) {
        UIImageView * dot = [self imageViewForSubview:[self.subviews objectAtIndex:i]];
        if (i == self.currentPage) {
            dot.image = activeImage;
            dot.frame = CGRectOffsetFromImage(activeImage, -3, -3);
        } else {
            dot.image = inActiveImage;
            dot.frame = CGRectOffsetFromImage(inActiveImage, -3, -3);
        }
    }
}

- (UIImageView *)imageViewForSubview:(UIView *)view
{
    UIImageView * dot = nil;
    
    if ([view isKindOfClass:[UIView class]]) {
        for (UIView *subview in view.subviews) {
            if ([subview isKindOfClass:[UIImageView class]]) {
                dot = (UIImageView *)subview;
                break;
            }
        }
        if (dot == nil) {
            dot = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, view.frame.size.width, view.frame.size.height)];
            [view addSubview:dot];
        }
    } else {
        dot = (UIImageView *) view;
    }
    
    return dot;
}

@end
