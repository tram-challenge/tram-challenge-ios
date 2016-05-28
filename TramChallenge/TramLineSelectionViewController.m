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

- (NSArray<NSString *> *)lines
{
    return [RouteData routeNames];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UITableView *tableView = self.tableView;
    tableView.rowHeight = 42;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.showsVerticalScrollIndicator = NO;

    [tableView registerClass:TramLineCell.class forCellReuseIdentifier:NSStringFromClass(TramLineCell.class)];
}

- (CGSize)preferredContentSize
{
    return CGSizeMake(40, [self lines].count * 42);
}

#pragma mark - UITableViewDataSource + UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self lines].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger lineIndex = indexPath.row;
    NSString *lineName = [self lines][lineIndex];
    BOOL selected = self.selectedLines.count ? [self.selectedLines containsObject:lineName] : YES;

    TramLineCell *cell = [TramLineCell tc_cast:[tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TramLineCell.class) forIndexPath:indexPath]];
    [cell configureWithLineName:lineName selected:selected];
    cell.separator.hidden = (indexPath.row == [self lines].count - 1);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *lineName = [self lines][indexPath.row];

    if ([self.selectedLines containsObject:lineName]) {
        self.selectedLines = [self.selectedLines tc_setByRemovingObject:lineName];
    } else {
        self.selectedLines = [(self.selectedLines ?: [NSSet set]) setByAddingObject:lineName];
        if (self.selectedLines.count == [self lines].count) {
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
        _button = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
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
        _separator = ({
            UIView *view = [UIView new];
            view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
            [self.contentView addSubview:view];
            view;
        });
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)updateConstraints
{
    [self.button mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];

    [self.separator mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.equalTo(self.contentView);
        make.height.equalTo(@(1 / UIScreen.mainScreen.scale));
    }];

    [super updateConstraints];
}

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

- (void)configureWithLineName:(NSString *)lineName
                         selected:(BOOL)selected
{
    self.button.tc_title = lineName;
    self.button.alpha = selected ? 1.0 : 0.4;

    self.button.layer.backgroundColor = [RouteData colorForRouteName:lineName].CGColor;
    self.button.layer.cornerRadius = 5;
}


@end
