//
//  TCTramStop.m
//  TramChallenge
//
//  Created by Stephen Sykes on 28/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import "TCTramStop.h"

@interface TCTramStop ()

@end

@implementation TCTramStop

- (void)markVisited
{
    _visited = YES;
}


- (void)markUnvisited
{
    _visited = NO;
}

@end
