//
//  AttemptViewController.h
//  TramChallenge
//
//  Created by Joao Cardoso on 28/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AttemptViewController : UIViewController

- (IBAction)abortChallenge:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *abortChallengeButton;

@end
