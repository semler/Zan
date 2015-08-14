//
//  MapPoint.m
//  Overtime
//
//  Created by Xu Shawn on 2/13/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "MapPoint.h"

@implementation MapPoint

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title
{
    self = [super init];
    if (self) {
        _coordinate = coordinate;
        _title = title;
    }
    return self;
}

@end
