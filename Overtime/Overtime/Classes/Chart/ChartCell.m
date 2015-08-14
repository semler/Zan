//
//  ChartCell.m
//  Overtime
//
//  Created by Xu Shawn on 3/6/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "ChartCell.h"

#define MoneyPixelMaxWidth 238.0

@implementation ChartCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    UIImage *image = [UIImage imageNamed:@"chart_bg"];
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(71.0, 11.0, MoneyPixelMaxWidth, image.size.height)];
    [containerView setClipsToBounds:YES];
    [self addSubview:containerView];
    
    UIImage *resizedImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(8.0, 4.0, 8.0, 4.0) resizingMode:UIImageResizingModeStretch];
    self.chartImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, image.size.height)];
    [self.chartImageView setImage:resizedImage];
    [containerView addSubview:self.chartImageView];
    
    self.moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, self.chartImageView.height)];
    [self.moneyLabel setTextColor:[UIColor whiteColor]];
    [self.moneyLabel setBackgroundColor:[UIColor clearColor]];
    [self.moneyLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
    [containerView addSubview:self.moneyLabel];
}

- (void)prepareForReuse
{
    [self.moneyLabel setHidden:YES];
    [self.moneyLabel setText:@""];
}

- (void)setMoneyText:(NSString *)moneyText
{
    if (moneyText.length > 0) {
        CGSize textSize = [moneyText sizeWithFont:self.moneyLabel.font];
        [self.moneyLabel setWidth:textSize.width];
        [self.moneyLabel setText:moneyText];
        [self.moneyLabel setHidden:NO];
    } else {
        [self.moneyLabel setHidden:YES];
    }
}

- (void)startAnimation
{
    UIImage *image = nil;
    
    if (self.money < self.maxMoney) {
        image = [UIImage imageNamed:@"chart_bg"];
    } else {
        image = [UIImage imageNamed:@"chart_full_bg"];
    }
    UIImage *resizedImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(8.0, 4.0, 8.0, 4.0) resizingMode:UIImageResizingModeStretch];
    [self.chartImageView setImage:resizedImage];
    
    CGFloat width = MoneyPixelMaxWidth * self.money / self.maxMoney;
    if (width > 0) {
        if (width < 8) {
            width = 8;
        }
        if (width > MoneyPixelMaxWidth) {
            width = MoneyPixelMaxWidth;
        }
        [self.moneyLabel setAlpha:0];
        [self.chartImageView setFrame:CGRectMake(self.chartImageView.left, self.chartImageView.top, 0, self.chartImageView.height)];
        [UIView animateWithDuration:0.3 animations:^{
            [self.chartImageView setFrame:CGRectMake(self.chartImageView.left, self.chartImageView.top, width, self.chartImageView.height)];
        } completion:^(BOOL finished) {
            if (self.moneyLabel.width + 3.0 > width) {
                [self.moneyLabel setLeft:self.chartImageView.right];
            } else {
                [self.moneyLabel setRight:self.chartImageView.right - 3.0];
            }
            [UIView animateWithDuration:0.3 animations:^{
                [self.moneyLabel setAlpha:1.0];
            }];
        }];
    } else {
        [self.chartImageView setWidth:0];
        [self.moneyLabel setLeft:self.chartImageView.left];
    }
}

@end
