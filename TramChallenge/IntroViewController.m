//
//  SecondViewController.m
//  TramChallenge
//
//  Created by Stephen Sykes on 19/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import "IntroViewController.h"
#import "TCAPIAdaptor.h"

@interface IntroViewController ()

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.startChallengeButton.layer.cornerRadius = 8;
}

- (IBAction)startChallenge:(id)sender {
    [[TCAPIAdaptor instance] startAttempt:^(NSString *cloudID) {
        
    } failure:^(NSError *error, NSInteger status, NSDictionary *info) {

    }];
}

@end
