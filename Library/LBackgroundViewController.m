//
//  LBackgroundViewController.m
//  Library
//
//  Created by 陈颖鹏 on 14-9-6.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "LBackgroundViewController.h"
#import "LHomeViewController.h"
#import "LRightDrawerView.h"

#define UIColorFromRGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

const NSTimeInterval kLLeftDrawerDefaultAnimationDuration = 0.25;

@interface LBackgroundViewController ()

@property (strong, nonatomic) LRightDrawerView *rightDrawerView;

@property (strong, nonatomic) LHomeViewController *homeView;
@property (strong, nonatomic) UIViewController *currentViewController;

@property (strong, nonatomic) UINavigationController *currentNavController;

@property (strong, nonatomic) NSMutableArray *navControllers;

@end

@implementation LBackgroundViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor whiteColor];
        _rightDrawerOn = NO;
        
        NSMutableArray *navControllers = [NSMutableArray array];
        _navControllers = navControllers;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UISwipeGestureRecognizer *swipeGestureFromRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showRightDrawer)];
    swipeGestureFromRight.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeGestureFromRight];
    
    // The homeView.
    LHomeViewController *homeView =[[LHomeViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:homeView];
    navController.navigationBar.barTintColor = UIColorFromRGBA(76, 220, 99, 1.0);
    navController.view.tag = 0;  // 0 for the homeView.
    [self.view addSubview:navController.view];
    self.homeView = homeView;
    self.currentViewController = homeView;
    self.currentNavController = navController;
    [self.navControllers addObject:navController];
}

- (void)showRightDrawer {
    if (!self.rightDrawerOn) {
        self.rightDrawerOn = YES;
        self.currentViewController.view.userInteractionEnabled = NO;
        if (self.homeView) {
            [self.homeView resignTheFirstResponder];
        }
        if (!self.blurView) {
            AMBlurView *blurView = [[AMBlurView alloc] initWithFrame:CGRectMake(0, 64, 320, self.view.frame.size.height-64)];
            blurView.alpha = 0.0;
            [self.view addSubview:blurView];
            _blurView = blurView;
        } else {
            [self.view addSubview:self.blurView];
        }
        if (!self.rightDrawerView) {
            LRightDrawerView *rightDrawerView = [[LRightDrawerView alloc] initWithFrame:CGRectMake(320, 64, 275, self.view.frame.size.height-64)];
            [rightDrawerView setModal:nil];
            [self.view addSubview:rightDrawerView];
            self.rightDrawerView = rightDrawerView;
        } else {
            [self.view bringSubviewToFront:self.rightDrawerView];
        }
        [UIView animateWithDuration:kLLeftDrawerDefaultAnimationDuration
                         animations:^{
                             self.blurView.alpha = 1.0;
                             self.rightDrawerView.transform = CGAffineTransformMakeTranslation(-275, 0);
                         } completion:nil];
    }
}

- (void)hideRightDrawer {
    if (self.rightDrawerOn) {
        self.rightDrawerOn = NO;
        self.currentViewController.view.userInteractionEnabled = YES;
        [UIView animateWithDuration:kLLeftDrawerDefaultAnimationDuration
                         animations:^{
                             self.blurView.alpha = 0.0;
                             self.rightDrawerView.transform = CGAffineTransformIdentity;
                         } completion:^(BOOL finished) {
                             [self.blurView removeFromSuperview];
                         }];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.rightDrawerOn) {
        [self hideRightDrawer];
    }
    if (self.homeView != nil) {
        [self.homeView resignTheFirstResponder];
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

@end
