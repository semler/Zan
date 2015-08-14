//
//  SettingChangeCell.m
//  Overtime
//
//  Created by Xu Shawn on 3/26/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "SettingChangeCell.h"

@implementation SettingChangeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [self.textLabel setFont:[UIFont systemFontOfSize:14.0]];
        [self.textLabel setTextColor:[UIColor whiteColor]];
        
        [self.detailTextLabel setTextAlignment:NSTextAlignmentRight];
        [self.detailTextLabel setFont:[UIFont systemFontOfSize:14.0]];
        [self.detailTextLabel setTextColor:[UIColor whiteColor]];
        
        UIImage *highlightedImage = [UIImage imageNamed:@"setting_cell_selected"];
        self.highlightedImageView = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(highlightedImage, 10.0, 0)];
        [self.highlightedImageView setImage:highlightedImage];
        [self.highlightedImageView setHidden:YES];
        [self addSubview:self.highlightedImageView];
        
        UIImage *switchImage = [UIImage imageNamed:@"switch_off"];
        self.switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.switchButton setFrame:CGRectOffsetFromImage(switchImage, 235.0, 10.0)];
        [self.switchButton setImage:switchImage forState:UIControlStateNormal];
        [self.switchButton addTarget:self action:@selector(switchButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.switchButton setHidden:YES];
        [self addSubview:self.switchButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIImage *image = self.imageView.image;
    if (IOS7_OR_LATER) {
        [self.imageView setFrame:CGRectMake(10.0, 0, image.size.width, image.size.height)];
    } else {
        [self.imageView setFrame:CGRectMake(0.0, 0, image.size.width, image.size.height)];
    }
    [self.textLabel setFrame:CGRectMake(20.0, 0, 160.0, 51.0)];
    [self.detailTextLabel setFrame:CGRectMake(140.0, 0, 145.0, 51.0)];
    
    [self.contentView bringSubviewToFront:self.textLabel];
    [self.contentView bringSubviewToFront:self.detailTextLabel];
}

- (void)prepareForReuse
{
    [self.textLabel setText:@""];
    [self.detailTextLabel setText:@""];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    [self.highlightedImageView setHidden:!highlighted];
}

- (void)setSwitchOn:(BOOL)switchOn
{
    _switchOn = switchOn;
    
    UIImage *switchImage = nil;
    if (switchOn) {
        switchImage = [UIImage imageNamed:@"switch_on"];
    } else {
        switchImage = [UIImage imageNamed:@"switch_off"];
    }
    [self.switchButton setImage:switchImage forState:UIControlStateNormal];
}

- (NSString *)switchOnString
{
    return self.switchOn ? @"1" : @"0";
}

- (NSString *)switchOnGAString
{
    NSString *dateString = [[NSDate date] localStringWithFormat:DB_DATE_YMDHMS];
    if (self.switchOn) {
        return [NSString stringWithFormat:@"ON %@", dateString];
    } else {
        return [NSString stringWithFormat:@"OFF %@", dateString];
    }
}

- (void)switchButtonDidClicked:(UIButton *)button
{
    [self setSwitchOn:!(self.switchOn)];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(settingChangeCell:switchDidClicked:)]) {
        [self.delegate settingChangeCell:self switchDidClicked:self.switchOn];
    }
}

@end
