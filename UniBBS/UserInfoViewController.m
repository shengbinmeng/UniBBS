//
//  UserInfoViewController.m
//  UniBBS
//
//  Created by fanyingming on 10/11/14.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import "UserInfoViewController.h"
#import "BDWMUserModel.h"

@interface UserInfoViewController ()

@end

@implementation UserInfoViewController

NSString *nickname;
NSString *numlogins;
NSString *numposts;
NSString *life;
NSString *staytime;
NSString *createtime;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"个人信息";
    }
    return self;
}

- (void) logoutButtonPressed {
    [BDWMUserModel logout];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) backButtonPressed{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"注销" style:UIBarButtonItemStylePlain target:self action:@selector(logoutButtonPressed)];
    self.navigationItem.rightBarButtonItem = button;
    //always back to profile view.
    button = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
    self.navigationItem.leftBarButtonItem = button;
    
    if (self.userInfoDict == nil) {
        self.userInfoDict = [BDWMUserModel getStoredUserInfo];
    }
    
    nickname = (NSString *)[self.userInfoDict objectForKey:@"nickname"];
    numlogins = [NSString stringWithFormat: @"%d", [[self.userInfoDict objectForKey:@"numlogins"] intValue]];
    numposts = [NSString stringWithFormat: @"%d", [[self.userInfoDict objectForKey:@"numposts"] intValue]];
    life = [NSString stringWithFormat: @"%d", [[self.userInfoDict objectForKey:@"life"] intValue]];
    
    int numSeconds = [[self.userInfoDict objectForKey:@"staytime"] intValue];
    int days = numSeconds / (60 * 60 * 24);
    numSeconds -= days * (60 * 60 * 24);
    int hours = numSeconds / (60 * 60);
    if (days > 0) {
        staytime = [NSString stringWithFormat: @"%d天%d小时", days, hours];
    } else {
        staytime = [NSString stringWithFormat: @"%d小时", hours];
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[self.userInfoDict objectForKey:@"createtime"] intValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH时mm分"];
    createtime = [dateFormatter stringFromDate:date];
     
}

- (void)viewDidAppear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Value1StyleCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    switch([indexPath row]) {
        case 0:
            cell.textLabel.text = @"昵称";
            cell.detailTextLabel.text = nickname;
            break;
        case 1:
            cell.textLabel.text = @"上站次数";
            cell.detailTextLabel.text = numlogins;
            break;
        case 2:
            cell.textLabel.text = @"文章数";
            cell.detailTextLabel.text = numposts;
            break;
        case 3:
            cell.textLabel.text = @"生命力";
            cell.detailTextLabel.text = life;
            break;
        case 4:
            cell.textLabel.text = @"上站时长";
            cell.detailTextLabel.text = staytime;
            break;
        case 5:
            cell.textLabel.text = @"注册日期";
            cell.detailTextLabel.text = createtime;
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
