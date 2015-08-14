//
//  SettingQACell.h
//  Overtime
//
//  Created by Sean on 4/23/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingQACell;

@protocol SettingQACellDelegate <NSObject>

@end

@interface SettingQACell : UITableViewCell

@property (nonatomic, strong) UIImageView *highlightedImageView;
@property (nonatomic, strong) UIImageView *detailImageView;
@property (nonatomic, strong) UIButton *detailButton;
@property (nonatomic, weak) id<SettingQACellDelegate> delegate;

@end
