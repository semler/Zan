//
//  AnimLabel.m
//  AnimLabel.h
//
//  Created by Shawn Xu on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AnimLabel.h"
#import "UIViewAdditions.h"

@implementation AnimLabel {
    UILabel *label;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(self.width, 0.0, self.width, self.height)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont boldSystemFontOfSize:13.0]];
        [label setTextColor:[UIColor whiteColor]];
        [self addSubview:label];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.layer removeAllAnimations];
    
    CGFloat seconds = 3 * (label.width / 100);
    [UIView setAnimationRepeatAutoreverses:YES];
    [UIView animateWithDuration:seconds delay:0 options:UIViewAnimationOptionRepeat animations:^{
        label.right = 0.0;
    } completion:^(BOOL finished) {

    }];
}

- (void)setText:(NSString *)value
{
    _text = value;
    
    label.text = _text;
    
    CGRect rect = label.frame;
    [label sizeToFit];
    CGFloat width = label.width;
    rect.origin.x = self.width;
    rect.size.width = width;
    label.frame = rect;
}

@end
