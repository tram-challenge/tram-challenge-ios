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
        return [self changeBrightness:baseColor amount:0.8];
    }
    return baseColor;
}

- (UIColor*)changeBrightness:(UIColor*)color amount:(CGFloat)amount
{

    CGFloat hue, saturation, brightness, alpha;
    if ([color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        brightness += (amount-1.0);
        brightness = MAX(MIN(brightness, 1.0), 0.0);
        return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    }

    CGFloat white;
    if ([color getWhite:&white alpha:&alpha]) {
        white += (amount-1.0);
        white = MAX(MIN(white, 1.0), 0.0);
        return [UIColor colorWithWhite:white alpha:alpha];
    }

    return nil;
}

@end
