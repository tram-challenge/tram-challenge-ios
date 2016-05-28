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

@interface StopsViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) NSMutableArray *PageControlBtns;
@end

@implementation StopsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSUInteger numberOfPages = [[RouteData routeNames] count];

    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(numberOfPages * self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    [self.view addSubview:self.scrollView];
    
    self.PageControlBtns = [[NSMutableArray alloc] init];

    int btnSize = 22;
    int btnMargin = 2;
    int x_coord = (self.view.frame.size.width - (btnSize + btnMargin) * numberOfPages) / 2.0;
    
    for (int i = 0; i < numberOfPages; i++) {
        
        NSString *routeName = [[RouteData routeNames] objectAtIndex: i];
        NSMutableArray *stops = [[NSMutableArray alloc] init];
        
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
                [stops addObject:stop.name];
            }
            NSString *startStop = stops[0];
            NSString *endStop = stops[stops.count-1];
            titleLbl.text = [NSString stringWithFormat:@"%@ - %@", startStop, endStop];
        }];
        
        [self.scrollView addSubview:page];

        UIButton *pageControlBtn = [[UIButton alloc] initWithFrame:CGRectMake(x_coord + i * (btnSize + btnMargin), self.scrollView.frame.size.height - 20, btnSize, btnSize)];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
