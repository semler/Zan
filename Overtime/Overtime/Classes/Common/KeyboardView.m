//
//  KeyboardView.m
//  Overtime
//
//  Created by xuxiaoteng on 2/12/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import "KeyboardView.h"

@implementation KeyboardView

#pragma mark - InputView

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (UIView *)inputAccessoryView
{
    if (!_keyboardBar) {
        _keyboardBar = [[KeyboardBar alloc] initWithFrame:CGRectMake(0, 0, self.width, 70.0) keyboardBarType:self.keyboardBarType];
        _keyboardBar.delegate = self.delegate;
    }
    [_keyboardBar setText:self.initialText];
    
    return _keyboardBar;
}

- (BOOL)becomeFirstResponder
{
    BOOL ret = [super becomeFirstResponder];
    [self.keyboardBar.textView becomeFirstResponder];
    return ret;
}

- (BOOL)resignFirstResponder
{
    BOOL ret = [super resignFirstResponder];
    [self.keyboardBar.textView resignFirstResponder];
    return ret;
}

@end
