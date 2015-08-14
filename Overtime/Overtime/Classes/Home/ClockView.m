//
//  ClockView.m
//  Overtime
//
//  Created by Xu Shawn on 3/31/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "ClockView.h"

@implementation ClockView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImage *bgImage = [UIImage imageNamed:@"home_clock_bg" themeType:CurrentThemeType];
        self.bgImageView = [[UIImageView alloc] initWithFrame:CGRectFromImage(bgImage)];
        [self.bgImageView setImage:bgImage];
        [self addSubview:self.bgImageView];
        
        self.arcView = [[ArcView alloc] initWithFrame:self.bounds];
        [self addSubview:self.arcView];
        
        UIImage *handImage = [UIImage imageNamed:@"clock_hand"];
        self.handImageView = [[UIImageView alloc] initWithFrame:CGRectOffsetFromImage(handImage, -7.0 + handImage.size.width / 2, (self.height - handImage.size.height) / 2)];
        [self.handImageView setImage:handImage];
        [self.handImageView.layer setAnchorPoint:CGPointMake(1, 0.5)];
        [self addSubview:self.handImageView];
        
        [self.handImageView setTransform:CGAffineTransformMakeRotation(90 * (M_PI / 180.0))];
    }
    return self;
}

- (void)updateTheme:(ThemeType)themeType
{
    UIImage *bgImage = [UIImage imageNamed:@"home_clock_bg" themeType:themeType];
    [self.bgImageView setImage:bgImage];
}

- (void)reloadAtStartTime:(NSString *)startTime endTime:(NSString *)endTime
{
    NSInteger startMinute = [self minuteFromTime:startTime];
    NSInteger endMinute = [self minuteFromTime:endTime];
    NSInteger startAngle = [self angleFromMinute:startMinute];
    NSInteger endAngle = [self angleFromMinute:endMinute];
    if (startAngle == endAngle) {
        endAngle = startAngle + 1;
    }
    // Reverse range to show black mask
    [self.arcView reloadAtStartAngle:endAngle endAngle:startAngle];
    // Hour hand rotation
    [self.handImageView setTransform:CGAffineTransformMakeRotation((endAngle + 180.0) * (M_PI / 180.0))];
}

- (NSInteger)minuteFromTime:(NSString *)time
{
    NSDate *date = [time localDateWithFormat:DB_DATE_HM];
    NSDateComponents *dateComponent = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:date];
    return dateComponent.hour * 60 + dateComponent.minute;
}

- (NSInteger)angleFromMinute:(NSInteger)minute
{
    // Per minute angle
    CGFloat minuteAngle = 360.0 / (24.0 * 60.0);
    // Result angle
    CGFloat angle = minute * minuteAngle + 270;
    return angle;
}

@end
