//
//  NSString+Size.h
//  Overtime
//
//  Created by xuxiaoteng on 2/17/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Size)

- (CGFloat)widthWithFont:(UIFont *)font;
- (CGFloat)heightWithWidth:(CGFloat)width andFont:(UIFont *)font;

@end
