//
//  DetailCell.m
//  Overtime
//
//  Created by Sean on 3/6/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "DetailCell.h"

@implementation DetailCell

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
    [self initializeControls];
    
//    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.textField.placeholder attributes:@{NSForegroundColorAttributeName: FONT_PLACEHOLDER}];
    
    UIImage *image = [UIImage imageNamed:@"detail_memo_bg"];
    UIImage *resizedImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(25.0, 100.0, 25.0, 100.0) resizingMode:UIImageResizingModeTile];
    [self.memoBgImageView setImage:resizedImage];
    
    [self.memoTextView setText:DETAIL_PLACEHOLDER];
    [self.memoTextView setTextColor:FONT_PLACEHOLDER];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self initializeControls];
}

- (void)initializeControls
{
    [self.startButton setHidden:NO];
    [self.startLabel setHidden:YES];
    [self.startLabel setText:@""];
    [self.endButton setHidden:NO];
    [self.endLabel setHidden:YES];
    [self.endLabel setText:@""];
    [self.memoView setHidden:YES];
    [self.memoIcon setHidden:YES];
    [self.startIcon setHidden:YES];
    [self.endIcon setHidden:YES];
    [self.memoTextView setText:DETAIL_PLACEHOLDER];
    [self.memoTextView setTextColor:FONT_PLACEHOLDER];
}

- (void)setStartTime:(NSString *)timeString
{
    if (timeString.length > 0) {
        [self.startIcon setHidden:NO];
        [self.startLabel setHidden:NO];
        [self.startLabel setText:timeString];
        [self.startButton setImage:[UIImage imageNamed:@"arrow_bottom"] forState:UIControlStateNormal];
        [self.startButton setImageEdgeInsets:UIEdgeInsetsMake(3.0, 53.0, 0, 0)];
    } else {
        [self.startButton setImage:[UIImage imageNamed:@"detail_cell_time"] forState:UIControlStateNormal];
        [self.startButton setImageEdgeInsets:UIEdgeInsetsZero];
    }
}

- (void)setEndTime:(NSString *)timeString
{
    if (timeString.length > 0) {
        [self.endIcon setHidden:NO];
        [self.endLabel setHidden:NO];
        [self.endLabel setText:timeString];
        [self.endButton setImage:[UIImage imageNamed:@"arrow_bottom"] forState:UIControlStateNormal];
        [self.endButton setImageEdgeInsets:UIEdgeInsetsMake(3.0, 53.0, 0, 0)];
    } else {
        [self.endButton setImage:[UIImage imageNamed:@"detail_cell_time"] forState:UIControlStateNormal];
        [self.endButton setImageEdgeInsets:UIEdgeInsetsZero];
    }
}

- (void)setEditable:(BOOL)editable
{
    if (editable) {
        [self.startButton setHidden:NO];
        [self.endButton setHidden:NO];
    } else {
        [self.startButton setHidden:YES];
        [self.endButton setHidden:YES];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)startButtonDidClicked:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(detailCell:startButtonDidClicked:)]) {
        [self.delegate detailCell:self startButtonDidClicked:button];
    }
}

- (IBAction)endButtonDidClicked:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(detailCell:endButtonDidClicked:)]) {
        [self.delegate detailCell:self endButtonDidClicked:button];
    }
}

- (IBAction)memoButtonDidClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(detailCell:memoButtonDidClicked:)]) {
        [self.delegate detailCell:self memoButtonDidClicked:sender];
    }
}

- (void)setMemoText:(NSString *)text
{
    [self.memoTextView setText:text];
    [self updateTextViewTextColor];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(detailCell:memoInputDidStart:)]) {
        NSString *text = textView.text;
        if ([text isEqualToString:DETAIL_PLACEHOLDER]) {
            text = @"";
        }
        [self.delegate detailCell:self memoInputDidStart:text];
    }
    return NO;
}

- (void)updateTextViewTextColor
{
    if ([self.memoTextView.text isEqualToString:@""]) {
        self.memoTextView.text = DETAIL_PLACEHOLDER;
        self.memoTextView.textColor = FONT_PLACEHOLDER;
    } else if ([self.memoTextView.text isEqualToString:DETAIL_PLACEHOLDER]) {
        self.memoTextView.text = DETAIL_PLACEHOLDER;
        self.memoTextView.textColor = FONT_PLACEHOLDER;
    } else {
        self.memoTextView.textColor = [UIColor whiteColor];
    }
}

@end
