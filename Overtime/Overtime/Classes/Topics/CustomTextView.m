//
//  CustomTextView.m
//  Overtime
//
//  Created by 于　超 on 2015/08/05.
//  Copyright (c) 2015年 Bravesoft. All rights reserved.
//

#import "CustomTextView.h"

@implementation CustomTextView

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    [UIMenuController sharedMenuController].menuVisible = NO;
//    [self resignFirstResponder];
    return NO;
}

@end
