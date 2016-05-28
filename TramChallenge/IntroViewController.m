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
    self.startChallengeButton.enabled = NO;
    [[TCAPIAdaptor instance] startAttempt:^() {
        [self performSegueWithIdentifier:@"StartChallengeSegue" sender:sender];
        self.startChallengeButton.enabled = YES;
    } failure:^(NSError *error, NSInteger status, NSDictionary *info) {
        self.startChallengeButton.enabled = YES;
    }];
}

@end
