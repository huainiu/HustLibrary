//
//  LRightDrawerView.m
//  Library
//
//  Created by 陈颖鹏 on 14-9-12.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "LRightDrawerView.h"
#import "LDBManager.h"

#define UIColorFromRGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@implementation LRightDrawerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        self.alpha = 0.8;
        self.userInteractionEnabled = YES;
        
        _filterDataSource = [NSMutableDictionary dictionary];
        _indexArr = [NSMutableArray array];
        _allIndexes = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"TB", @"TD", @"TE", @"TF", @"TG", @"TH", @"TJ", @"TK", @"TL", @"TM", @"TN", @"TP", @"TQ", @"TS", @"TU", @"TV", @"U", @"V", @"X", @"Z", nil];
        _allIndexNames = [NSArray arrayWithObjects:@"马列主义毛泽东思想", @"哲学", @"社会科学总论", @"政治法律", @"军事", @"经济", @"文化科学教育体育", @"语言、文字", @"文学", @"艺术", @"历史地理", @"自然科学总论", @"数理科学和化学", @"天文学、地球科学", @"生物科学", @"医药卫生", @"农业科学", @"工业技术", @" 一般工业技术", @"矿业工程", @"石油、天然气工业", @"冶金工业", @"金属学与金属工艺", @"机械、仪表工业", @"武器工业", @"能源与动力工程", @"原子能技术", @"电工技术", @"无线电电子学、电信技术", @"自动化技术、计算机技术", @"化学工业", @"轻工业、手工业", @"建筑科学", @"水利工程", @"交通运输", @"航空、航天", @"环境科学、安全科学", @"综合性图书", nil];
        
        cellHeaderHeight = 44.0;
        cellHeight = 40.0;
    }
    return self;
}

- (void)setData {
    NSMutableArray *fetchBookLists = [[LDBManager sharedManager] takeOutRecordsInEntity:@"BookLists"];
    for (NSInteger i = 0; i < [fetchBookLists count]; i++) {
        BookLists *tempBookLists = fetchBookLists[i];
        if ([tempBookLists.name isEqualToString:@"allInOneBookList"]) {
            _dataSource = tempBookLists.bookList;
            break;
        }
    }
    NSMutableArray *fetchBooksDetailedInfo = [[LDBManager sharedManager] takeOutRecordsInEntity:@"BooksDetailedInfo"];
    for (NSInteger i = 0; i < [self.dataSource count]; i++) {
        NSString *bookID = [self.dataSource objectAtIndex:i];
        for (NSInteger j = 0; j < [fetchBooksDetailedInfo count]; j++) {
            BooksDetailedInfo *tempBooksDetailedInfo = fetchBooksDetailedInfo[j];
            if ([tempBooksDetailedInfo.bookID isEqualToString:bookID]) {
                NSString *borrowingID = tempBooksDetailedInfo.borrowingID;
                if (!borrowingID || borrowingID.length == 0) {
                    NSMutableArray *others = [self.filterDataSource objectForKey:@"#"];
                    if (!others) {
                        others = [NSMutableArray arrayWithObject:@{@"name": tempBooksDetailedInfo.name,
                                                                 @"bookID": tempBooksDetailedInfo.bookID}];
                        [self.filterDataSource setObject:others forKey:@"#"];
                        [self.indexArr addObject:@"#"];
                    } else {
                        [others addObject:@{@"name": tempBooksDetailedInfo.name,
                                            @"bookID": tempBooksDetailedInfo.bookID}];
                    }
                } else {
                    NSString *index;
                    if ([borrowingID rangeOfString:@"TB, TD, TE, TF, TG, TH, TJ, TK, TL, TM, TP, TQ, TS, TU, TV"].location != NSNotFound) {
                        index = [borrowingID substringWithRange:NSMakeRange(0, 2)];
                    } else {
                        index = [borrowingID substringWithRange:NSMakeRange(0, 1)];
                    }
                    NSMutableArray *mutArr = [self.filterDataSource objectForKey:index];
                    if (!mutArr) {
                        mutArr = [NSMutableArray arrayWithObject:@{@"name": tempBooksDetailedInfo.name,
                                                                 @"bookID": tempBooksDetailedInfo.bookID,
                                                            @"borrowingID": tempBooksDetailedInfo.borrowingID}];
                        [self.filterDataSource setObject:mutArr forKey:index];
                        [self.indexArr addObject:index];
                    } else {
                        [mutArr addObject:@{@"name": tempBooksDetailedInfo.name,
                                            @"bookID": tempBooksDetailedInfo.bookID,
                                            @"borrowingID": tempBooksDetailedInfo.borrowingID}];
                    }
                }
                break;
            }
        }
    }
    
    _sortedIndexArr = [self.indexArr sortedArrayUsingSelector:@selector(compare:)];
    if ([self.sortedIndexArr count] > 0) {
        if ([self.sortedIndexArr.firstObject isEqualToString:@"#"]) {
            NSMutableArray *tempSortedMutArr = [NSMutableArray array];
            for (NSInteger i = 1; i < [self.sortedIndexArr count]; i++) {
                [tempSortedMutArr addObject:[self.sortedIndexArr objectAtIndex:i]];
            }
            [tempSortedMutArr addObject:[self.sortedIndexArr objectAtIndex:0]];
            _sortedIndexArr = [NSArray arrayWithArray:tempSortedMutArr];
        }
    }
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 275, self.bounds.size.height)
                                                          style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
//    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.separatorColor = UIColorFromRGBA(76, 220, 99, 1.0);
    [self addSubview:tableView];
    self.tableView = tableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sortedIndexArr count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.filterDataSource objectForKey:[self.sortedIndexArr objectAtIndex:section]] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return cellHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 275, cellHeaderHeight)];
    label.textColor = UIColorFromRGBA(76, 220, 99, 1.0);
    label.font = [UIFont boldSystemFontOfSize:cellHeaderHeight/2];
    NSString *index = [self.sortedIndexArr objectAtIndex:section];
    for (NSInteger i = 0; i < [self.allIndexes count]; i++) {
        NSString *tempIndex = [self.allIndexes objectAtIndex:i];
        if ([tempIndex isEqualToString:index]) {
            label.text = [self.allIndexNames objectAtIndex:i];
            break;
        }
    }
    if (!label.text || label.text.length == 0) {
        label.text = @"其他类";
    }

    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:cellHeight/3];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:cellHeight/3];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    }
    cell.textLabel.text = [[[self.filterDataSource objectForKey:[self.sortedIndexArr objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.detailTextLabel.text = [[[self.filterDataSource objectForKey:[self.sortedIndexArr objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] objectForKey:@"borrowingID"];
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.sortedIndexArr;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *bookID = [[[self.filterDataSource objectForKey:[self.sortedIndexArr objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] objectForKey:@"bookID"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RightDrawerViewDidSelect"
                                                        object:self
                                                      userInfo:@{@"bookID": bookID}];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
