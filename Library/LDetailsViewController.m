//
//  LDetailsViewController.m
//  Library
//
//  Created by 陈颖鹏 on 14-9-13.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "LDetailsViewController.h"
#import "LLoadImagesManager.h"
#import "LLoadDetailsManager.h"
#import "ProgressHUD.h"
#import "LDBManager.h"

#define UIColorFromRGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface LDetailsViewController () {
    NSString *bookID;
}

@property (strong, nonatomic) UISegmentedControl *segmentedControl;

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) UIScrollView *scrollView;
//@property (strong, nonatomic) UIScrollView *bookDescriptionScrollView;
//@property (strong, nonatomic) UIScrollView *bookCollectionScrollView;
@property (strong, nonatomic) UIView *descriptionView;
@property (strong, nonatomic) UIView *collectionInfoView;

@property (strong, nonatomic) UIToolbar *toolBar;
@property (strong, nonatomic) UIButton *addToListBtn;
@property (strong, nonatomic) UIButton *addToDefaultListBtn;

@end

@implementation LDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"详情";
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-44)];
    _scrollView.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.view addSubview:self.scrollView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(110, 84, 100, 100)];
    imageView.contentMode = UIViewContentModeScaleToFill;
    [self.scrollView addSubview:imageView];
    _imageView = imageView;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 194, 320, 42)];
    titleLabel.numberOfLines = 0;
    titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:titleLabel];
    _titleLabel = titleLabel;
    
    NSArray *segmentedArr = [NSArray arrayWithObjects:@"图书描述", @"馆藏信息", nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentedArr];
    segmentedControl.tintColor = UIColorFromRGBA(76, 220, 99, 1.0);
    segmentedControl.frame = CGRectMake(19.75, 246, 280.5, 22);
    segmentedControl.selectedSegmentIndex = 0;
    [segmentedControl addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:segmentedControl];
    _segmentedControl = segmentedControl;
    
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-44, 320, 44)];
    
    UIButton *addToListBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    addToListBtn.backgroundColor = [UIColor clearColor];
    addToListBtn.layer.borderColor = [UIColor grayColor].CGColor;
    addToListBtn.layer.borderWidth = 1.0;
    [addToListBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [addToListBtn setTitle:@"加入书单" forState:UIControlStateNormal];
    [addToListBtn addTarget:self action:@selector(addToList) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addToListBarBtn = [[UIBarButtonItem alloc] initWithCustomView:addToListBtn];
    UIBarButtonItem *flexibleBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                 target:nil
                                                                                 action:nil];
    _addToListBtn = addToListBtn;
    
    UIButton *addToDefaultListBtn = [[UIButton alloc] initWithFrame:addToListBtn.frame];
    addToDefaultListBtn.backgroundColor = [UIColor clearColor];
    addToDefaultListBtn.layer.borderColor = [UIColor grayColor].CGColor;
    addToDefaultListBtn.layer.borderWidth = 1.0;
    [addToDefaultListBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [addToDefaultListBtn setTitle:@"收藏" forState:UIControlStateNormal];
    [addToDefaultListBtn addTarget:self action:@selector(addtoDefaultList) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addToDefaultListBarBtn = [[UIBarButtonItem alloc] initWithCustomView:addToDefaultListBtn];
    _addToDefaultListBtn = addToDefaultListBtn;
    
    [self.toolBar setItems:@[flexibleBtn, addToListBarBtn, flexibleBtn, addToDefaultListBarBtn, flexibleBtn]];
    [self.view addSubview:self.toolBar];
}

- (void)addToList {
    [ProgressHUD showSuccess:@"已加入书单" Interaction:NO];
}

- (void)addtoDefaultList {
    [[LDBManager sharedManager] addObject:@{@"name": @"defaultBookList",
                                          @"bookID": bookID}
                                 toEntity:@"BookLists"];
    
    [self.addToDefaultListBtn setBackgroundColor:UIColorFromRGBA(76, 220, 99, 1.0)];
    self.addToDefaultListBtn.layer.borderWidth = 0.0;
    [self.addToDefaultListBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.addToDefaultListBtn setTitle:@"已加入收藏" forState:UIControlStateNormal];
    [ProgressHUD showSuccess:@"已加入收藏" Interaction:NO];
    
}

- (void)segmentedControlAction:(UISegmentedControl *)seg {
    switch (seg.selectedSegmentIndex) {
        case 0:
            [self.collectionInfoView removeFromSuperview];
            self.scrollView.contentSize = CGSizeMake(320, 288+self.descriptionView.frame.size.height);
            [self.scrollView addSubview:self.descriptionView];
            [self.scrollView scrollRectToVisible:CGRectMake(0, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height) animated:YES];
            break;
        case 1:
            [self.descriptionView removeFromSuperview];
            if (self.collectionInfoView) {
                self.scrollView.contentSize = CGSizeMake(320, 288+self.collectionInfoView.frame.size.height);
                [self.scrollView addSubview:self.collectionInfoView];
                [self.scrollView scrollRectToVisible:CGRectMake(0, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height) animated:YES];
            }
            break;
        default:
            break;
    }
}

- (void)loadDetailsWithID:(NSString *)ID {
    bookID = ID;
    LLoadImagesManager *loadImageManager = [LLoadImagesManager sharedManager];
    [loadImageManager loadingImagesForTerm:ID
                                Completion:^(UIImage *image, NSError *error) {
                                    self.imageView.image = image;
                                }];
    LLoadDetailsManager *loadDetailsManager = [LLoadDetailsManager sharedManager];
    [loadDetailsManager loadingDetailsForTerm:ID
                       Completion:^(NSDictionary *detailsInfo, NSError *error) {
                           if (self.descriptionView) {
                               [self.descriptionView removeFromSuperview];
                               self.descriptionView = nil;
                           }
                           self.titleLabel.text = detailsInfo[@"detailedInfo"][0][1];
                           _descriptionView = [[UIView alloc] initWithFrame:CGRectMake(20, 288, 280, 0)];
                           [self.scrollView addSubview:self.descriptionView];
                           
                           NSInteger descriptionCount = [detailsInfo[@"detailedInfo"] count];
                           NSArray *detailsArr = detailsInfo[@"detailedInfo"];
                           float titleLabelWidth = 80;
                           for (NSInteger i = 1; i < descriptionCount; i++) {
                               static float totalHeight = 0;
                               UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, totalHeight, titleLabelWidth, 19.0)];
                               titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
                               titleLabel.text = [detailsArr[i][0] stringByAppendingString:@": "];
                               [self.descriptionView addSubview:titleLabel];
                               
                               NSString *text = detailsArr[i][1];
                               for (NSInteger j = 2; j < [detailsArr[i] count]-1; j++) {
                                   text = [text stringByAppendingString:[NSString stringWithFormat:@"\n%@", detailsArr[i][j]]];
                               }
                               NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text
                                                                                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0]}];
                               CGRect rect = [attributedText boundingRectWithSize:(CGSize){self.descriptionView.bounds.size.width-titleLabelWidth, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                               UILabel *detailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelWidth, totalHeight, rect.size.width, MAX(rect.size.height, 19.0))];
                               detailsLabel.numberOfLines = 0;
                               detailsLabel.font = [UIFont systemFontOfSize:12.0];
                               detailsLabel.text = text;
                               [self.descriptionView addSubview:detailsLabel];
                               
                               totalHeight += MAX(rect.size.height, 19.0);
                               if (i == descriptionCount-1) {
                                   self.descriptionView.frame = CGRectMake(self.descriptionView.frame.origin.x, self.descriptionView.frame.origin.y, self.descriptionView.frame.size.width, totalHeight);
                                   self.scrollView.contentSize = CGSizeMake(320, 288+totalHeight);
                                   totalHeight = 0;
                               }
                           }
                           
                           NSDictionary *collectionInfo = detailsInfo[@"collectionInfo"];
                           if (collectionInfo) {
                               _collectionInfoView = [[UIView alloc] initWithFrame:(CGRect){self.descriptionView.frame.origin, CGSizeMake(self.descriptionView.frame.size.width, 0)}];
                               
                               NSInteger collectionType = [collectionInfo[@"type"] integerValue];
                               if (collectionType == 0) {
                                   NSArray *collection = collectionInfo[@"collection"];
                                   for (NSInteger i = 0; i < [collection count]; i++) {
                                       static float totalHeight = 0;
                                       
                                       NSString *text = collection[i];
                                       NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text
                                                                                                            attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]}];
                                       CGRect rect = [attributedText boundingRectWithSize:(CGSize){self.collectionInfoView.bounds.size.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                                       UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, totalHeight, rect.size.width, rect.size.height)];
                                       label.font = [UIFont systemFontOfSize:14.0];
                                       label.numberOfLines = 0;
                                       label.text = text;
                                       [self.collectionInfoView addSubview:label];
                                       
                                       totalHeight += MAX(rect.size.height, 14.0);
                                       if (i == [collection count]-1) {
                                           self.collectionInfoView.frame = CGRectMake(self.collectionInfoView.frame.origin.x, self.collectionInfoView.frame.origin.y, self.collectionInfoView.frame.size.width, totalHeight);
                                           totalHeight = 0;
                                       }
                                   }
                               } else {
                                   NSArray *collection = collectionInfo[@"collection"];
                                   for (NSInteger i = 0; i < [collection count]; i++) {
                                       static float totalHeight = 0;
                                       NSArray *partCollection = collection[i];
                                       
                                       UILabel *placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, totalHeight, self.collectionInfoView.bounds.size.width*0.6, 30)];
                                       placeLabel.font = [UIFont systemFontOfSize:14.0];
                                       placeLabel.text = [partCollection firstObject];
                                       [self.collectionInfoView addSubview:placeLabel];
                                       
                                       UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.collectionInfoView.bounds.size.width*0.6, totalHeight, self.collectionInfoView.bounds.size.width*0.4, 30)];
                                       infoLabel.font = [UIFont systemFontOfSize:14.0];
                                       infoLabel.text = [partCollection lastObject];
                                       [self.collectionInfoView addSubview:infoLabel];
                                       
                                       totalHeight += 30;
                                       
                                       if (i == [collection count]-1) {
                                           self.collectionInfoView.frame = CGRectMake(self.collectionInfoView.frame.origin.x, self.collectionInfoView.frame.origin.y, self.collectionInfoView.frame.size.width, totalHeight);
                                           totalHeight = 0;
                                       }
                                   }
                               }
                           }
                       }];
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

@end
