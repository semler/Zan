//
//  DaysView.m
//  Overtime
//
//  Created by xuxiaoteng on 2/25/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import "DaysView.h"

@implementation DaysView

- (void)setDays:(NSInteger)days
{
    _days = days;
    
    for (id view in self.subviews) {
        [view removeFromSuperview];
    }
    
    NSString *daysString = [NSString stringWithFormat:@"%d", (int)days];
    
    CGFloat x = self.width;
    NSInteger count = 0;
    CGFloat ratio = 1.0;
    
    for (NSInteger i = (daysString.length - 1); i >= 0; i--) {
        NSString *imageName = [NSString stringWithFormat:@"achieve_%c", [daysString characterAtIndex:i]];
        UIImage *image = [UIImage imageNamed:imageName];
        
        if (image.size.height > self.height) {
            ratio = self.height / image.size.height;
        }
        x -= image.size.width * ratio;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, image.size.width * ratio, image.size.height * ratio)];
        [imageView setImage:image];
        [self addSubview:imageView];
        
        count++;
    }
}

@end
