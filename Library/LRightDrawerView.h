//
//  LRightDrawerView.h
//  Library
//
//  Created by 陈颖鹏 on 14-9-12.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LRightDrawerView : UIView <UITableViewDelegate, UITableViewDataSource> {
    float cellHeaderHeight;
    float cellHeight;
}

@property (strong, nonatomic) NSArray *allIndexes;
@property (strong, nonatomic) NSArray *allIndexNames;

@property (strong, nonatomic) NSMutableArray *indexArr;
@property (strong, nonatomic) NSArray *sortedIndexArr;

@property (strong, nonatomic) NSMutableArray *dataSource;

@property (strong, nonatomic) NSMutableDictionary *filterDataSource;

@property (strong, nonatomic) UITableView *tableView;

- (void)setData;

@end
