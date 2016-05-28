//
//  TCTabBarController.m
//  TramChallenge
//
//  Created by Joao Cardoso on 28/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import "TCTabBarController.h"
#import "ChallengeNavigationController.h"

@implementation TCTabBarController

- (void)viewDidLoad {
    self.delegate = self;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (![tabBarController.selectedViewController isKindOfClass:[ChallengeNavigationController class]]) {
        return YES;
    }
    
    if ([viewController isKindOfClass:[ChallengeNavigationController class]]) {
        return NO;
    }
    
    return YES;
}

@end
