//
//  SettingsViewController.m
//  UniBBS
//
//  Created by Shengbin Meng on 10/21/14.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import "SettingsViewController.h"
#import "WebViewController.h"
#import "BDWMSettings.h"
#import "BDWMAlertMessage.h"
#import "DatabaseWrapper.h"
#import "BDWMUserModel.h"

@interface SettingsViewController ()
@property (readwrite, nonatomic, strong) UIAlertView *alertView;
@end

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"更多";
        self.tabBarItem.image = [UIImage imageNamed:@"settings"];
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

- (void)sendMail
{
    // Email Subject
    NSString *emailTitle = @"北大未名iOS客户端用户反馈";
    // Email Content
    NSString *messageBody = @"";
    // To address
    NSMutableArray *addressArray = [NSMutableArray array];
    [addressArray addObject:@"yingmingfan@gmail.com"];
    [addressArray addObject:@"shengbinmeng@gmail.com"];
    NSArray *toRecipents = addressArray;
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];

}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            [BDWMAlertMessage alertMessage:@"感谢您的反馈。我们会尽快答复。"];
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
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
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else if (section == 1) {
        return 1;
    }else if (section == 2) {
        return 3;
    } else if (section == 3) {
        return 1;
    } else if (section == 4){
        return 2;
    }
    return 1;
}

- (void) boolUsePostSuffixStringSwitchChanged:(id)sender {
    UISwitch* switchControl = sender;
    NSLog( @"The switch is %@", switchControl.on ? @"ON" : @"OFF" );
    [BDWMSettings setBoolUsePostSuffixString:switchControl.on];
    
}

- (void) boolAutoLoginSwitchChanged:(id)sender {
    UISwitch* switchControl = sender;
    NSLog( @"The switch is %@", switchControl.on ? @"ON" : @"OFF" );
    [BDWMSettings setBoolAutoLogin:switchControl.on];
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultStyleCell"];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultStyleCell"];
        }
        if ([indexPath row] == 0) {
            [cell.textLabel setText:@"打开小尾巴"];
            //add a switch
            UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
            [switchview addTarget:self action:@selector(boolUsePostSuffixStringSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            [switchview setOn:[BDWMSettings boolUsePostSuffixString] animated:NO];
            cell.accessoryView = switchview;
        }
        return cell;
    }
    
    if ([indexPath section] == 1) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultStyleCell"];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultStyleCell"];
        }
        if ([indexPath row] == 0) {
            [cell.textLabel setText:@"自动登录"];
            //add a switch
            UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
            [switchview addTarget:self action:@selector(boolAutoLoginSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            [switchview setOn:[BDWMSettings boolAutoLogin] animated:NO];
            cell.accessoryView = switchview;
        }
        return cell;
    }
    
    if ([indexPath section] == 2) {
        
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Value1StyleCell"];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Value1StyleCell"];
        }
        
        if ([indexPath row] == 0) {
            [cell.textLabel setText:@"关于此应用"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if ([indexPath row] == 1) {
            [cell.textLabel setText:@"关于开发者"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if ([indexPath row] == 2) {
            [cell.textLabel setText:@"未名站点"];
            [cell.detailTextLabel setText:@"将打开浏览器访问"];
        }
        return cell;
    }
    
    if ([indexPath section] ==3) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultStyleCell"];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultStyleCell"];
        }
        if ([indexPath row] == 0) {
            [cell.textLabel setText:@"给我们发邮件"];
        }
        return cell;
    }
    
    if ([indexPath section] == 4) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultStyleCell"];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultStyleCell"];
        }
        if([indexPath row] == 0){
            [cell.textLabel setText:@"清空收藏夹"];
        }else if([indexPath row] == 1){
            [cell.textLabel setText:@"清空个人设置"];
        }
        return cell;
    }
    
    return nil;
}

- (NSString *)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *header = @"";
    if (section == 0) {
        header = @"设置";
    }
    if (section == 1) {
        header = @"";
    }
    if (section == 2) {
        header = @"关于";
    }
    if (section == 3) {
        header = @"反馈";
    }
    if (section == 4){
        header = @"高级设置";
    }
    return header;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *footerText = @"";
    if (section == 0) {
        footerText = [NSString stringWithFormat:@"打开小尾巴就是在您发布的消息结尾加上“发自我的北大未名iOS客户端”字样"];
    }
    if (section == 1) {
        footerText = [NSString stringWithFormat:@"开启自动登录后，应用会在启动时自动登录您的账号"];
    }
    if (section == 4) {
        footerText = [NSString stringWithFormat:@"高级设置，请谨慎使用"];
    }
    return footerText;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    if ([indexPath section] == 2) {
        if ([indexPath row] == 0) {
            WebViewController *aboutViewController = [[WebViewController alloc] init];
            aboutViewController.webAddress = @"http://unibbs.sinaapp.com/bdwm";
            aboutViewController.barTitle = @"关于此应用";
            [self.navigationController pushViewController:aboutViewController animated:YES];
            return;
        }
        if ([indexPath row] == 1) {
            WebViewController *aboutViewController = [[WebViewController alloc] init];
            aboutViewController.webAddress = @"http://unibbs.sinaapp.com/authors";
            aboutViewController.barTitle = @"关于开发者";
            [self.navigationController pushViewController:aboutViewController animated:YES];
            return;
        }
        if ([indexPath row] == 2) {
            [[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:@"https://bbs.pku.edu.cn"]];
            return;
        }
    }
    
    if ([indexPath section] == 3) {
        if ([indexPath row] ==0) {
            [self sendMail];
            return;
        }
    }
    
    if ([indexPath section] == 4){
        self.alertView = [[UIAlertView alloc] initWithTitle:@"警告"
                                             message:@"message"
                                            delegate:self
                                   cancelButtonTitle:@"取消"
                                   otherButtonTitles:@"确定",nil];
        if ([indexPath row] ==0 ) {
            self.alertView.tag = 0;
            self.alertView.message = @"确定清空收藏夹?";
            [self.alertView show];
            return;
        }else if([indexPath row] == 1){
            //delete user setting cache.
            self.alertView.tag = 1;
            self.alertView.message = @"确定清空个人设置?";
            [self.alertView show];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 0:
            if (buttonIndex==1) {
                [DatabaseWrapper deleteDatabase];
                NSLog(@"db file deleted");
            }
            break;
        case 1:
            if (buttonIndex==1) {
                //todo: support multi-user
                //current version is the same as logout.
                [BDWMUserModel logout];
                NSLog(@"db user setting deleted");
            }
            break;
        default:
            break;
    }
}

@end
