//
//  TramLineSelectionViewController.h
//  TramChallenge
//
//  Created by Stephen Sykes on 27/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TramLineSelectionViewController;

@protocol TramLineSelectionDelegate <NSObject>

- (void)lineListDidChangeSelection:(TramLineSelectionViewController *)list;

@end

@interface TramLineSelectionViewController : UITableViewController

@property (nonatomic, copy) NSSet *selectedLines;

@property (nonatomic, weak) id<TramLineSelectionDelegate> delegate;

@end
