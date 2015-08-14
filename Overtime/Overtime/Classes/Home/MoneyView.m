//
//  MoneyView.m
//  Overtime
//
//  Created by Xu Shawn on 2/18/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "MoneyView.h"

@implementation MoneyView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setBackgroundColor:[UIColor clearColor]];
    [self setClipsToBounds:YES];
}

- (void)setMoney:(NSInteger)money withThemeType:(ThemeType)themeType
{
    [self setMoney:money];
    [self setThemeType:themeType];
    
    for (id view in self.subviews) {
        [view removeFromSuperview];
    }
    
    NSString *moneyString = [NSString stringWithFormat:@"%ld", (long)money];
    
    CGFloat x = self.width;
    NSInteger count = 0;
    CGFloat ratio = 1.0;
    
    for (NSInteger i = (moneyString.length - 1); i >= 0; i--) {
        NSString *number = [NSString stringWithFormat:@"%c", [moneyString characterAtIndex:i]];
        UIImage *image = [UIImage imageNamed:number themeType:themeType];
        
        if (image.size.height > self.height) {
            ratio = self.height / image.size.height;
        }
        x -= image.size.width * ratio;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, image.size.width * ratio, image.size.height * ratio)];
        [imageView setImage:image];
        [self addSubview:imageView];
        
        count++;
        
        if (count % 3 == 0 && count != moneyString.length) {
            UIImage *comaImage = [UIImage imageNamed:@"coma" themeType:themeType];
            x -= comaImage.size.width * ratio;
            UIImageView *comaImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, comaImage.size.width * ratio, comaImage.size.height * ratio)];
            [comaImageView setImage:comaImage];
            [self addSubview:comaImageView];
        }
    }
    
    UIImage *symbolImage = [UIImage imageNamed:@"symbol" themeType:themeType];
    x -= symbolImage.size.width * ratio;
    UIImageView *symbolImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, symbolImage.size.width * ratio, symbolImage.size.height * ratio)];
    [symbolImageView setImage:symbolImage];
    [self addSubview:symbolImageView];
}

@end
