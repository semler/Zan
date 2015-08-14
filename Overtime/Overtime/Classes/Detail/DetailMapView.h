//
//  DetailMapView.h
//  Overtime
//
//  Created by xuxiaoteng on 2/3/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class DetailMapView;

@protocol DetailMapViewDelegate <NSObject>

- (void)detailMapViewBackToHomeView:(DetailMapView *)mapView;

@end

@interface DetailMapView : UIView

@property (nonatomic, weak) id<DetailMapViewDelegate> delegate;

- (void)addAnnotationAtCoordinate:(CLLocationCoordinate2D)coordinate infoString:(NSString *)info;
- (void)addOverlayAtCoordinate:(CLLocationCoordinate2D)coordinate;

@end
