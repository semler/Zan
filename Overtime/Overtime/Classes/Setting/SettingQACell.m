//
//  SettingQACell.m
//  Overtime
//
//  Created by Sean on 4/23/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "SettingQACell.h"

@implementation SettingQACell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [self.textLabel setFont:[UIFont systemFontOfSize:14.0]];
        [self.textLabel setTextColor:[UIColor whiteColor]];
        [self.textLabel setNumberOfLines:0];
        
        [self.detailTextLabel setFont:[UIFont systemFontOfSize:14.0]];
        [self.detailTextLabel setTextColor:[UIColor whiteColor]];
        [self.detailTextLabel setNumberOfLines:0];
        
        UIImage *plusImage = [UIImage imageNamed:@"setting_qa_plus"];
        self.detailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.detailButton setFrame:CGRectOffsetFromImage(plusImage, 285.0, 15.0)];
        [self.detailButton setImage:plusImage forState:UIControlStateNormal];
        [self.detailButton addTarget:self action:@selector(detailButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.detailButton];
        
        UIImage *detailImage = [UIImage imageNamed:@"setting_qa_cell_bg3"];
        self.detailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11.0, 51.0, 299.0, 54.0)];
        [self.detailImageView setImage:detailImage];
        [self.contentView addSubview:self.detailImageView];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat titleHeight = 0;
    CGSize titleSize = [self.textLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(270.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    
    titleHeight = titleSize.height + 20.0;
    
    if (titleHeight < 51.0) {
        titleHeight = 51.0;
    }
    
    UIImage *image = self.imageView.image;
    [self.imageView setFrame:CGRectMake(11.0, 0, image.size.width - 1.0, titleHeight)];
    [self.textLabel setFrame:CGRectMake(15.0, 0, 270.0, titleHeight)];
    
    CGSize detailSize = [self.detailTextLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(290.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat detailHeight = detailSize.height + 20.0;
    
    [self.detailImageView setFrame:CGRectMake(self.detailImageView.left, titleHeight, self.detailImageView.width, detailHeight)];
    [self.detailTextLabel setFrame:CGRectMake(15.0, titleHeight, 290.0, detailHeight)];
    
    [self.contentView bringSubviewToFront:self.detailButton];
    [self.contentView bringSubviewToFront:self.textLabel];
    [self.contentView bringSubviewToFront:self.detailTextLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)detailButtonDidClicked:(UIButton *)button
{
    
}

@end
