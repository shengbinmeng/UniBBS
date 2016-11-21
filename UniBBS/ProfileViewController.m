//
//  ProfileViewController.m
//  UniBBS
//
//  Created by Shengbin Meng on 14/10/12.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import "ProfileViewController.h"
#import "LoginViewController.h"
#import "FavouritesViewController.h"
#import "BDWMUserModel.h"
#import "BDWMAlertMessage.h"
#import "UserInfoViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"我的未名";
        self.tabBarItem.image = [UIImage imageNamed:@"profile"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 2;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultStyleCell"];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultStyleCell"];
        }
        if ([indexPath row] == 0) {
            NSString *cellContent = [[NSString alloc] init];
            if ([BDWMUserModel isLogined]) {
                cellContent = [BDWMUserModel getLoginUser];
                
                if (cellContent==nil || cellContent.length==0) {
                    [BDWMAlertMessage alertAndAutoDismissMessage:@"你是谁啊."];
                }
            }else{
                cellContent = @"账号登录";
            }
            [cell.textLabel setText:cellContent];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        return cell;
    }
    
    if ([indexPath section] == 1) {
        
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultStyleCell"];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultStyleCell"];
        }
        if ([indexPath row] == 0) {
            [cell.textLabel setText:@"本地收藏"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if ([indexPath row] == 1) {
            [cell.textLabel setText:@"站内信"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        return cell;
    }
    
    return nil;
}

- (NSString *)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *header = @"";
    if (section == 0) {
        
    }
    return header;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *footerText = @"";
    if (section == 0) {
        
    }
    return footerText;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([indexPath section] == 0) {
        if ([indexPath row] == 0) {
            //segue to appropriate view.
            if ([BDWMUserModel isLogined]) {
                UserInfoViewController *userInfo = [[UserInfoViewController alloc] initWithStyle:UITableViewStylePlain];
                [self.navigationController pushViewController:userInfo animated:YES];
            }else{
                LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                [self.navigationController pushViewController:login animated:YES];
            }
            
            return;
        }
    }
    
    if ([indexPath section] == 1) {
        if ([indexPath row] == 0) {
            FavouritesViewController *favourites = [[FavouritesViewController alloc] initWithStyle:UITableViewStylePlain];
            [self.navigationController pushViewController:favourites animated:YES];
            return;
        }
        if ([indexPath row] == 1) {
            [BDWMAlertMessage alertMessage:@"站内信功能暂时下线啦，请在web端进行处理~"];
            return;
        }
    }
}

@end
