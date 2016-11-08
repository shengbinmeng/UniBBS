//
//  UserInfoViewController.m
//  UniBBS
//
//  Created by fanyingming on 10/11/14.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import "UserInfoViewController.h"
#import "BDWMUserModel.h"
#import "MailListViewController.h"
#import "LoginViewController.h"
@interface UserInfoViewController ()
@property (retain, nonatomic) IBOutlet UILabel *userNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *loginTimesLabel;
@property (retain, nonatomic) IBOutlet UILabel *postingNumLabel;
@property (retain, nonatomic) IBOutlet UILabel *energyNumLabel;
@property (retain, nonatomic) IBOutlet UILabel *totalScoreLabel;
@property (retain, nonatomic) IBOutlet UILabel *originalScoreLabel;
@property (retain, nonatomic) IBOutlet UILabel *dutiesLabel;

@end

@implementation UserInfoViewController

- (void) logoutButtonPressed {
    [BDWMUserModel logout];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) backButtonPressed{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nil bundle:nil];
    
    if(self != nil)
    {
        self.title = @"个人信息";
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"注销" style:UIBarButtonItemStylePlain target:self action:@selector(logoutButtonPressed)];
    self.navigationItem.rightBarButtonItem = button;
    //always back to profile view.
    button = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
    self.navigationItem.leftBarButtonItem = button;
    
    if (self.userInfoDict==nil) {
        self.userInfoDict = [BDWMUserModel LoadUserInfo:[BDWMUserModel getLoginUser]];
    }
    self.userNameLabel.text = (NSString *)[self.userInfoDict objectForKey:@"nickname"];
    self.loginTimesLabel.text = [NSString stringWithFormat: @"%d", [[self.userInfoDict objectForKey:@"numlogins"] intValue]];
    self.postingNumLabel.text = [NSString stringWithFormat: @"%d", [[self.userInfoDict objectForKey:@"numposts"] intValue]];
    self.energyNumLabel.text = [NSString stringWithFormat: @"%d", [[self.userInfoDict objectForKey:@"life"] intValue]];
}

- (void)viewDidAppear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
