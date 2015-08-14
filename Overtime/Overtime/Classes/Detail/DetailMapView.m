//
//  DetailMapView.m
//  Overtime
//
//  Created by xuxiaoteng on 2/3/15.
//  Copyright (c) 2015 Bravesoft. All rights reserved.
//

#import "DetailMapView.h"
#import "DetailOverlay.h"
#import "DetailOverlayView.h"
#import "MapPoint.h"
#import "DetailAnnotationView.h"

@interface DetailMapView () <MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *info;

@end

@implementation DetailMapView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setClipsToBounds:YES];
        
        self.mapView = [[MKMapView alloc] initWithFrame:self.bounds];
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
    }
    return self;
}

- (void)backButtonDidClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(detailMapViewBackToHomeView:)]) {
        [self.delegate detailMapViewBackToHomeView:self];
    }
}

- (void)addAnnotationAtCoordinate:(CLLocationCoordinate2D)coordinate infoString:(NSString *)info
{
    [self setCoordinate:coordinate];
    [self setInfo:info];
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 1000.0, 1000.0);
    [self.mapView setRegion:region animated:YES];
    
    MapPoint *mapPoint = [[MapPoint alloc] initWithCoordinate:coordinate title:@""];
    [self.mapView addAnnotation:mapPoint];
    
//    MKCircle *circle = [MKCircle circleWithCenterCoordinate:coordinate radius:100];
//    [self.mapView addOverlay:circle];
}

- (void)addOverlayAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self setCoordinate:coordinate];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 1000.0, 1000.0);
    [self.mapView setRegion:region animated:YES];
    
    [self.mapView removeOverlays:self.mapView.overlays];
    
    DetailOverlay *detailOverlay = [[DetailOverlay alloc] initWithCoordinate:self.coordinate];
    [self.mapView addOverlay:detailOverlay];
}

#pragma mark - MKMapViewDelegate

//- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
//{
//    if ([overlay isKindOfClass:[DetailOverlay class]]) {
//        DetailOverlayView *detailOverlayView = [[DetailOverlayView alloc] initWithOverlay:overlay];
//        return detailOverlayView;
//    } else {
//        return nil;
//    }
//}

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
    DetailAnnotationView *annotationView = (DetailAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:PinIdentifier];
    if ([annotation isKindOfClass:[MapPoint class]]) {
        annotationView = [[DetailAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:PinIdentifier];
        [annotationView setCenterOffset:CGPointMake(15.0, -33.0)];
        [annotationView setImage:[self generateImage]];
    }
    return annotationView;
}

- (UIImage *)generateImage
{
    UIImage *image = [UIImage imageNamed:@"detail_map_info_bg"];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [imageView setImage:image];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 145.0, 54.0)];
    [label setText:self.info];
    [label setNumberOfLines:0];
    [label setFont:[UIFont systemFontOfSize:12.0]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    [imageView addSubview:label];
    
    UIGraphicsBeginImageContextWithOptions(imageView.frame.size, NO, 0.0);
    [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
