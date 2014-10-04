//
//  LEverSearchingView.h
//  Library
//
//  Created by 陈颖鹏 on 14-9-12.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LEverSearchingView : UIView <UITableViewDelegate, UITableViewDataSource> {
    float cellHeight;
}

@property (strong, nonatomic) NSArray *everSearching;
@property (strong, nonatomic) NSMutableArray *filterEverSearching;

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UILabel *noResultsLabel;

- (void)setFilterTerm:(NSString *)term;

@end
