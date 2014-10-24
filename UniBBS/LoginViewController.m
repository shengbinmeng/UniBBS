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
        [BDWMAlertMessage alertAndAutoDismissMessage:@"请输入用户名"];
        return;
    }
    
    if (userPass.length==0) {
        [BDWMAlertMessage alertAndAutoDismissMessage:@"请输入密码"];
        return;
    }
    
    [BDWMUserModel checkLogin:userName userPass:userPass blockFunction:^(NSString *name, NSError *error){
        if ( !error && name!=nil ) {
            [BDWMUserModel saveUsernameAndPassword:userName userPassword:userPass];
            UserInfoViewController *userInfoViewController = [[[UserInfoViewController alloc] initWithNibName:@"UserInfoViewController" bundle:nil] autorelease];
            userInfoViewController.userName = userName;
            [self.navigationController pushViewController:userInfoViewController animated:YES];
            self.userNameTextField.text = @"";
            self.userPasswordTextField.text = @"";
        }else{
            self.userPasswordTextField.text = @"";
            [BDWMAlertMessage alertAndAutoDismissMessage:@"用户名或密码错误"];
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_userNameTextField release];
    [_userPasswordTextField release];
    [super dealloc];
}
@end
