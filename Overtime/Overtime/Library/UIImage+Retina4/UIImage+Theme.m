//
//  UIImage+Theme.m
//  Overtime
//
//  Created by Xu Shawn on 2/18/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "UIImage+Theme.h"

@implementation UIImage (Theme)

+ (UIImage *)imageNamed:(NSString *)name themeType:(ThemeType)themeType
{
    NSString *imageName = @"";
    
    switch (themeType) {
        case ThemeTypeBlue:
            imageName = [NSString stringWithFormat:@"%@_blue", name];
            break;
        case ThemeTypeRed:
            imageName = [NSString stringWithFormat:@"%@_red", name];
            break;
        default:
            break;
    }
    
    return [UIImage imageNamed:imageName];
}

@end
