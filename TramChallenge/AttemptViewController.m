//
//  AttemptViewController.m
//  TramChallenge
//
//  Created by Joao Cardoso on 28/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import "AttemptViewController.h"
#import "RouteData.h"
#import "TCAPIAdaptor.h"
#import "TCTramStop.h"
#import <MBCircularProgressBar/MBCircularProgressBarView.h>
#import "TCUtilities.h"

@interface AttemptViewController ()

@property (weak, nonatomic) IBOutlet MBCircularProgressBarView *progressBarView;

@end

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
    
    self.timeElapsedLabel.shouldCountBeyondHHLimit = YES;
    
    double elapsed = TCAPIAdaptor.instance.elapsedTime.doubleValue;
    lg(@"Elapsed time: %f", elapsed);
    if (elapsed > 24 * 60 * 60) {
        [self timeLimitExceeded];
        return;
    }
    [self.timeElapsedLabel setStopWatchTime:TCAPIAdaptor.instance.elapsedTime.doubleValue];
    [self.timeElapsedLabel start];
    
    self.totalStops = 0;
    self.stopsVisited = 0;
    
    self.totalStopsLabel.text = @"";

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    if (screenHeight >= 550) self.progressBarView.progressColor = [self.progressBarView.progressColor colorWithAlphaComponent:1];

    [[RouteData instance] fetchStopsSuccess:^{
        self.totalStops = RouteData.instance.stops.count;
        self.stopsVisited = RouteData.instance.visitedStops.count;
    }];
}

- (void)timeLimitExceeded
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Time limit exceeded"
                                                                   message:@"The challenge cannot exceed 24 hours, please start a new challenge."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction * action) {
                                                          [[TCAPIAdaptor instance] abortAttempt:^{
                                                              NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                              [defaults setBool:NO forKey:@"in_progress"];
                                                              [defaults synchronize];
                                                              [[RouteData instance] clearVisitedStops];
                                                              [self.navigationController popToRootViewControllerAnimated:NO];
                                                          } failure:^{}];
                                                      }];
    
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.stopsVisited = RouteData.instance.visitedStops.count;
}

- (IBAction)abortChallenge:(id)sender {
    if (RouteData.instance.unvisitedStops.count == 0) {
        [[RouteData instance] clearVisitedStops];
        [self.navigationController popToRootViewControllerAnimated:NO];
        return;
    }

    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Abort Challenge"
                                                                   message:@"Are you sure you want to abort the challenge?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * action) {
                                                              [[TCAPIAdaptor instance] abortAttempt:^{
                                                                  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                                  [defaults setBool:NO forKey:@"in_progress"];
                                                                  [defaults synchronize];
                                                                  [[RouteData instance] clearVisitedStops];
                                                                  [self.navigationController popToRootViewControllerAnimated:NO];
                                                              } failure:^{}];
                                                          }];
    
    UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:yesAction];
    [alert addAction:noAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)setTotalStops:(NSInteger)totalStops {
    _totalStops = totalStops;
    self.totalStopsLabel.text = [NSString stringWithFormat:@"%ld", (long)totalStops];
    [self updateProgress];
}

- (void)setStopsVisited:(NSInteger)stopsVisited {
    _stopsVisited = stopsVisited;
    self.stopsVisitedLabel.text = [NSString stringWithFormat:@"%ld", (long)stopsVisited];
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

- (void)challengeCompleted {
    [self.timeElapsedLabel pause];
    [self.abortChallengeButton setTitle:@"DONE" forState:UIControlStateNormal];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"in_progress"];
    [defaults synchronize];
}


@end
