//
//  TopicsCell.m
//  Overtime
//
//  Created by 于　超 on 2015/07/28.
//  Copyright (c) 2015年 Bravesoft. All rights reserved.
//

#import "TopicsListCell.h"
#import "UIImageView+WebCache.h"

@interface TopicsListCell () {
    UIImageView *bg;
    UIImageView *imageview;
    UILabel *title;
    UIImageView *clock;
    UILabel *time;
    UIImageView *line;
}
@end

@implementation TopicsListCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    bg = [[UIImageView alloc] initWithFrame:CGRectMake(-1, 0, 302, 80)];
    [self.contentView addSubview:bg];
    imageview = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 50, 50)];
    [self.contentView addSubview:imageview];
    title = [[UILabel alloc] initWithFrame:CGRectMake(70, 15, 220, 38)];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setTextColor:[UIColor whiteColor]];
    [title setFont:[UIFont boldSystemFontOfSize:14.0]];
    [title setNumberOfLines:2];
    [self.contentView addSubview:title];
    clock = [[UIImageView alloc] initWithFrame:CGRectMake(70, 53, 12, 12)];
    clock.image = [UIImage imageNamed:@"clock"];
    [self.contentView addSubview:clock];
    time = [[UILabel alloc] initWithFrame:CGRectMake(85, 53, 205, 12)];
    [time setBackgroundColor:[UIColor clearColor]];
    [time setTextColor:[UIColor whiteColor]];
    [time setFont:[UIFont systemFontOfSize:10.0]];
    [time setNumberOfLines:1];
    [self.contentView addSubview:time];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    if (IOS8_OR_LATER) {
        self.layoutMargins = UIEdgeInsetsZero;
        self.separatorInset = UIEdgeInsetsZero;
    } else {
        self.separatorInset = UIEdgeInsetsZero;
    }
    
    return self;
}

- (void) initFrame {
    if (self) {
        if (_index == 0) {
            bg.image = [UIImage imageNamed:@"cellTopBg"];
        } else {
            bg.image = [UIImage imageNamed:@"cellBg"];
        }
        
        [imageview sd_setImageWithURL:[NSURL URLWithString:_data.thumbnail] placeholderImage:[UIImage imageNamed:@"imageBack"] options:SDWebImageDelayPlaceholder];
        title.text = _data.title;
        NSString *date = [_data.pub_date stringByReplacingOccurrencesOfString:@"-" withString:@"."];
        time.text = date;
    }
}

-(void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted) {
        if (self.selectionStyle != UITableViewCellSelectionStyleNone) {
            self.backgroundColor = [UIColor clearColor]; //選択状態の色をセット
        }
    } else {
        self.backgroundColor = [UIColor clearColor];  //非選択状態の色をセット
    }
}

@end
