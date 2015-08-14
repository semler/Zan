//
//  HolidayCell.m
//  Overtime
//
//  Created by Xu Shawn on 3/20/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "HolidayCell.h"

@implementation HolidayCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        UIImage *selectedImage = [UIImage imageNamed:@"holiday_week_selected"];
        self.selectedImageView = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(selectedImage, 10.0, 0)];
        [self.selectedImageView setImage:selectedImage];
        [self.selectedImageView setHidden:YES];
        [self addSubview:self.selectedImageView];
        
        UIImage *checkedImage = [UIImage imageNamed:@"holiday_checked"];
        UIImageView *checkedImageView = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(checkedImage, 260.0, (self.selectedImageView.height - checkedImage.size.height) / 2)];
        [checkedImageView setImage:checkedImage];
        [self.selectedImageView addSubview:checkedImageView];
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

    [self.imageView setLeft:10.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    [self.selectedImageView setHidden:!selected];
}

@end
