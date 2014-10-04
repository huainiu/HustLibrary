//
//  LEverBorrowingBooksViewController.m
//  Library
//
//  Created by 陈颖鹏 on 14-9-21.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "LEverBorrowingBooksViewController.h"

@interface LEverBorrowingBooksViewController ()

@end

@implementation LEverBorrowingBooksViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"借阅";
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, 320, 100)];
    label.numberOfLines = 0;
    label.font = [UIFont boldSystemFontOfSize:18.0];
    label.text = @"本功能正在测试当中,本测试版本暂不开放,敬请期待。";
    [self.view addSubview:label];
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
