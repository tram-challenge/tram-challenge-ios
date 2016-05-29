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
#import "TCTramRoute.h"
#import "TCTramStop.h"
#import "TCAPIAdaptor.h"

#pragma mark - Annotation class

@interface TCAnnotation : NSObject <MKAnnotation>
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic) UIColor *color;
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title;
@end

@implementation TCAnnotation
- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title
{
    self = [super init];
    if (self) {
        _coordinate = coordinate;
        _title = title;
    }
    return self;
}
@end

#pragma mark - Annotation view

@interface TCAnnotationView : MKAnnotationView
@property (nonatomic) UIColor *color;
@end

@implementation TCAnnotationView
- (void)drawRect:(CGRect)rect
{
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(3, 3, 14, 14)];
    [[UIColor whiteColor] setFill];
    [ovalPath fill];
    [self.color setStroke];
    ovalPath.lineWidth = 5;
    [ovalPath stroke];
}
@end

#pragma mark - Veh annotation class

@interface TCVehAnnotation : NSObject <MKAnnotation>
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic) UIColor *color;
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title;
@end

@implementation TCVehAnnotation
- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title
{
    self = [super init];
    if (self) {
        _coordinate = coordinate;
        _title = title;
    }
    return self;
}
@end

#pragma mark - Veh annotation view

@interface TCVehAnnotationView : MKAnnotationView
@property (nonatomic) UIColor *color;
@property (nonatomic) NSString *title;
@end

@implementation TCVehAnnotationView
- (void)drawRect:(CGRect)rect
{
    //// Rounded Rectangle Drawing
    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(3, 3, 14, 14) cornerRadius: 4];
    [self.color setFill];
    [roundedRectanglePath fill];
    [self.color setStroke];
    roundedRectanglePath.lineWidth = 1;
    [roundedRectanglePath stroke];


    CGRect textRect = CGRectMake(3, 5, 14, 14);
    NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [textStyle setAlignment: NSTextAlignmentCenter];
    NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 9], NSForegroundColorAttributeName: [UIColor whiteColor], NSParagraphStyleAttributeName: textStyle};

    [self.title drawInRect: textRect withAttributes: textFontAttributes];
}
@end


#pragma mark - MapViewController

@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate, TramLineSelectionDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) MKMapView *mapView;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL userLocationUpdated;

@property (nonatomic) NSMutableDictionary<NSString *, MKPolyline *> *overlays;
@property (nonatomic) NSMutableDictionary<NSString *, NSMutableArray<TCAnnotation *> *> *annotations;
@property (nonatomic) NSMutableDictionary<NSString *, TCVehAnnotation *> *vehAnnotations;

@property (nonatomic) TramLineSelectionViewController *filterListViewer;
@property (nonatomic) UIView *filterListOverlay;
@property (nonatomic) BOOL showingFilters;

@property (nonatomic) UIBarButtonItem *filterButton;
@property (nonatomic, weak) SMCalloutView *activeCallout;

@property (nonatomic, strong) NSTimer *vehTimer;

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

    UIImage *buttonImage = [self imageWithImage:[UIImage imageNamed:@"tramsbuttonpng"] scaledToSize:CGSizeMake(34,34)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:buttonImage style:UIBarButtonItemStylePlain target:self action:@selector(showFilters:)];
    self.filterButton = self.navigationItem.leftBarButtonItem;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
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
        NSArray *coords = [[RouteData instance] coordsForRoute:name];
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

    [[RouteData instance] fetchStopsSuccess:^{
        self.annotations = [NSMutableDictionary dictionary];
        for (NSString *name in [RouteData routeNames]) {
            TCTramRoute *route = [[RouteData instance] routeForRouteName:name];
            self.annotations[name] = [NSMutableArray array];
            for (TCTramStop *stop in [[RouteData instance] stopsForRoute:name]) {
                TCAnnotation *annotation = [[TCAnnotation alloc] initWithCoordinate:stop.coord title:stop.name];
                annotation.color = [route colorForStop:stop];
                [self.mapView addAnnotation:annotation];
                [self.annotations[name] addObject:annotation];
            }
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.vehTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updateVeh) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.vehTimer invalidate];
}

