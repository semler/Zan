//
//  SettingCell.m
//  Overtime
//
//  Created by Xu Shawn on 3/26/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "SettingCell.h"

@implementation SettingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 5.0, 260.0, 42.0)];
        [self.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
        [self.titleLabel setTextColor:[UIColor whiteColor]];
        [self addSubview:self.titleLabel];
        
        
        self.detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(140.0, 0, 145.0, 51.0)];
        [self.detailLabel setTextAlignment:NSTextAlignmentRight];
        [self.detailLabel setFont:[UIFont systemFontOfSize:14.0]];
        [self.detailLabel setTextColor:[UIColor whiteColor]];
        [self addSubview:self.detailLabel];
        
        UIImage *highlightedImage = [UIImage imageNamed:@"setting_cell_selected"];
        self.highlightedImageView = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(highlightedImage, 10.0, 0)];
        [self.highlightedImageView setImage:highlightedImage];
        [self.highlightedImageView setHidden:YES];
        [self addSubview:self.highlightedImageView];
        
        UIImage *kyaraNewImage = [UIImage imageNamed:@"btn_new"];
        self.kyaraNewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -2.0, kyaraNewImage.size.width, kyaraNewImage.size.height)];
        [self.kyaraNewImageView setImage:kyaraNewImage];
        [self.kyaraNewImageView setHidden:YES];
        [self addSubview:self.kyaraNewImageView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIImage *image = self.imageView.image;
    [self.imageView setFrame:CGRectMake(10.0, 0, image.size.width, image.size.height)];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.kyaraNewImageView setHidden:YES];
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

@end
