//
//  SettingChangeCell.h
//  Overtime
//
//  Created by Xu Shawn on 3/26/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingChangeCell;

@protocol SettingChangeCellDelegate <NSObject>

- (void)settingChangeCell:(SettingChangeCell *)cell switchDidClicked:(BOOL)switchOn;

@end

@interface SettingChangeCell : UITableViewCell

@property (nonatomic, strong) UIImageView *highlightedImageView;
@property (nonatomic, strong) UIButton *switchButton;
@property (nonatomic, assign) BOOL switchOn;
@property (nonatomic, weak) id<SettingChangeCellDelegate> delegate;

- (NSString *)switchOnString;
- (NSString *)switchOnGAString;

@end
