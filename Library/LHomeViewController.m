//
//  LHomeViewController.m
//  Library
//
//  Created by 陈颖鹏 on 14-9-6.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "LHomeViewController.h"
#import "LLoadSelfInfoManager.h"
#import "LEverSearchingView.h"
#import "LSearchResultsViewController.h"
#import "LDetailsViewController.h"
#import "LLoadDetailsManager.h"
#import "ProgressHUD.h"
#import "LRightDrawerView.h"

@interface LHomeViewController () {
    float cellHeight;
    BOOL selfInfoLoaded;
}

@property (strong, nonatomic) UIView *selfInfoView;

@property (strong, nonatomic) LRightDrawerView *rightDrawerView;
@property (strong, nonatomic) UIToolbar *blurView;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UISearchBar *searchBar;

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *borrowingInfo;

@property (strong, nonatomic) LEverSearchingView *everSearchingView;

@end

@implementation LHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"有书";
        self.view.backgroundColor = [UIColor whiteColor];
        selfInfoLoaded = NO;
        cellHeight = 30.0;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!selfInfoLoaded) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"User_ID"]) {
            [self loadingSelfInfoShow];
        }
    }
}

- (void)loadingSelfInfoShow {
    [ProgressHUD show:@"正在加载个人借阅信息" Interaction:YES];
    selfInfoLoaded = YES;
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dismissProgressHUD) userInfo:nil repeats:NO];
}

- (void)dismissProgressHUD {
    [ProgressHUD dismiss];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _blurView = [[UIToolbar alloc] initWithFrame:self.view.bounds];
    self.blurView.barStyle = UIBarStyleDefault;
    self.blurView.alpha = 0.0;
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightDrawerShow)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeGesture];
    
    // The searchBar.
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 64, 320, 44)];
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    searchBar.placeholder = @"书名/ISBN/作者/出版社";
    searchBar.delegate = self;
    [self.view addSubview:searchBar];
    _searchBar = searchBar;
    
    // The scrollView.
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 108, 320, 125)];
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Propaganda.jpg"]];
    imageView.frame = self.scrollView.bounds;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.scrollView addSubview:imageView];
    
    _selfInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 233, 320, self.view.frame.size.height-233-44)];
    _selfInfoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.selfInfoView];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"User_ID"]) {
        
        [self initTableView:nil];
        
    } else {
        UIButton *loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 50, 320, 50)];
        [loginBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [loginBtn setTitle:@"你尚未登录,点击登录" forState:UIControlStateNormal];
        [loginBtn addTarget:self action:@selector(turnToLoginView) forControlEvents:UIControlEventTouchUpInside];
        [self.selfInfoView addSubview:loginBtn];
    }
}

- (void)initTableView:(NSArray *)selfInfo {
    _borrowingInfo = [NSMutableArray array];
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-233-44) style:UITableViewStylePlain];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.selfInfoView addSubview:tableView];
    _tableView = tableView;
    
    if (!selfInfo) {
        LLoadSelfInfoManager *manager = [LLoadSelfInfoManager sharedManager];
        [manager loadBorrowingBooksInfoWithName:[[NSUserDefaults standardUserDefaults] objectForKey:@"User_Name"]
                                           Code:[[NSUserDefaults standardUserDefaults] objectForKey:@"User_Code"]
                                     Completion:^(NSArray *info, NSError *error, BOOL finished) {
                                         if (!error) {
                                             for (NSInteger i = 0; i < [info count]; i++) {
                                                 NSMutableArray *aBook = [NSMutableArray arrayWithObjects:info[i][@"ID"], info[i][@"date"], nil];
                                                 [self.borrowingInfo addObject:aBook];
                                                 LLoadDetailsManager *loadDetailsManger = [LLoadDetailsManager sharedManager];
                                                 [loadDetailsManger loadingDetailsForTerm:info[i][@"ID"]
                                                                               Completion:^(NSDictionary *detailsInfo, NSError *error) {
                                                                                   [self.borrowingInfo[i] addObject:detailsInfo];
                                                                                   [self.tableView reloadData];
                                                                                   if (i == self.tableView.numberOfSections-1) {
                                                                                       [ProgressHUD showSuccess:@"加载个人借阅信息成功" Interaction:YES];
                                                                                   }
                                                                               }];
                                             }
                                         } else {
                                             [ProgressHUD showError:@"请检查你的网络状态" Interaction:NO];
                                         }
                                     }];
    } else {
        for (NSInteger i = 0; i < [selfInfo count]; i++) {
            NSMutableArray *aBook = [NSMutableArray arrayWithObjects:selfInfo[i][@"ID"], selfInfo[i][@"date"], nil];
            [self.borrowingInfo addObject:aBook];
            LLoadDetailsManager *loadDetailsManger = [LLoadDetailsManager sharedManager];
            [loadDetailsManger loadingDetailsForTerm:selfInfo[i][@"ID"]
                                          Completion:^(NSDictionary *detailsInfo, NSError *error) {
                                              [self.borrowingInfo[i] addObject:detailsInfo];
                                              [self.tableView reloadData];
                                              if (i == self.tableView.numberOfSections-1) {
                                                  [ProgressHUD showSuccess:@"加载个人借阅信息成功" Interaction:YES];
                                              }
                                          }];
        }
    }
}

