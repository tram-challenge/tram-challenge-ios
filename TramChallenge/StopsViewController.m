//
//  StopsViewController.m
//  TramChallenge
//
//  Created by Krister Kari on 28/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import "StopsViewController.h"
#import "RouteData.h"
#import "TCTramRoute.h"
#import "TCTramStop.h"
#import "TCAPIAdaptor.h"

@interface StopsViewController () <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource> {
    BOOL _setup;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) NSMutableArray *PageControlBtns;
@property (nonatomic) NSMutableDictionary *routes;
@end

@implementation StopsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _setup = NO;
}

- (void)viewDidLayoutSubviews {
    [self setup];
}

- (void)viewDidAppear:(BOOL)animated {
    [self updateVisitedStops];
}

- (void)setup {
    if (_setup) {
        return;
    }
    _setup = YES;

    NSUInteger numberOfPages = [[RouteData routeNames] count];

    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(numberOfPages * self.scrollView.frame.size.width, self.scrollView.frame.size.height);

    self.PageControlBtns = [[NSMutableArray alloc] init];
    self.routes = [[NSMutableDictionary alloc] init];

    int btnSize = 22;
    int btnMargin = 2;
    int x_coord = (self.view.frame.size.width - (btnSize + btnMargin) * numberOfPages) / 2.0;

    for (int i = 0; i < numberOfPages; i++) {

        NSString *routeName = [[RouteData routeNames] objectAtIndex: i];
        NSMutableArray<TCTramStop *> *stops = [[NSMutableArray alloc] init];

        UIView *page = [[UIView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width * i, 0.0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];

        UILabel *numberLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 40, 40)];
        numberLbl.backgroundColor = [RouteData colorForRouteName: routeName];
        numberLbl.textColor = [UIColor whiteColor];
        numberLbl.font = [UIFont boldSystemFontOfSize:16.0];
        numberLbl.text = routeName;
        numberLbl.clipsToBounds = YES;
        numberLbl.layer.cornerRadius = 5;
        numberLbl.textAlignment = NSTextAlignmentCenter;

        [page addSubview:numberLbl];

        UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(70, 20.0, page.frame.size.width-20.0, 40.0)];
        titleLbl.textColor = [RouteData colorForRouteName: routeName];
        titleLbl.font = [UIFont boldSystemFontOfSize:18.0];
        [page addSubview:titleLbl];

        [[RouteData instance] fetchStopsSuccess:^{

            for (TCTramStop *stop in [[RouteData instance] stopsForRoute:routeName]) {
                [stops addObject:stop];
            }
            [self.routes setObject:stops forKey:[NSString stringWithFormat:@"%d", i]];
            NSString *startStop = stops[0].name;
            NSString *endStop = stops[stops.count-1].name;
            titleLbl.text = [NSString stringWithFormat:@"%@ - %@", startStop, endStop];

            UITableView *tableView = [[UITableView alloc] initWithFrame: CGRectMake(20, 80, self.scrollView.frame.size.width, self.scrollView.frame.size.height - 130) style:UITableViewStylePlain];
            tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.rowHeight = 42;
            tableView.allowsMultipleSelection = YES;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.showsVerticalScrollIndicator = NO;
            tableView.tag = i + 100;
            [page addSubview:tableView];
        }];

        [self.scrollView addSubview:page];

        UIButton *pageControlBtn = [[UIButton alloc] initWithFrame:CGRectMake(x_coord + i * (btnSize + btnMargin), self.scrollView.frame.size.height + 24, btnSize, btnSize)];
        pageControlBtn.alpha = i == 0 ? 1 : 0.4;
        pageControlBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        [pageControlBtn setTitle:routeName forState:UIControlStateNormal];
        [pageControlBtn setTag:i + 2000];
        pageControlBtn.layer.cornerRadius = 4;

        pageControlBtn.backgroundColor = [RouteData colorForRouteName: routeName];
        [pageControlBtn addTarget:self action:@selector(onPageControlBtnPressed:) forControlEvents:UIControlEventTouchUpInside];

        [self.view addSubview:pageControlBtn];

        [self.PageControlBtns addObject:pageControlBtn];
    }
    
    [self updateVisitedStops];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.routes valueForKey: [NSString stringWithFormat:@"%ld",(long)tableView.tag-100]] count];
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    UIView *transparentBackground = [[UIView alloc] initWithFrame:cell.bounds];
    transparentBackground.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    transparentBackground.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = transparentBackground;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[TCAPIAdaptor instance] attemptInProgress];
}

