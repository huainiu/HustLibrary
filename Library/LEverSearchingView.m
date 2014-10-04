//
//  LEverSearchingView.m
//  Library
//
//  Created by 陈颖鹏 on 14-9-12.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "LEverSearchingView.h"

@implementation LEverSearchingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        cellHeight = 40.0;
        
        // Get the ever searching terms
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"Ever_Searching"]) {
            self.everSearching = [NSArray array];
        } else {
            _everSearching = [[NSUserDefaults standardUserDefaults] objectForKey:@"Ever_Searching"];
        }
        _filterEverSearching = [_everSearching mutableCopy];
        
        // The tableView
        [self initTableView];
    }
    return self;
}

- (void)initTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.bounds];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self addSubview:tableView];
    _tableView = tableView;
}

- (void)setFilterTerm:(NSString *)term {
    if (term == nil || term.length == 0) {
        _filterEverSearching = [self.everSearching copy];
    } else {
        _filterEverSearching = [NSMutableArray array];
        for (NSInteger i = 0; i < [self.everSearching count]; i++) {
            if ([self.everSearching[i] rangeOfString:term].location != NSNotFound) {
                [self.filterEverSearching addObject:self.everSearching[i]];
            }
        }
    }
    [self.tableView reloadData];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma -
#pragma - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.noResultsLabel) {
        [self.noResultsLabel removeFromSuperview];
    }
    if ([self.filterEverSearching count] == 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 320, 80)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"无搜索结果";
        [self addSubview:label];
        _noResultsLabel = label;
    }
    return [self.filterEverSearching count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"everSearchingCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = self.filterEverSearching[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EverSearchingViewDidSelect" object:self userInfo:@{@"term": [self.filterEverSearching objectAtIndex:indexPath.row]}];
}

@end