- (void)turnToLoginView {
    UIViewController *vc = [self.tabBarController.viewControllers lastObject];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"LoginSuccessfully"
                                                      object:vc
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      for (NSInteger i = 0; i < [self.selfInfoView.subviews count]; i++) {
                                                          UIView *view = [self.selfInfoView.subviews objectAtIndex:i];
                                                          [view removeFromSuperview];
                                                      }
                                                      [self initTableView:[note.userInfo objectForKey:@"info"]];
                                                  }];
    self.tabBarController.selectedIndex = 3;
}

- (void)rightDrawerShow {
    for (NSInteger i = 0; i < [self.view.gestureRecognizers count]; i++) {
        UIGestureRecognizer *gesture = [self.view.gestureRecognizers objectAtIndex:i];
        [self.view removeGestureRecognizer:gesture];
    }
    [self resignTheFirstResponder];
    
    [self.view addSubview:self.blurView];
    _rightDrawerView = [[LRightDrawerView alloc] initWithFrame:CGRectMake(320, 64, 0, self.view.frame.size.height-64-44)];
    [self.rightDrawerView setData];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"RightDrawerViewDidSelect"
                                                      object:self.rightDrawerView
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self detailsForTerm:[[note userInfo] objectForKey:@"bookID"]];
                                                  }];
    [self.view addSubview:self.rightDrawerView];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.blurView.alpha = 1.0;
        self.rightDrawerView.frame = CGRectMake(320-275, 64, 275, self.view.frame.size.height-64);
    }];
}

- (void)resignTheFirstResponder {
    if (self.searchBar && [self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
}

- (void)searchForTerm:(NSString *)term {
    self.tabBarController.tabBar.hidden = YES;
    LSearchResultsViewController *searchResultsView = [[LSearchResultsViewController alloc] init];
    searchResultsView.searchStr = term;
    [self.navigationController pushViewController:searchResultsView animated:YES];
}

- (void)detailsForTerm:(NSString *)term {
    self.tabBarController.tabBar.hidden = YES;
    LDetailsViewController *detailsView = [[LDetailsViewController alloc] init];
    [detailsView loadDetailsWithID:term];
    [self.navigationController pushViewController:detailsView animated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.rightDrawerView) {
        __block LRightDrawerView *rightDrawerView = self.rightDrawerView;
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:@"RightDrawerViewDidSelect"
                                                      object:self.rightDrawerView];
        _rightDrawerView = nil;
        
        [UIView animateWithDuration:0.25 animations:^{
            self.blurView.alpha = 0.0;
            rightDrawerView.frame = CGRectMake(320, 64, 0, self.view.frame.size.height-64);
        } completion:^(BOOL finished) {
            [rightDrawerView removeFromSuperview];
            [self.blurView removeFromSuperview];
            
            UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightDrawerShow)];
            swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
            [self.view addGestureRecognizer:swipeGesture];
        }];
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
#pragma - UISearchBarDelegate methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [ProgressHUD dismiss];
    searchBar.showsCancelButton = YES;
    LEverSearchingView *everSearchingView = [[LEverSearchingView alloc] initWithFrame:CGRectMake(0, 108, 320, self.view.frame.size.height-108)];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"EverSearchingViewDidSelect"
                                                      object:everSearchingView queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self resignTheFirstResponder];
                                                      self.searchBar.text = [[note userInfo] objectForKey:@"term"];
                                                      [self searchForTerm:[[note userInfo] objectForKey:@"term"]];
                                                  }];
    [self.view addSubview:everSearchingView];
    _everSearchingView = everSearchingView;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self resignTheFirstResponder];
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar becomeFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"Ever_Searching"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@[searchBar.text] forKey:@"Ever_Searching"];
    } else {
        NSMutableArray *everSearching = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"Ever_Searching"]];
        for (NSInteger i = 0; i < [everSearching count]; i++) {
            if ([everSearching[i] isEqualToString:searchBar.text]) {
                [self searchForTerm:searchBar.text];
                [self.searchBar resignFirstResponder];
                return;
            }
        }
        [everSearching insertObject:searchBar.text atIndex:0];
        [[NSUserDefaults standardUserDefaults] setObject:everSearching forKey:@"Ever_Searching"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self searchForTerm:searchBar.text];
    [self.searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.everSearchingView setFilterTerm:searchText];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    [self.everSearchingView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"EverSearchingViewDidSelect" object:self.everSearchingView];
    self.everSearchingView = nil;
}

#pragma -
#pragma - UITableViewDelegate and UITableViewDataSource methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.borrowingInfo count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"selfInfoCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellIdentifier];
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, cellHeight)];
        nameLabel.font = [UIFont systemFontOfSize:12.0];
        nameLabel.textColor = [UIColor blackColor];
        [cell.contentView addSubview:nameLabel];
        
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 120, cellHeight)];
        infoLabel.font = [UIFont systemFontOfSize:12.0];
        infoLabel.textColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:infoLabel];
    } else {
        NSArray *subViews = cell.contentView.subviews;
        for (NSInteger i = 0; i < [subViews count]; i++) {
            UILabel *label = [subViews objectAtIndex:i];
            label.text = nil;
        }
    }
    
    if ([self.borrowingInfo[indexPath.row] count] > 2) {
        NSArray *subViews = cell.contentView.subviews;
        UILabel *nameLabel = [subViews objectAtIndex:0];
        nameLabel.text = self.borrowingInfo[indexPath.row][2][@"detailedInfo"][0][1];
        UILabel *infoLabel = [subViews objectAtIndex:1];
        infoLabel.text = self.borrowingInfo[indexPath.row][1];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
