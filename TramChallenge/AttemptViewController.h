//
//  AttemptViewController.h
//  TramChallenge
//
//  Created by Joao Cardoso on 28/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MZTimerLabel/MZTimerLabel.h>
#import <MBCircularProgressBar/MBCircularProgressBarView.h>

@interface AttemptViewController : UIViewController

- (IBAction)abortChallenge:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *abortChallengeButton;
@property (weak, nonatomic) IBOutlet UIView *statsView;
@property (weak, nonatomic) IBOutlet MZTimerLabel *timeElapsedLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalStopsLabel;
@property (weak, nonatomic) IBOutlet UILabel *stopsVisitedLabel;
@property (assign, nonatomic) NSInteger stopsVisited;
@property (assign, nonatomic) NSInteger totalStops;
@property (weak, nonatomic) IBOutlet MBCircularProgressBarView *progressView;

@end
