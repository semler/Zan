//
//  HomeMapView.h
//  Overtime
//
//  Created by Xu Shawn on 3/4/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MAP_MARGIN_X 90.0
#define MAP_MARGIN_Y 58.0

@class HomeMapView;

@protocol HomeMapViewDelegate <NSObject>

- (void)homeMapViewBackToHomeView:(HomeMapView *)mapView;

@end

@interface HomeMapView : UIView

@property (nonatomic, weak) id<HomeMapViewDelegate> delegate;

- (void)addAreaCircles;

@end
