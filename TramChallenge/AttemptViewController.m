//
//  AttemptViewController.m
//  TramChallenge
//
//  Created by Joao Cardoso on 28/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import "AttemptViewController.h"
#import "RouteData.h"
#import "TCTramStop.h"

@implementation AttemptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        [self.navigationController.view removeGestureRecognizer:self.navigationController.interactivePopGestureRecognizer];
    }
    
    [self.navigationItem setHidesBackButton:YES];
    
    self.abortChallengeButton.layer.cornerRadius = 4;
    self.abortChallengeButton.layer.borderWidth = 2;
    self.abortChallengeButton.layer.borderColor = [[UIColor colorWithRed:0.59 green:0.59 blue:0.59 alpha:1.0] CGColor];
    
    self.statsView.layer.cornerRadius = 4;
    self.timeElapsedLabel.font = [UIFont monospacedDigitSystemFontOfSize:34 weight:UIFontWeightBold];
    self.totalStopsLabel.font = [UIFont monospacedDigitSystemFontOfSize:34 weight:UIFontWeightBold];
    self.stopsVisitedLabel.font = [UIFont monospacedDigitSystemFontOfSize:34 weight:UIFontWeightBold];
    
    [self.timeElapsedLabel start];
    
    self.totalStops = 0;
    self.stopsVisited = 0;
    
    self.totalStopsLabel.text = @"";

    [[RouteData instance] fetchStopsSuccess:^{
        self.totalStops = RouteData.instance.stops.count;
        self.stopsVisited = RouteData.instance.visitedStops.count;
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.stopsVisited = RouteData.instance.visitedStops.count;
}

- (IBAction)abortChallenge:(id)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Abort Challenge"
                                                                   message:@"Are you sure you want to abort the challenge?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * action) {
                                                                  [self.navigationController popToRootViewControllerAnimated:NO];
                                                          }];
    
    UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:yesAction];
    [alert addAction:noAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)setTotalStops:(NSInteger)totalStops {
    _totalStops = totalStops;
    self.totalStopsLabel.text = [NSString stringWithFormat:@"%d", totalStops];
    [self updateProgress];
}

- (void)setStopsVisited:(NSInteger)stopsVisited {
    _stopsVisited = stopsVisited;
    self.stopsVisitedLabel.text = [NSString stringWithFormat:@"%d", stopsVisited];
    [self updateProgress];
}

- (void)updateProgress {
    if (self.totalStops == 0) {
        self.progressView.value = 0;
    } else {
        CGFloat progress = floor(100.0 * self.stopsVisited / self.totalStops);
        self.progressView.value = progress;
    }
}


@end
