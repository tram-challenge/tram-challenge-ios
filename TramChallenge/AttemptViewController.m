//
//  AttemptViewController.m
//  TramChallenge
//
//  Created by Joao Cardoso on 28/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import "AttemptViewController.h"

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

@end
