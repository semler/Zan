//
//  KeyboardBar.m
//  Overtime
//
//  Created by xuxiaoteng on 2/9/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import "KeyboardBar.h"

@implementation KeyboardBar

- (id)initWithFrame:(CGRect)frame keyboardBarType:(KeyboardBarType)keyboardBarType
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *image = [UIImage imageNamed:@"memo_input_bg"];
        UIImage *resizedImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0) resizingMode:UIImageResizingModeTile];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width - 67.0, 70.0)];
        [imageView setImage:resizedImage];
        [self addSubview:imageView];
        
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(14.0, 11.0, imageView.width - 20.0, imageView.height - 11 * 2)];
        [self.textView setBackgroundColor:[UIColor clearColor]];
        [self.textView setTextColor:[UIColor whiteColor]];
        [self.textView setFont:[UIFont systemFontOfSize:14.0]];
//        [self.textView setReturnKeyType:UIReturnKeyDone];
        [self.textView setDelegate:self];
        [self addSubview:self.textView];
        
        UIImage *sendBgImage = [UIImage imageNamed:@"memo_send_bg"];
        UIImage *resizedSendBgImage = [sendBgImage resizableImageWithCapInsets:UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0) resizingMode:UIImageResizingModeTile];
        UIImageView *sendBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageView.right - 1, 0, self.width - imageView.right + 1, imageView.height)];
        [sendBgImageView setImage:resizedSendBgImage];
        [self addSubview:sendBgImageView];
        
        self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.sendButton setFrame:CGRectMake(imageView.right, 15.0, 60.0, 41.0)];
        if (keyboardBarType == KeyboardBarTypeDetail) {
            [self.sendButton setTitle:@"メモする" forState:UIControlStateNormal];
        } else {
            [self.sendButton setTitle:@"つぶやく" forState:UIControlStateNormal];
        }
        [self.sendButton setBackgroundImage:[UIImage imageNamed:@"send_text_button2"] forState:UIControlStateNormal];
        [self.sendButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
        [self.sendButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 13.0, 0)];
        [self.sendButton addTarget:self action:@selector(sendButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.sendButton];
        
        self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 20.0, self.sendButton.width, 14.0)];
        [self.countLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
        [self.countLabel setTextColor:[UIColor whiteColor]];
        [self.countLabel setTextAlignment:NSTextAlignmentCenter];
        [self.countLabel setText:@"(30)"];
        [self.sendButton addSubview:self.countLabel];
    }
    return self;
}

- (void)setText:(NSString *)text
{
    [self.textView setText:text];
    [self updateStatus];
}

- (void)updateStatus
{
    NSInteger count = 30 - self.textView.text.length;
    NSString *countText = [NSString stringWithFormat:@"(%d)", (int)count];
    
    if (count >= 0) {
        [self.countLabel setText:countText];
        [self.sendButton setEnabled:YES];
    } else {
        NSMutableAttributedString *attributeText = [[NSMutableAttributedString alloc] initWithString:countText];
        [attributeText addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, 1)];
        [attributeText addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(countText.length - 1, 1)];
        [attributeText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(1, countText.length - 2)];
        [self.countLabel setAttributedText:attributeText];
        [self.sendButton setEnabled:NO];
    }
}

- (void)sendButtonDidClicked:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(keyboardBar:inputDidFinished:)]) {
        [self.delegate keyboardBar:self inputDidFinished:self.textView.text];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        return NO;
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateStatus];
}

@end
