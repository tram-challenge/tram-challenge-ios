//
//  TCTramRoute.m
//  TramChallenge
//
//  Created by Stephen Sykes on 28/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import "TCTramRoute.h"
#import "TCTramStop.h"
#import "RouteData.h"

@implementation TCTramRoute

- (instancetype)init
{
    self = [super init];
    if (self) {
        _stops = [NSMutableArray array];
    }
    return self;
}

- (UIColor *)colorForStop:(TCTramStop *)stop
{
    UIColor *baseColor = [RouteData colorForRouteName:self.routeName];
    if (stop.visited) {
        return [self setSaturation:baseColor amount:0.15];
    }
    return baseColor;
}

- (UIColor*)setSaturation:(UIColor*)color amount:(CGFloat)amount
{

    CGFloat hue, saturation, brightness, alpha;
    if ([color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        saturation = amount;
        return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    }

    return color;
}

@end
