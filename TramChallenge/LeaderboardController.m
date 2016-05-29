//
//  LeaderboardController.m
//  TramChallenge
//
//  Created by Joao Cardoso on 28/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import "LeaderboardController.h"
#import "TCAPIAdaptor.h"

@interface LeaderboardController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *leaderboard;
@end

@implementation LeaderboardController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.leaderboard = [[NSMutableArray alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [[TCAPIAdaptor instance] getLeaderboardWithSuccess:^(NSArray *leaderboard) {
        self.leaderboard = leaderboard;
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    } failure:^(NSError *error, NSInteger status, NSDictionary *info) {}];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.leaderboard count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor: indexPath.row % 2 == 0 ? [UIColor whiteColor] : [UIColor colorWithRed:0 green:0.6 blue:0.36 alpha:0.030]];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:15.0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"LeaderboardCell"];
    NSDictionary *team = [self.leaderboard objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@. %@", team[@"position"], team[@"name"]];
    cell.detailTextLabel.text = team[@"elapsed_time"];
    return cell;
}

@end
