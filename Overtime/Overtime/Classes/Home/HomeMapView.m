//
//  HomeMapView.m
//  Overtime
//
//  Created by Xu Shawn on 3/4/14.
//  Copyright (c) 2014 Bravesoft. All rights reserved.
//

#import "HomeMapView.h"
#import "MapPoint.h"
#import <MapKit/MapKit.h>

@interface HomeMapView () <MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;

@end

@implementation HomeMapView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setClipsToBounds:YES];
        
        self.mapView = [[MKMapView alloc] initWithFrame:self.bounds];
        [self.mapView setShowsUserLocation:YES];
        [self.mapView setDelegate:self];
        [self.mapView setUserTrackingMode:MKUserTrackingModeNone];
        if ([self.mapView respondsToSelector:@selector(setRotateEnabled:)]) {
            [self.mapView setRotateEnabled:NO];
        }
        if ([self.mapView respondsToSelector:@selector(setPitchEnabled:)]) {
            [self.mapView setPitchEnabled:NO];
        }
        [self addSubview:self.mapView];
        
        UIImage *bgImage = [UIImage imageNamed:@"HOME_MAP_bg"];
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [bgImageView setImage:bgImage];
        [self addSubview:bgImageView];
        
        UIImage *backImage = [UIImage imageNamed:@"back"];
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setFrame:CGRectMake(17.0, 20.0, backImage.size.width, backImage.size.height)];
        [backButton setImage:backImage forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backButton];
        
        if (DEBUG_MODE) {
            UIImage *crossImage = [UIImage imageNamed:@"map_cross"];
            UIButton *crossButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [crossButton setFrame:CGRectFromImage(crossImage)];
            [crossButton setImage:crossImage forState:UIControlStateNormal];
            [crossButton setCenter:self.mapView.center];
            [crossButton addTarget:self action:@selector(crossButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:crossButton];
        }
        
        [self addAreaCircles];
    }
    return self;
}

- (void)crossButtonDidClicked:(id)sender
{
    CLLocationCoordinate2D location = [self.mapView convertPoint:self.mapView.center toCoordinateFromView:self];
    [[AppManager sharedInstance] setTestLatitude:location.latitude];
    [[AppManager sharedInstance] setTestLongitude:location.longitude];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    [hud setMode:MBProgressHUDModeText];
    [hud setLabelText:@"Set test location successs"];
    [hud setRemoveFromSuperViewOnHide:YES];
    [hud hide:YES afterDelay:0.3];
}

- (void)backButtonDidClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(homeMapViewBackToHomeView:)]) {
        [self.delegate homeMapViewBackToHomeView:self];
    }
}

- (void)addAreaCircles
{
    [self.mapView removeOverlays:self.mapView.overlays];
    
    for (Area *area in [[AppManager sharedInstance] areaArray]) {
        double latitude = [area.latitude doubleValue];
        double longitude = [area.longitude doubleValue];
        double radius = [area.radius doubleValue];
        
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:CLLocationCoordinate2DMake(latitude, longitude) radius:radius];
        [self.mapView addOverlay:circle];
    }
}

- (void)putPinWithLatitude:(double)latitue andLogitude:(double)longitude
{
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latitue, longitude);
    MapPoint *mapPoint = [[MapPoint alloc] initWithCoordinate:location title:@""];
    [self.mapView addAnnotation:mapPoint];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D location = [userLocation coordinate];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 3000.0, 3000.0);
    [mapView setRegion:region animated:YES];
//    DLog(@"Home User Location: %f, %f", location.latitude, location.longitude);
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    MKCircleView *circleView = nil;
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircle *circle = overlay;
        circleView = [[MKCircleView alloc] initWithCircle:circle];
        [circleView setStrokeColor:[UIColor colorWithRed:0.41 green:0.65 blue:0.95 alpha:1]];
        [circleView setFillColor:[UIColor colorWithRed:0.83 green:0.93 blue:1 alpha:0.8]];
        [circleView setLineWidth:1.0];
    }
    return circleView;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *PinIdentifier = @"AnnotationIdentifier";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:PinIdentifier];
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:PinIdentifier];
        [annotationView setImage:[UIImage imageNamed:@"current_location"]];
    }
    return annotationView;
}

@end
