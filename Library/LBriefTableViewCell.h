//
//  LBriefTableViewCell.h
//  Library
//
//  Created by 陈颖鹏 on 14-9-13.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBriefTableViewCell : UITableViewCell {
    float cellHeight;
}

@property (strong, nonatomic) UIImageView *picView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *detailsLabel_one;
@property (strong, nonatomic) UILabel *detailsLabel_two;

@property (strong, nonatomic) NSArray *detailsLabels;

@property (nonatomic, weak) NSURLSessionDataTask *task;

- (void)clearAll;

@end
