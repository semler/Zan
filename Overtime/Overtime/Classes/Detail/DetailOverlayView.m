//
//  DetailOverlayView.m
//  Overtime
//
//  Created by xuxiaoteng on 2/3/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import "DetailOverlayView.h"

@implementation DetailOverlayView

- (UIImage *)generateImage
{
    UIImage *image = [UIImage imageNamed:@"detail_map_info_bg"];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [imageView setImage:image];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 145.0, 54.0)];
    [label setText:@"2014年9月1日（月）\n5:00 出勤"];
    [label setNumberOfLines:0];
    [label setFont:[UIFont systemFontOfSize:12.0]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    [imageView addSubview:label];
    
    UIGraphicsBeginImageContext(imageView.frame.size);
    [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
    [super drawMapRect:mapRect zoomScale:zoomScale inContext:context];
    
//    UIImage *image = [UIImage imageNamed:@"detail_map_info_bg"];
    UIImage *image = [self generateImage];

    CGImageRef imageRef = image.CGImage;
    
    MKMapRect theMapRect = [self.overlay boundingMapRect];
    
    MKMapRect newMapRect = [self mapRectForRect:CGRectMake(0, 0, 148.0*2 / zoomScale, 88.0*2 / zoomScale)];
    newMapRect.origin.x = theMapRect.origin.x;
    newMapRect.origin.y = theMapRect.origin.y;
    CGRect theRect = [self rectForMapRect:newMapRect];
//    CGRect clipRect = [self rectForMapRect:mapRect];
    
//    CGContextScaleCTM(context, 1.0, -1.0);
//    CGContextTranslateCTM(context, 0.0, -theRect.size.height);

//    CGContextAddRect(context, clipRect);
//    CGContextClip(context);
    
    CGContextDrawImage(context, theRect, imageRef);
}

@end
