//
//  LSearchResultsViewController.m
//  Library
//
//  Created by 陈颖鹏 on 14-9-13.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "LSearchResultsViewController.h"
#import "LLoadBriefManager.h"
#import "LBriefTableViewCell.h"
#import "LDetailsViewController.h"
#import "LLoadImagesManager.h"
#import "MJRefresh.h"
#import "ProgressHUD.h"

@interface LSearchResultsViewController () {
    int beginNum;
    int endNum;
    BOOL end;
    BOOL haveBeenBegan;
    NSString *baseURL;
}

@property (nonatomic, weak) NSURLSessionDataTask *currentTask;

@property (strong, nonatomic) NSMutableArray *briefInfo;

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation LSearchResultsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"搜索";
        self.view.backgroundColor = [UIColor whiteColor];
        baseURL = @"http://ftp.lib.hust.edu.cn";
        cellHeight = 150.0;
        _briefInfo = [NSMutableArray array];
        end = NO;
        haveBeenBegan = NO;
        beginNum = -9;
        endNum = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!haveBeenBegan) {
        [self loadBriefWithTerm:self.searchStr];
        haveBeenBegan = YES;
    }
}

- (void)loadBriefWithTerm:(NSString *)searchStr {
    beginNum += 10;
    endNum += 10;
    
    [ProgressHUD show:@"正在加载" Interaction:YES];
    
    NSString *encodedSearchStr = [searchStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *partOne = @"/search*chx?/X";
    NSString *partTwo = @"&SORT=D/X";
    NSString *partThree = @"&SORT=D&SUBKEY=";
    NSString *partFour = @"%2C";
    NSString *partFive = @"B/browse";
    ////https://ftp.lib.hust.edu.cn/search*chx?/XiOS&SORT=D/XiOS&SORT=D&SUBKEY=iOS/51%2C119%2C119%2CB/browse
    NSString *urlStr = [NSString stringWithFormat:@"%@%@%@%@%@%@/%d%@%d%@10000%@%@", partOne, encodedSearchStr, partTwo, encodedSearchStr, partThree, encodedSearchStr, beginNum, partFour, endNum, partFour, partFour, partFive];
    NSLog(@"%@", urlStr);
    LLoadBriefManager *manager = [LLoadBriefManager sharedManager];
    NSURLSessionDataTask *task = [manager loadingBriefForTerm:urlStr
                                                   Completion:^(NSDictionary *briefInfo, NSError *error, BOOL finished) {
                                                       if (!finished) {
                                                           [ProgressHUD showError:@"无更多书目" Interaction:YES];
                                                           end = YES;
                                                           [self.tableView reloadData];
                                                           [self.tableView footerEndRefreshing];
                                                           [self.tableView removeFooter];
                                                       } else {
                                                           if (!error) {
                                                               [ProgressHUD showSuccess:@"加载成功" Interaction:YES];
                                                               [self.briefInfo addObject:briefInfo];
                                                               if (!self.tableView) {
                                                                   [self initTableView];
                                                               } else {
                                                                   [self.tableView reloadData];
                                                                   [self.tableView footerEndRefreshing];
                                                               }
                                                           } else {
                                                               [ProgressHUD showError:@"请检查你的网络状态" Interaction:NO];
                                                               [self.navigationController popViewControllerAnimated:YES];
                                                           }
                                                       }
                                                   }];
    _currentTask = task;
}

- (void)initTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 320, self.view.frame.size.height-64) style:UITableViewStyleGrouped];
    self.automaticallyAdjustsScrollViewInsets = NO;
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView addFooterWithTarget:self action:@selector(refresh)];
    [tableView setFooterPullToRefreshText:@"下拉加载更多..."];
    [tableView setFooterReleaseToRefreshText:@"松开加载更多..."];
    [tableView setFooterRefreshingText:@"正在加载..."];
    [self.view addSubview:tableView];
    _tableView = tableView;
}

- (void)refresh {
    if (!end) {
        [self loadBriefWithTerm:self.searchStr];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma - 
#pragma - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.briefInfo count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.briefInfo[section][@"booksBriefInfo"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"briefCellIdentifier";
    LBriefTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[LBriefTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    } else {
        [cell clearAll];
    }
    
    LLoadImagesManager *manager = [LLoadImagesManager sharedManager];
    cell.task = [manager loadingImagesForTerm:self.briefInfo[indexPath.section][@"booksBriefInfo"][indexPath.row][@"bookID"]
                       Completion:^(UIImage *image, NSError *error) {
                           cell.picView.image = image;
                       }];
    
    cell.titleLabel.text = [self.briefInfo[indexPath.section][@"booksBriefInfo"][indexPath.row] objectForKey:@"name"];
    NSArray *detailsArr = [self.briefInfo[indexPath.section][@"booksBriefInfo"][indexPath.row] objectForKey:@"briefInfo"];
    for (NSInteger i = 0; i < MIN([detailsArr count], [cell.detailsLabels count]); i++) {
        UILabel *label = cell.detailsLabels[i];
        label.text = detailsArr[i];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LDetailsViewController *detailsView = [[LDetailsViewController alloc] init];
    [detailsView loadDetailsWithID:[self.briefInfo[indexPath.section][@"booksBriefInfo"][indexPath.row] objectForKey:@"bookID"]];
    [self.navigationController pushViewController:detailsView animated:YES];
//    if (self.tableView.frame.origin.y == 64) {
//        self.tableView.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
//    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (end && section == self.tableView.numberOfSections-1) {
        return @"无更多书目";
    }
    return nil;
}

@end
