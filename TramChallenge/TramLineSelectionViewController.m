//
//  TramLineSelectionViewController.m
//  TramChallenge
//
//  Created by Stephen Sykes on 27/05/16.
//  Copyright © 2016 Switchstep. All rights reserved.
//

#import "TramLineSelectionViewController.h"
#import "RouteData.h"
#import "TCUtilities.h"
#import <Masonry/Masonry.h>

#define TC_TRAMLINECELL_HEIGHT 39
#define TC_TRAMLINECELL_WIDTH 60

@interface TramLineCell : UITableViewCell

@property (nonatomic) UIButton *button;
@property (nonatomic) UIView *separator;

- (void)configureWithLineName:(NSString *)lineName
                         selected:(BOOL)selected;
@end

@interface TramLineSelectionViewController ()

@end


@implementation TramLineSelectionViewController


- (BOOL)automaticallyAdjustsScrollViewInsets
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UITableView *tableView = self.tableView;
    tableView.rowHeight = TC_TRAMLINECELL_HEIGHT;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.backgroundColor = [UIColor clearColor];

    [tableView registerClass:TramLineCell.class forCellReuseIdentifier:NSStringFromClass(TramLineCell.class)];
}

- (CGSize)preferredContentSize
{
    return CGSizeMake(TC_TRAMLINECELL_WIDTH, [RouteData routeNames].count * TC_TRAMLINECELL_HEIGHT);
}

#pragma mark - UITableViewDataSource + UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [RouteData routeNames].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger lineIndex = indexPath.row;
    NSString *lineName = [RouteData routeNames][lineIndex];
    BOOL selected = self.selectedLines.count ? [self.selectedLines containsObject:lineName] : YES;

    TramLineCell *cell = [TramLineCell tc_cast:[tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TramLineCell.class) forIndexPath:indexPath]];
    [cell configureWithLineName:lineName selected:selected];
    cell.separator.hidden = YES;

    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = [UIView new];
    cell.selectedBackgroundView = [UIView new];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *lineName = [RouteData routeNames][indexPath.row];

    if ([self.selectedLines containsObject:lineName]) {
        self.selectedLines = [self.selectedLines tc_setByRemovingObject:lineName];
    } else {
        self.selectedLines = [(self.selectedLines ?: [NSSet set]) setByAddingObject:lineName];
        if (self.selectedLines.count == [RouteData routeNames].count) {
            self.selectedLines = nil;
        }
    }

    [tableView reloadData];

    [self.delegate lineListDidChangeSelection:self];
}

@end

@implementation TramLineCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = CGRectMake(0, 0, TC_TRAMLINECELL_WIDTH, TC_TRAMLINECELL_HEIGHT);
        self.contentView.backgroundColor = [UIColor clearColor];
        _button = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = self.frame;
            button.tc_titleColor = [UIColor whiteColor];
            button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
            button.titleLabel.numberOfLines = 0;
            button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
            button.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            button.userInteractionEnabled = NO;
            [self.contentView addSubview:button];
            button;
        });
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)configureWithLineName:(NSString *)lineName
                         selected:(BOOL)selected
{
    self.button.tc_title = lineName;
    self.button.alpha = selected ? 1.0 : 0.35;

    self.button.layer.backgroundColor = [RouteData colorForRouteName:lineName].CGColor;
    self.button.layer.cornerRadius = 5;
}


@end
