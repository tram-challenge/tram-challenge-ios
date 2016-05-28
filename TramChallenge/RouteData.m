//
//  RouteData.m
//  TramChallenge
//
//  Created by Stephen Sykes on 24/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import "RouteData.h"

@implementation RouteData

+ (NSArray *)coordsForRoute:(NSString *)routeName
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
      @"1A" : [UIColor redColor],
      @"2"  : [UIColor greenColor],
      @"3"  : [UIColor cyanColor],
      @"4T" : [UIColor blueColor],
      @"6T" : [UIColor brownColor],
      @"7A" : [UIColor purpleColor],
      @"7B" : [UIColor magentaColor],
      @"8"  : [UIColor orangeColor],
      @"9"  : [UIColor yellowColor],
      @"10" : [UIColor grayColor]
      }[routeName]);
}

@end
