//
//  RouteData.m
//  TramChallenge
//
//  Created by Stephen Sykes on 24/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import "RouteData.h"
#import "TCUtilities.h"

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

- (NSArray *)coordsForRoute:(NSString *)routeName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:routeName ofType:@".coords.txt"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    return json[@"line"];
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
