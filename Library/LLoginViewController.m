//
//  LLoginViewController.m
//  Library
//
//  Created by 陈颖鹏 on 14-9-21.
//  Copyright (c) 2014年 UniqueStudio. All rights reserved.
//

#import "LLoginViewController.h"
#import "LLoadSelfInfoManager.h"
#import "ProgressHUD.h"

#define UIColorFromRGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface LLoginViewController ()

@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) UITextField *nameTextField;

@property (strong, nonatomic) UITextField *codeTextField;

@property (strong, nonatomic) UIButton *loginBtn;

@property (strong, nonatomic) UIButton *visitorBtn;

@end

@implementation LLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardWillChange:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 320, 200)];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.image = [UIImage imageNamed:@"loginBackground.png"];
    [self.view addSubview:self.imageView];
    
    _nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(47.5, 220, 225, 30)];
    UIView *inputAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 24)];
    UIButton *inputAccessoryBtn = [[UIButton alloc] initWithFrame:CGRectMake(260, 5, 60, 19)];
    [inputAccessoryBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [inputAccessoryBtn setTitle:@"完成" forState:UIControlStateNormal];
    [inputAccessoryBtn addTarget:self action:@selector(resignTheFirstResponder) forControlEvents:UIControlEventTouchUpInside];
    [inputAccessoryView addSubview:inputAccessoryBtn];
    [inputAccessoryView setBackgroundColor:UIColorFromRGBA(211, 214, 219, 1.0)];
    _nameTextField.inputAccessoryView = inputAccessoryView;
    _nameTextField.placeholder = @"Your Name";
//    _nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.nameTextField];
    
    UILabel *line1 = [[UILabel alloc] initWithFrame:CGRectMake(47.5, 249.5, 225, 1.0)];
    line1.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:line1];
    
    _codeTextField = [[UITextField alloc] initWithFrame:CGRectMake(47.5, 270, 225, 30)];
    _codeTextField.inputAccessoryView = inputAccessoryView;
//    [_codeTextField setSecureTextEntry:YES];
    _codeTextField.placeholder = @"Card Number";
//    _codeTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.codeTextField];
    
    UILabel *line2 = [[UILabel alloc] initWithFrame:CGRectMake(47.5, 299.5, 225, 1.0)];
    line2.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:line2];
    
    _loginBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _loginBtn.frame = CGRectMake(47.5, 320, 225, 30);
    _loginBtn.backgroundColor = UIColorFromRGBA(76, 220, 99, 1.0);
    [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [_loginBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loginBtn];
    
    _visitorBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _visitorBtn.frame = CGRectMake(47.5, 370, 225, 30);
    _visitorBtn.backgroundColor = [UIColor whiteColor];
    _visitorBtn.layer.borderWidth = 1.0;
    _visitorBtn.layer.borderColor = UIColorFromRGBA(76, 220, 99, 1.0).CGColor;
    [_visitorBtn setTitleColor:UIColorFromRGBA(76, 220, 99, 1.0) forState:UIControlStateNormal];
    [_visitorBtn setTitle:@"游客" forState:UIControlStateNormal];
    [self.view addSubview:self.visitorBtn];
    
}

- (void)loginAction {
    [[LLoadSelfInfoManager sharedManager] loadBorrowingBooksInfoWithName:self.nameTextField.text
                                                                    Code:self.codeTextField.text
                                                              Completion:^(NSArray *info, NSError *error, BOOL finished) {
                                                                  if (!finished) {
                                                                      [ProgressHUD showError:@"名字或密码错误" Interaction:NO];
                                                                  } else if (error) {
                                                                      [ProgressHUD showError:@"请检查你的网络状态" Interaction:NO];
                                                                  } else {
                                                                      [ProgressHUD showSuccess:@"登录成功"];
                                                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccessfully" object:self userInfo:@{@"info": info}];
                                                                      self.tabBarController.selectedIndex = 0;
                                                                  }
                                                              }];
}

- (void)keyBoardWillChange:(NSNotification *)notif {
    NSDictionary *userInfo = [notif userInfo];
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect rect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float endHeight = rect.origin.y;
    [UIView animateWithDuration:duration
                     animations:^{
                         if (endHeight != self.view.frame.size.height) {
                             self.view.transform = CGAffineTransformMakeTranslation(0, endHeight-self.nameTextField.center.y-100.0);
                         } else {
                             self.view.transform = CGAffineTransformIdentity;
                         }
                     }];
}

- (void)resignTheFirstResponder {
    if ([self.nameTextField isFirstResponder]) {
        [self.nameTextField resignFirstResponder];
    } else if ([self.codeTextField isFirstResponder]) {
        [self.codeTextField resignFirstResponder];
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