- (void)updateVeh
{
    if (!self.vehAnnotations) self.vehAnnotations = [NSMutableDictionary dictionary];

    NSMutableArray *seen = [NSMutableArray array];
    [[TCAPIAdaptor instance] tramPositions:^(NSDictionary *pos) {
        for (NSString *vehID in pos) {
            NSArray *data = [NSArray tc_cast:pos[vehID]];
            NSString *longName = [NSString tc_cast:data[2]];
            NSString *routeName = [longName substringFromIndex:3];
            TCVehAnnotation *annotation = self.vehAnnotations[vehID];
            CLLocationCoordinate2D coord = {.latitude = [data[0] floatValue], .longitude =  [data[1] floatValue]};

            if (annotation) {
                annotation.coordinate = coord;
                [seen addObject:vehID];
            } else if ([[RouteData routeNames] containsObject:routeName]) {
                TCVehAnnotation *newAnnotation = [[TCVehAnnotation alloc] initWithCoordinate:coord title:routeName];
                newAnnotation.color = [RouteData colorForRouteName:routeName];
                [self.mapView addAnnotation:newAnnotation];
                self.vehAnnotations[vehID] = newAnnotation;
                [seen addObject:vehID];
            }
        }
        NSMutableDictionary<NSString *, TCVehAnnotation *> *newVehAnnotations = [NSMutableDictionary dictionary];
        for (NSString *vehID in self.vehAnnotations) {
            TCVehAnnotation *annotation = self.vehAnnotations[vehID];
            if ([seen containsObject:vehID]) {
                newVehAnnotations[vehID] = annotation;
            } else {
                [self.mapView removeAnnotation:annotation];
            }
        }
        self.vehAnnotations = newVehAnnotations;
        [self filterLiveTrams:self.filterListViewer];
    }];
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

// TODO: Find a way to get the rect from the barbuttonitem
//    CGRect rect = CGRectOffset([self.view convertRect:self.filterButton.bounds fromView:self.mapView], 16, 26);
    CGRect rect = CGRectMake(0,0,50,50); // Fudged for now
    [callout presentCalloutFromRect:rect inView:self.view constrainedToView:self.view animated:YES];

    self.activeCallout = callout;
    self.showingFilters = YES;
}



#pragma mark - TramLineSelectionDelegate

- (void)lineListDidChangeSelection:(TramLineSelectionViewController *)list
{
    // Better to this with set operations?
    if (list.selectedLines.count) {
        for (NSString *lineName in [RouteData routeNames]) {
            if (![list.selectedLines containsObject:lineName]) {
                [self.mapView removeOverlay:self.overlays[lineName]];
            }
        }
        for (NSString *lineName in list.selectedLines) {
            [self.mapView addOverlay:self.overlays[lineName]];
        }
        for (NSString *lineName in [RouteData routeNames]) {
            if (![list.selectedLines containsObject:lineName]) {
                for (TCAnnotation *annotation in self.annotations[lineName]) {
                    [self.mapView removeAnnotation:annotation];
                }
            }
        }
        for (NSString *lineName in list.selectedLines) {
            for (TCAnnotation *annotation in self.annotations[lineName]) {
                if (![_mapView.annotations containsObject:annotation]) {
                    [self.mapView addAnnotation:annotation];
                }
            }
        }
    } else {
        for (NSString *lineName in [RouteData routeNames]) {
            [self.mapView addOverlay:self.overlays[lineName]];
        }

        for (NSString *lineName in [RouteData routeNames]) {
            for (TCAnnotation *annotation in self.annotations[lineName]) {
                if (![_mapView.annotations containsObject:annotation]) {
                    [self.mapView addAnnotation:annotation];
                }
            }
        }
    }

    [self filterLiveTrams:list];
}

- (void)filterLiveTrams:(TramLineSelectionViewController *)list
{
    for (TCVehAnnotation *annotation in [self.vehAnnotations allValues]) {
        if (list.selectedLines.count) {
            if ([list.selectedLines containsObject:annotation.title]) {
                [[self.mapView viewForAnnotation:annotation] setHidden:NO];
            } else {
                [[self.mapView viewForAnnotation:annotation] setHidden:YES];
            }
        } else {
            [[self.mapView viewForAnnotation:annotation] setHidden:NO];
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
    polylineView.lineWidth = 6.0;

    return polylineView;
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    TCAnnotationView *pinView = nil;
    TCVehAnnotationView *pinvehView = nil;
    if ([annotation isKindOfClass:[TCAnnotation class]]) {
        static NSString *defaultPinID = @"com.switchstep.stop";
        pinView = (TCAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if (pinView == nil) pinView = [[TCAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        pinView.color = ((TCAnnotation *)annotation).color;
        pinView.frame = CGRectMake(0, 0, 25, 25);
        pinView.canShowCallout = YES;
        pinView.backgroundColor = [UIColor clearColor];
        [pinView setNeedsDisplay];
        return pinView;
    } else if ([annotation isKindOfClass:[TCVehAnnotation class]]) {
        static NSString *defaultVehPinID = @"com.switchstep.veh";
        pinvehView = (TCVehAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultVehPinID];
        if (pinvehView == nil) pinvehView = [[TCVehAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultVehPinID];
        pinvehView.color = ((TCVehAnnotation *)annotation).color;
        pinvehView.frame = CGRectMake(0, 0, 25, 25);
        pinvehView.canShowCallout = YES;
        pinvehView.backgroundColor = [UIColor clearColor];
        pinvehView.title = ((TCVehAnnotation *)annotation).title;
        pinvehView.layer.zPosition = 3; // in front of stops
        [pinvehView setNeedsDisplay];
        return pinvehView;
    } else {
        return nil;
    }
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
