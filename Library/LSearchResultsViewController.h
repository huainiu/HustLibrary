//
//  LSearchResultsViewController.h
//  Library
//
//  Created by 陈颖鹏 on 14-9-13.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSearchResultsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    float cellHeight;
}

@property (nonatomic, copy) NSString *searchStr;

- (void)loadBriefWithTerm:(NSString *)searchStr;

@end
