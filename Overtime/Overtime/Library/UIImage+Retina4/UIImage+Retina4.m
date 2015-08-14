//
//  UIImage+Retina4.m
//  UIImage+Retina4
//
//  Created by Xu Shawn on 4/24/13.
//  Copyright (c) 2013 BraveSoft. All rights reserved.
//

#import "UIImage+Retina4.h"
#import <objc/runtime.h>
#import <objc/message.h>

static Method origImageNamedMethod = nil;

@implementation UIImage (Retina4)

+ (void)load {
    origImageNamedMethod = class_getClassMethod(self, @selector(imageNamed:));
    method_exchangeImplementations(origImageNamedMethod,
                                   class_getClassMethod(self, @selector(retina4ImageNamed:)));
}

+ (UIImage *)retina4ImageNamed:(NSString *)imageName {
//    NSLog(@"Loading image named => %@", imageName);
    
    NSMutableString *imageNameMutable = nil;
    
    NSRange dotRange = [imageName rangeOfString:@"."];
    if (dotRange.location != NSNotFound) {
        imageNameMutable = [[imageName substringToIndex:dotRange.location] mutableCopy];
    } else {
        imageNameMutable = [imageName mutableCopy];
    }
    
    NSRange retinaAtSymbol = [imageName rangeOfString:@"@"];
    if (retinaAtSymbol.location != NSNotFound) {
        [imageNameMutable insertString:@"_568h" atIndex:retinaAtSymbol.location];
    } else {
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f) {
            NSRange dot = [imageName rangeOfString:@"."];
            if (dot.location != NSNotFound) {
                [imageNameMutable insertString:@"_568h@2x" atIndex:dot.location];
            } else {
                [imageNameMutable appendString:@"_568h@2x"];
            }
        }
    }
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageNameMutable ofType:@"png"];
    if (imagePath) {
        retinaAtSymbol = [imageNameMutable rangeOfString:@"@"];
        if (retinaAtSymbol.location != NSNotFound) {
            return [UIImage retina4ImageNamed:[imageNameMutable substringToIndex:retinaAtSymbol.location]];
        } else {
            return [UIImage retina4ImageNamed:imageNameMutable];
        }
    } else {
        return [UIImage retina4ImageNamed:imageName];
    }
    return nil;
}

@end
