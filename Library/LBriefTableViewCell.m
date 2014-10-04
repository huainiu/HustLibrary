//
//  LBriefTableViewCell.m
//  Library
//
//  Created by 陈颖鹏 on 14-9-13.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "LBriefTableViewCell.h"

@implementation LBriefTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        cellHeight = 150.0;
        _picView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 90, 120)];
        self.picView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.picView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 20, 180, 48)];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        self.titleLabel.numberOfLines = 0;
        [self.contentView addSubview:self.titleLabel];
        
        _detailsLabel_one = [[UILabel alloc] initWithFrame:CGRectMake(110, 63, 180, 36)];
        self.detailsLabel_one.numberOfLines = 0;
        self.detailsLabel_one.font = [UIFont systemFontOfSize:12.0];
        [self.contentView addSubview:self.detailsLabel_one];
        
        _detailsLabel_two = [[UILabel alloc] initWithFrame:CGRectMake(110, 94, 180, 36)];
        self.detailsLabel_two.numberOfLines = 0;
        self.detailsLabel_two.font = [UIFont systemFontOfSize:12.0];
        [self.contentView addSubview:self.detailsLabel_two];
        
        _detailsLabels = @[self.detailsLabel_one, self.detailsLabel_two];
    }
    return self;
}

- (void)clearAll {
    self.picView.image = nil;
    self.titleLabel.text = nil;
    self.detailsLabel_one.text = nil;
    self.detailsLabel_two.text = nil;
    [self.task cancel];
    self.task = nil;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
