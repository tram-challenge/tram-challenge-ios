//
//  MapViewController.m
//  TramChallenge
//
//  Created by Stephen Sykes on 19/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <Masonry/Masonry.h>
#import "AppDelegate.h"
#import "RouteData.h"

@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic) MKMapView *mapView;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL userLocationUpdated;

@property (nonnull) MKPolylineView *lineView;

@end

@implementation MapViewController

- (void)loadView
{
    [super loadView];

    self.mapView = ({
        MKMapView *mapView = [MKMapView new];
        mapView.delegate = self;
        mapView.showsPointsOfInterest = NO;
        [self.view addSubview:mapView];
        mapView;
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;

    self.userLocationUpdated = NO;

    CLLocationCoordinate2D coord = {.latitude =  60.1799, .longitude =  24.9384};
    MKCoordinateSpan span = {.latitudeDelta =  0.1, .longitudeDelta =  0.1};
    MKCoordinateRegion region = {coord, span};
    [self.mapView setRegion:region];

    [self updateForAuthorizationStatus:[CLLocationManager authorizationStatus]];

    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }


    for (NSString *name in [RouteData routeNames]) {
        NSArray *coords = [RouteData coordsForRoute:name];
        CLLocationCoordinate2D coordinates[coords.count];
        int i = 0;
        for (NSArray *coord in coords) {
            coordinates[i] = CLLocationCoordinate2DMake([coord[0] floatValue], [coord[1] floatValue]);
            i++;
        }
        MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinates count:i];
        [self.mapView addOverlay:polyline];

        self.lineView = [[MKPolylineView alloc] initWithPolyline:polyline];
        self.lineView.strokeColor = [RouteData colorForRouteName:name];
        self.lineView.lineWidth = 5;
        break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)updateViewConstraints
{
    [self.mapView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];


    [super updateViewConstraints];
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self updateForAuthorizationStatus:status];
}

- (void)updateForAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.mapView.showsUserLocation = YES;
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    delegate.userLocation = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude
                                                       longitude:userLocation.coordinate.longitude];

    if (self.userLocationUpdated) return;

    MKCoordinateRegion region;

    CLLocationCoordinate2D location;
    location.latitude = userLocation.coordinate.latitude;
    location.longitude = userLocation.coordinate.longitude;
    region.center = location;

    MKCoordinateSpan span;
    span.latitudeDelta = 0.1;
    span.longitudeDelta = 0.1;
    region.span = span;

    [mapView setRegion:region animated:YES];

    self.userLocationUpdated = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    return self.lineView;
}

@end
