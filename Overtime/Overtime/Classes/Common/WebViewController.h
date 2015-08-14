//
//  WebViewController.h
//  Overtime
//
//  Created by xuxiaoteng on 2/3/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import "BaseViewController.h"

typedef enum {
    WebVCTypeDefault,
    WebVCTypeTask,
    WebVCTypeSuggest
} WebVCType;

@interface WebViewController : BaseViewController

- (id)initWithTitle:(NSString *)title URLString:(NSString *)urlString webVCType:(WebVCType)webVCType;

@end
