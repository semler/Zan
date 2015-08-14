//
//  LegalCell.m
//  Overtime
//
//  Created by xuxiaoteng on 2/1/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import "LegalCell.h"

@implementation LegalCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.lineImageView setHidden:NO];
}

@end
