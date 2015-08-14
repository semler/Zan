//
//  Modal.m
//  Overtime
//
//  Created by Xu Shawn on 3/11/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "Modal.h"

@implementation Modal

- (id)init
{
    self = [super init];
    if (self) {
        _dbo = [[DBUtils sharedDBUtils] dbo];
        _pid = 0;
        _send_flag = @"0";
        _delete_flag = @"0";
    }
    return self;
}

- (BOOL)save
{
    return NO;
}

@end
