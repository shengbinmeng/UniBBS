//
//  LoginViewController.m
//  UniBBS
//
//  Created by Shengbin Meng on 14/10/11.
//  Copyright (c) 2014年 Peking University. All rights reserved.
//

#import "LoginViewController.h"
#import "UserInfoViewController.h"
#import "BDWMUserModel.h"
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
        self.title = @"登陆";
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        
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
    
    [BDWMUserModel checkLogin:userName userPass:userPass blockFunction:^(NSString *name, NSError *error){
        if ( !error && name!=nil ) {
            [BDWMUserModel saveUsernameAndPassword:userName userPassword:userPass];
            UserInfoViewController *userInfoViewController = [[[UserInfoViewController alloc] initWithNibName:@"UserInfoViewController" bundle:nil] autorelease];
            userInfoViewController.userName = userName;
            [self.navigationController pushViewController:userInfoViewController animated:YES];
            
        }else{
            self.userPasswordTextField.text = @"";
            [BDWMAlertMessage alertMessage:@"用户名或密码错误"];
        }
    }];
}

- (void)loadSavedUserData {
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaultes stringForKey:@"saved_username"];
    NSString *password = [userDefaultes stringForKey:@"saved_password"];
    
    if (username) {
        self.userNameTextField.text = username;
        if (password) {
            self.userPasswordTextField.text = password;
            [self clickLoginButton:nil];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self loadSavedUserData];//try auto login.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

- (void)dealloc {
    [_userNameTextField release];
    [_userPasswordTextField release];
    [super dealloc];
}
@end
