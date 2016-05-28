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
#import "TramLineSelectionViewController.h"
#import <SMCalloutView/SMCalloutView.h>
#import "TCUtilities.h"

@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate, TramLineSelectionDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) MKMapView *mapView;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL userLocationUpdated;

@property (nonatomic) NSMutableDictionary<NSString *, MKPolyline *> *overlays;

@property (nonatomic) TramLineSelectionViewController *filterListViewer;
@property (nonatomic) UIView *filterListOverlay;
@property (nonatomic) BOOL showingFilters;

@property (nonatomic) UIButton *filterButton;
@property (nonatomic, weak) SMCalloutView *activeCallout;

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

    self.overlays = [NSMutableDictionary new];

    self.filterListViewer = ({
        TramLineSelectionViewController *listViewer = [TramLineSelectionViewController new];
        listViewer.delegate = self;
        listViewer;
    });

    self.filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.filterButton.frame = CGRectMake(10, 22, 40, 40);
    self.filterButton.tintColor = [UIColor blackColor];
    [self.filterButton addTarget:self action:@selector(showFilters:) forControlEvents:UIControlEventTouchUpInside];
    [self.filterButton setImage:[UIImage imageNamed:@"tramsbutton"] forState:UIControlStateNormal];
    [self.mapView addSubview:self.filterButton];
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
        polyline.title = name;
        [self.mapView addOverlay:polyline];
        self.overlays[name] = polyline;
    }

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapViewTapped:)];
    tap.delegate = self;
    [self.mapView addGestureRecognizer:tap];
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

#pragma mark - Line Filters

- (IBAction)showFilters:(id)sender
{
    if (self.showingFilters) {
        [self dismissActiveCallout];
        return;
    }

    SMCalloutView *callout = [SMCalloutView new];
    callout.permittedArrowDirection = SMCalloutArrowDirectionUp;

    callout.contentView = ({
        UIView *view = [UIView new];
        CGSize preferredContentSize = self.filterListViewer.preferredContentSize;
        CGFloat height = MIN(preferredContentSize.height, self.view.height - 104);
        view.frame = CGRectMake(0, 0, preferredContentSize.width, height);
        [view addSubview:self.filterListViewer.view];
        self.filterListViewer.view.frame = CGRectInset(view.bounds, -10, -10);
        self.filterListViewer.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.filterListViewer.tableView.clipsToBounds = NO;
        view;
    });

    CGRect rect = CGRectOffset([self.view convertRect:self.filterButton.bounds fromView:self.mapView], 16, 26);
    [callout presentCalloutFromRect:rect inView:self.view constrainedToView:self.view animated:YES];

    self.activeCallout = callout;
    self.showingFilters = YES;
}



#pragma mark - TramLineSelectionDelegate

- (void)lineListDidChangeSelection:(TramLineSelectionViewController *)list
{
    if (list.selectedLines.count) {
        for (NSString *lineName in [RouteData routeNames]) {
            [self.mapView removeOverlay:self.overlays[lineName]];
        }
        for (NSString *lineName in list.selectedLines) {
            [self.mapView addOverlay:self.overlays[lineName]];
        }
    } else {
        for (NSString *lineName in [RouteData routeNames]) {
            [self.mapView addOverlay:self.overlays[lineName]];
        }
    }
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

- (MKPolylineRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(MKPolyline *)overlay
{
    MKPolylineRenderer *polylineView = [[MKPolylineRenderer alloc] initWithPolyline:overlay];

    polylineView.strokeColor =  [RouteData colorForRouteName:overlay.title];
    polylineView.lineWidth = 4.0;

    return polylineView;
}

#pragma mark - Gesture delegate

- (void)mapViewTapped:(UITapGestureRecognizer *)sender
{
    if (self.showingFilters) {
        [self dismissActiveCallout];
    }
}

- (void)dismissActiveCallout
{
    if (self.activeCallout) {
        [self.activeCallout dismissCalloutAnimated:YES];
        self.activeCallout = nil;
    }

    self.showingFilters = NO;
}


@end
