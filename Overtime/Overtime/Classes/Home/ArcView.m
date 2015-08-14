//
//  ArcView.m
//  Overtime
//
//  Created by Xu Shawn on 3/31/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "ArcView.h"

#define PI 3.14159265358979323846
#define DegreesToRadiansFactor  0.017453292519943f			// PI / 180
#define RadiansToDegreesFactor  57.29577951308232f			// 180 / PI
#define DegreesToRadians(D) ((D) * DegreesToRadiansFactor)
#define RadiansToDegrees(R) ((R) * RadiansToDegreesFactor)
#define PerAngle (360.0 / 36.0)
#define AnimEndAngle 280.0

@implementation ArcView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        _startAngle = 0;
        _endAngle = 360;
    }
    return self;
}

- (void)reloadAtStartAngle:(NSInteger)startAngle endAngle:(NSInteger)endAngle
{
    [self setStartAngle:startAngle];
    [self setEndAngle:endAngle];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat components[] = {0.0, 0.0, 0.0, 1};
    CGContextSetFillColor(context, components);
    CGContextMoveToPoint(context, self.center.x, self.center.y);
    CGContextAddArc(context, self.center.x, self.center.y, self.width / 2, DegreesToRadians(self.startAngle), DegreesToRadians(self.endAngle), 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    
    CGContextSetBlendMode(context, kCGBlendModeClear);
    CGContextMoveToPoint(context, self.center.x, self.center.y);
    CGContextAddArc(context, self.center.x, self.center.y, self.width / 2 - 5.0, 0, 2 * PI, 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
}

@end
