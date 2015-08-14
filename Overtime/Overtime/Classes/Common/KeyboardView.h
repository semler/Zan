//
//  KeyboardView.h
//  Overtime
//
//  Created by xuxiaoteng on 2/12/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyboardBar.h"

@interface KeyboardView : UIView

@property (nonatomic, strong) KeyboardBar *keyboardBar;
@property (nonatomic, weak) id<KeyboardBarDelegate> delegate;
@property (nonatomic, copy) NSString *initialText;
@property (nonatomic, assign) KeyboardBarType keyboardBarType;

@end
