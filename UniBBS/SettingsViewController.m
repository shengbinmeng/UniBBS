//
//  SettingsViewController.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/8/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "SettingsViewController.h"
#import "WebViewController.h"
#import "LoginViewController.h"

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"更多";
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


#pragma mark - Table View delegate and data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;//3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 2;
    }
//    else if (section == 2) {
//        return 2;
//    }
//    else if (section == 3) {
//        return 2;
//    }
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultStyleCell"];
        if(cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultStyleCell"] autorelease];
        }
        if ([indexPath row] == 0) {
            [cell.textLabel setText:@"关于此程序"];
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        }
        return cell;
    }
    
    if ([indexPath section] == 1) {

        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Value1StyleCell"];
        if(cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Value1StyleCell"] autorelease];
        }
        
        if ([indexPath row] == 0) {
            [cell.textLabel setText:@"未名站点"];
            [cell.textLabel setFont:[UIFont systemFontOfSize:17.0]];
            [cell.detailTextLabel setText:@"http://www.bdwm.net"];
        }
        if ([indexPath row] == 1) {
            [cell.textLabel setText:@"支持开发者"];
            [cell.textLabel setFont:[UIFont systemFontOfSize:17.0]];
            [cell.detailTextLabel setText:@"shengbin.me"];
        }
        
        return cell;
    }
    /*
    if ([indexPath section] == 2) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultStyleCell"];
        if(cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultStyleCell"] autorelease];
        }
        if ([indexPath row] == 0) {
            [cell.textLabel setText:@"用户登录"];
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        }
        if ([indexPath row] == 1) {
            [cell.textLabel setText:@"退出账户"];
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        }
        return cell;
    }
    */
    
    return nil;
}

- (NSString *)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *header = @"";
    if (section == 0) {
        header = @"";
    }
    if (section == 1) {
        header = @"网页访问";
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
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"关于" message:@"北大未名Lite - 这是用于在北大未名BBS潜水的iOS客户端。该版本不具备用户登录和回复功能，是实实在在的潜水版。如果有任何问题和建议，可以发信至：shengbinmeng@gmail.com。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert performSelector:@selector(show) withObject:nil afterDelay:0.5];
            [alert show];
            [alert release];
            return;
        }
    }
    
    if ([indexPath section] == 1) {
        if ([indexPath row] == 0) {
            WebViewController *aboutViewController =[[[WebViewController alloc] init] autorelease];
            aboutViewController.webAddress = @"http://www.bdwm.net/bbs";
            [self.navigationController pushViewController:aboutViewController animated:YES];
            return;
        }
        if ([indexPath row] == 1) {
            [[UIApplication sharedApplication] openURL:[[[NSURL alloc] initWithString:@"http://www.shengbin.me/apps/unibbs"] autorelease]];
            return;
        }
    }
    /*
    if ([indexPath section] == 2) {
        if ([indexPath row] == 0) {
            LoginViewController *login = [[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil] autorelease];
            [self.navigationController pushViewController:login animated:YES];
        }
        if ([indexPath row] == 1) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"消息" message:@"已经退出。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert performSelector:@selector(show) withObject:nil afterDelay:0.5];
            [alert show];
            [alert release];
        }
    }
     */
}

@end