- (void)selectStop:(UITableViewCell *)cell
{
    UIView *whiteBulletView = [cell viewWithTag:1];
    cell.imageView.alpha = 1;
    whiteBulletView.hidden = YES;
}

- (void)deselectStop:(UITableViewCell *) cell
{
    UIView *whiteBulletView = [cell viewWithTag:1];
    cell.imageView.alpha = 0.5;
    whiteBulletView.hidden = NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [[[self.routes valueForKey: [NSString stringWithFormat:@"%ld",(long)tableView.tag-100]] objectAtIndex:indexPath.row] markVisited];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self selectStop:cell];
    [self updateVisitedStops];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[[self.routes valueForKey: [NSString stringWithFormat:@"%ld",(long)tableView.tag-100]] objectAtIndex:indexPath.row] markUnvisited];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self deselectStop:cell];
    [self updateVisitedStops];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"StopsTableCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    NSString *stopName = [[[self.routes valueForKey: [NSString stringWithFormat:@"%ld",(long)tableView.tag-100]] objectAtIndex:indexPath.row] name];
    NSString *routeName = [[RouteData routeNames] objectAtIndex: (long)tableView.tag-100];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];

        int bullet = 32;

        CGRect bulletRect = CGRectMake(0, 0, bullet, bullet);
        UIGraphicsBeginImageContext(bulletRect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();

        CGContextSetFillColorWithColor(context, [RouteData colorForRouteName: routeName].CGColor);
        CGContextFillRect(context, bulletRect);

        UIImage *bulletImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        cell.imageView.image = bulletImage;
        cell.imageView.alpha = 0.5;
        cell.imageView.layer.cornerRadius = bullet / 2;
        cell.imageView.layer.masksToBounds = YES;

        CGRect inner = CGRectMake(0, 0, bullet, bullet);
        UIGraphicsBeginImageContext(inner.size);
        CGContextRef innerContext = UIGraphicsGetCurrentContext();

        CGContextSetFillColorWithColor(innerContext, [UIColor whiteColor].CGColor);
        CGContextFillRect(innerContext, inner);

        UIImage *innerImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        UIImageView *whiteBulletView = [[UIImageView alloc] init];
        whiteBulletView.frame = CGRectMake(bullet / 4, bullet / 4, bullet / 2, bullet / 2);
        whiteBulletView.image = innerImage;
        whiteBulletView.layer.cornerRadius = bullet / 4;
        whiteBulletView.layer.masksToBounds = YES;
        whiteBulletView.alpha = 1;
        whiteBulletView.tag = 1;
        [cell.imageView addSubview:whiteBulletView];

        cell.textLabel.textColor = [RouteData colorForRouteName: routeName];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
    }
    
    if ([[tableView indexPathsForSelectedRows] containsObject: indexPath]) {
        [self selectStop:cell];
    } else {
        [self deselectStop:cell];
    }
    
    cell.textLabel.text = stopName;
    UIView *transparentBackground = [[UIView alloc] initWithFrame:cell.bounds];
    transparentBackground.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    transparentBackground.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = transparentBackground;
    return cell;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)sender
{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    [self SetActivePageControlWithIndex:page];
}


-(void)onPageControlBtnPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;

    int tag = (int)button.tag - 2000;

    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * tag, 0) animated:YES];

    [self SetActivePageControlWithIndex:tag];
}


-(void)SetActivePageControlWithIndex:(int)index
{
    for (int i=0; i<[self.PageControlBtns count]; i++)
    {
        UIButton *button = [self.PageControlBtns objectAtIndex:i];
        button.alpha = 0.4;
    }
    UIButton *button = [self.PageControlBtns objectAtIndex:index];
    button.alpha = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateVisitedStops {
    NSUInteger numberOfPages = [[RouteData routeNames] count];

    for (int i = 0; i < numberOfPages; i++) {
        UITableView *tableView = [self.view viewWithTag:i+100];
        
        NSArray *stops = [self.routes valueForKey: [NSString stringWithFormat:@"%ld",(long)tableView.tag-100]];
        
        for (int j = 0; j < stops.count; j++) {
            TCTramStop *stop = stops[j];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:0];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if (stop.visited) {
                [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                [self selectStop:cell];
            } else {
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
                [self deselectStop:cell];
            }
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
