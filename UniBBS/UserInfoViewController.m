//
//  UserInfoViewController.m
//  UniBBS
//
//  Created by fanyingming on 10/11/14.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import "UserInfoViewController.h"
#import "BDWMUserModel.h"
#import "MailListTableViewController.h"
#import "LoginViewController.h"
@interface UserInfoViewController ()
@property (retain, nonatomic) IBOutlet UILabel *userNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *loginTimesLabel;
@property (retain, nonatomic) IBOutlet UILabel *postingNumLabel;
@property (retain, nonatomic) IBOutlet UILabel *energyNumLabel;
@property (retain, nonatomic) IBOutlet UILabel *totalScoreLabel;
@property (retain, nonatomic) IBOutlet UILabel *originalScoreLabel;

@end

@implementation UserInfoViewController

- (void) logoutButtonPressed {
    [BDWMUserModel logout];
    [LoginViewController setUnlogined];
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nil bundle:nil];
    
    if(self != nil)
    {
        self.title = @"个人信息";
        
    }
    return self;
}

- (void)segueToUserMail
{
    MailListTableViewController *mailListViewController = [[[MailListTableViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    mailListViewController.userName = self.userName;
    [self.navigationController pushViewController:mailListViewController animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"注销" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutButtonPressed)];
    self.navigationItem.leftBarButtonItem = button;
    [button release];
    
    button = [[UIBarButtonItem alloc] initWithTitle:@"站内信" style:UIBarButtonItemStyleBordered target:self action:@selector(segueToUserMail)];
    self.navigationItem.rightBarButtonItem = button;
    [button release];
    
    NSMutableDictionary *userInfoDict = [BDWMUserModel LoadUserInfo:self.userName];
    self.userNameLabel.text = [userInfoDict objectForKey:@"userName"];
    self.loginTimesLabel.text = [userInfoDict objectForKey:@"loginTimes"];
    self.postingNumLabel.text = [userInfoDict objectForKey:@"postingNum"];
    self.energyNumLabel.text = [userInfoDict objectForKey:@"energyNum"];
    self.totalScoreLabel.text = [userInfoDict objectForKey:@"totalScore"];
    self.originalScoreLabel.text = [userInfoDict objectForKey:@"originalScore"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc {
    [_userNameLabel release];
    [_loginTimesLabel release];
    [_postingNumLabel release];
    [_energyNumLabel release];
    [_totalScoreLabel release];
    [_originalScoreLabel release];
    [super dealloc];
}
@end
