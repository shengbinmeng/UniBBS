//
//  LoginViewController.m
//  UniBBS
//
//  Created by Shengbin Meng on 14/10/11.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import "LoginViewController.h"
#import "UserInfoViewController.h"
#import "BDWMUserModel.h"
#import "BDWMAlertMessage.h"
#import "BDWMAlertMessage.h"


@interface LoginViewController ()
@property (retain, nonatomic) IBOutlet UITextField *userNameTextField;
@property (retain, nonatomic) IBOutlet UITextField *userPasswordTextField;
@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nil bundle:nil];
    
    if(self != nil)
    {
        self.title = @"登录";
    }
    return self;
}

- (IBAction)clickLoginButton:(id)sender {
    NSString *userName = self.userNameTextField.text;
    NSString *userPass = self.userPasswordTextField.text;
    
    if (userName.length==0 ) {
        [BDWMAlertMessage alertMessage:@"请输入用户名"];
        return;
    }
    
    if (userPass.length==0) {
        [BDWMAlertMessage alertMessage:@"请输入密码"];
        return;
    }
    
    [BDWMAlertMessage startSpinner:@"正在登录"];
    
    [BDWMUserModel checkLogin:userName userPass:userPass blockFunction:^(NSDictionary *responseDict, NSString *error){
        if (error == nil) {
            UserInfoViewController *userInfoViewController = [[UserInfoViewController alloc] initWithNibName:@"UserInfoViewController" bundle:nil];
            userInfoViewController.userName = userName;
            
            userInfoViewController.userInfoDict = responseDict;
            [BDWMAlertMessage stopSpinner];
            [self.navigationController pushViewController:userInfoViewController animated:YES];
            self.userNameTextField.text = @"";
            self.userPasswordTextField.text = @"";
        } else {
            [BDWMAlertMessage stopSpinner];
            self.userNameTextField.text = @"";
            self.userPasswordTextField.text = @"";
            [BDWMAlertMessage alertAndAutoDismissMessage:error];
        }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if( theTextField==self.userNameTextField ){
        [self.userPasswordTextField becomeFirstResponder];
    }else if( theTextField==self.userPasswordTextField){
        [self clickLoginButton:nil];
    }
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.userNameTextField.delegate = self;
    self.userPasswordTextField.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];

    [self.userNameTextField becomeFirstResponder];
    
    if (NO == [BDWMUserModel isLogined]) {
        NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
        NSString *userName = [userDefaultes stringForKey:@"saved_username"];
        NSString *password = [userDefaultes stringForKey:@"saved_password"];
        
        if( userName==nil || password==nil )
            return;
        self.userNameTextField.text = userName;
        self.userPasswordTextField.text = password;
        
        [self clickLoginButton:self];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
