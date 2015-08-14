//
//  KeyboardBar.h
//  Overtime
//
//  Created by xuxiaoteng on 2/9/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    KeyboardBarTypeDetail,
    KeyboardBarTypeSNS
} KeyboardBarType;

@class KeyboardBar;

@protocol KeyboardBarDelegate <NSObject>

- (void)keyboardBar:(KeyboardBar *)keyboardBar inputDidFinished:(NSString *)text;

@end

@interface KeyboardBar : UIView <UITextViewDelegate>

@property (nonatomic, weak) id<KeyboardBarDelegate> delegate;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, assign) KeyboardBarType keyboardBarType;

- (id)initWithFrame:(CGRect)frame keyboardBarType:(KeyboardBarType)keyboardBarType;
- (void)setText:(NSString *)text;

@end
