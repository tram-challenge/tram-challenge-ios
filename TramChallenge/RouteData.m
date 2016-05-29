//
//  RouteData.m
//  TramChallenge
//
//  Created by Stephen Sykes on 24/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import "RouteData.h"
#import "TCUtilities.h"
#import "TCAPIAdaptor.h"
#import "TCTramStop.h"
#import "TCTramRoute.h"

@interface RouteData ()

@property (nonatomic) NSMutableDictionary<NSString *, TCTramRoute *> *routes;

@end

@implementation RouteData

static RouteData *_RouteData;

+ (RouteData *)instance
{
    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        _RouteData = [[self alloc] init];
    });
    return _RouteData;
}

- (void)fetchStopsSuccess:(void (^)())successBlock
{
    if (self.routes) {successBlock(); return;}

    [[TCAPIAdaptor instance] getRoutesWithSuccess:^(NSArray *stops) {
        [self setupRoutes];
        for (NSDictionary *stopDict in stops) {
            TCTramStop *stop = [TCTramStop new];
            stop.id = stopDict[@"id"];
            stop.name = stopDict[@"name"];
            stop.stop_numbers = stopDict[@"stop_numbers"];
            stop.hsl_ids = stopDict[@"hsl_ids"];
            stop.links = stopDict[@"links"];
            stop.stop_positions = [NSDictionary tc_cast:stopDict[@"stop_positions"]];
            CLLocationCoordinate2D coord =  {.latitude =  [stopDict[@"latitude"] floatValue], .longitude =  [stopDict[@"longitude"] floatValue]};
            stop.coord = coord;
            for (NSString *route in [NSArray tc_cast:stopDict[@"routes"]]) {
                [self.routes[route].stops addObject:stop];
            }
        }

        for (NSString *routeName in [self.class routeNames]) {
            [[self routeForRouteName:routeName] sort];
        }

        successBlock();
    } failure:^(NSError *error, NSInteger status, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Communication error"
                                                                           message:@"Can't fetch stops"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* retryAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [self fetchStopsSuccess:successBlock];
                                                              }];
            
            [alert addAction:retryAction];
            
            [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
        });
    }];
}

- (void)setupRoutes
{
    self.routes = [NSMutableDictionary dictionary];
    for (NSString *name in [self.class routeNames]) {
        TCTramRoute *route = [TCTramRoute new];
        route.routeName = name;
        self.routes[name] = route;
    }
}

- (NSArray<TCTramStop *> *)stopsForRoute:(NSString *)routeName
{
    return self.routes[routeName].stops;
}

- (TCTramRoute *)routeForRouteName:(NSString *)name
{
    return self.routes[name];
}

- (NSArray *)coordsForRoute:(NSString *)routeName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:routeName ofType:@".coords.txt"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    return json[@"line"];
}

- (NSSet<TCTramStop *> *)stops {
    NSMutableSet<TCTramStop *> *stops = [NSMutableSet set];
    
    for (NSString *routeName in self.class.routeNames) {
        for (TCTramStop *stop in [self stopsForRoute:routeName]) {
            [stops addObject:stop];
        }
    }
    
    return stops;
}

- (NSSet<TCTramStop *> *)visitedStops {
    NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(TCTramStop *stop, NSDictionary *bindings) {
        return stop.visited;
    }];
    
    return [self.stops filteredSetUsingPredicate:pred];
}

- (NSSet<TCTramStop *> *)unvisitedStops {
    NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(TCTramStop *stop, NSDictionary *bindings) {
        return !stop.visited;
    }];
    
    return [self.stops filteredSetUsingPredicate:pred];
}

- (void)markStopAsVisited:(NSString *)stopID
{
    for (TCTramStop *stop in [self stops]) {
        if ([stop.id isEqualToString:stopID]) {
            stop.visited = YES;
            break;
        }
    }
}

- (void)clearVisitedStops {
    for (TCTramStop *stop in self.stops) {
        stop.visited = NO;
    }
}

+ (NSArray<NSString *> *)routeNames
{
    return @[@"1", @"1A", @"2", @"3", @"4", @"4T", @"6", @"6T", @"7A", @"7B", @"8", @"9", @"10"];
}

+ (UIColor *)colorForRouteName:(NSString *)routeName
{
    return (UIColor *)(@{
      @"1" : [UIColor colorWithRed:0.50 green:0.75 blue:0.88 alpha:1.0],
      @"1A" : [UIColor colorWithRed:0.50 green:0.75 blue:0.88 alpha:1.0],
      @"2"  : [UIColor colorWithRed:0.00 green:0.65 blue:0.39 alpha:1.0],
      @"3"  : [UIColor colorWithRed:0.55 green:0.78 blue:0.59 alpha:1.0],
      @"4" : [UIColor colorWithRed:0.79 green:0.11 blue:0.31 alpha:1.0],
      @"4T" : [UIColor colorWithRed:0.79 green:0.11 blue:0.31 alpha:1.0],
      @"6" : [UIColor colorWithRed:0.58 green:0.27 blue:0.59 alpha:1.0],
      @"6T" : [UIColor colorWithRed:0.58 green:0.27 blue:0.59 alpha:1.0],
      @"7A" : [UIColor colorWithRed:0.97 green:0.68 blue:0.17 alpha:1.0],
      @"7B" : [UIColor colorWithRed:0.97 green:0.68 blue:0.17 alpha:1.0],
      @"8"  : [UIColor colorWithRed:0.80 green:0.47 blue:0.15 alpha:1.0],
      @"9"  : [UIColor colorWithRed:0.80 green:0.09 blue:0.53 alpha:1.0],
      @"10" : [UIColor colorWithRed:0.77 green:0.73 blue:0.17 alpha:1.0]
      }[routeName]);
}

@end
