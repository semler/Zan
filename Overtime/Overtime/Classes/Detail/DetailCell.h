//
//  DetailCell.h
//  Overtime
//
//  Created by Sean on 3/6/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DETAIL_PLACEHOLDER @"メモ"

@class DetailCell;

@protocol DetailCellDelegate <NSObject>

- (void)detailCell:(DetailCell *)detailCell startButtonDidClicked:(UIButton *)button;
- (void)detailCell:(DetailCell *)detailCell endButtonDidClicked:(UIButton *)button;
- (void)detailCell:(DetailCell *)detailCell memoInputDidStart:(NSString *)text;
//- (void)detailCell:(DetailCell *)detailCell memoInputDidFinished:(NSString *)memo;
- (void)detailCell:(DetailCell *)detailCell memoButtonDidClicked:(UIButton *)button;

@end

@interface DetailCell : UITableViewCell <UITextViewDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *bgImageView;
@property (nonatomic ,strong) IBOutlet UILabel *dayLabel;
@property (nonatomic ,strong) IBOutlet UILabel *weekLabel;
@property (nonatomic, strong) IBOutlet UIButton *startButton;
@property (nonatomic, strong) IBOutlet UIButton *endButton;
@property (nonatomic, strong) IBOutlet UILabel *startLabel;
@property (nonatomic, strong) IBOutlet UILabel *endLabel;
@property (nonatomic, strong) IBOutlet UIView *memoView;
@property (nonatomic, strong) IBOutlet UIButton *memoIcon;
@property (nonatomic, strong) IBOutlet UIImageView *startIcon;
@property (nonatomic, strong) IBOutlet UIImageView *endIcon;
@property (nonatomic, strong) IBOutlet UIImageView *memoBgImageView;
@property (nonatomic, strong) IBOutlet UITextView *memoTextView;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) Day *day;
@property (nonatomic, weak) id<DetailCellDelegate> delegate;

- (void)setStartTime:(NSString *)timeString;
- (void)setEndTime:(NSString *)timeString;
- (void)setEditable:(BOOL)editable;
- (void)setMemoText:(NSString *)text;

@end
