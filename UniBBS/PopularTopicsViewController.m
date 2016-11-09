//
//  PopularTopicsViewController.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/7/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "PopularTopicsViewController.h"
#import "TopicViewController.h"
#import "BDWMUserModel.h"
#import "BDWMAlertMessage.h"
#import "BDWMUserModel.h"
#import "BDWMPopularReader.h"

@interface PopularTopicsViewController ()
@property (readwrite, nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation PopularTopicsViewController {
    int numLimit;
    int popType; // 0 for instance, 1 for day, 2 for week
}

@synthesize popularTopics;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"当天最热";
        self.tabBarItem.image = [UIImage imageNamed:@"popular"];
        numLimit = 20;
        popType = 1;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


- (void) buttonPressed 
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选项" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"实时热点", @"当天最热", @"一周热点", nil];
    [sheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    NSInteger index = buttonIndex - actionSheet.firstOtherButtonIndex;
    if (index == popType) {
        return;
    }
    switch (index) {
        case 0:
            popType = 0;
            self.title = @"实时热点";
            break;
        case 1:
            popType = 1;
            self.title = @"当天最热";
            break;
        case 2:
            popType = 2;
            self.title = @"一周热点";
            break;
        default:
            break;
    }

    numLimit = 20;
    [((UIButton*)self.tableView.tableFooterView) setTitle:@"更多" forState:UIControlStateNormal];
    [((UIButton*)self.tableView.tableFooterView) setEnabled:YES];
    //todo:show refreshing.
    [self reload:nil];
    if (self.popularTopics.count != 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (void) showMore
{
    if (numLimit < self.popularTopics.count) {
        numLimit += 20;
        [self.tableView reloadData];
    } else {
//        [((UIButton*)self.tableView.tableFooterView) setTitle:@"没有更多" forState:UIControlStateNormal];
//        [((UIButton*)self.tableView.tableFooterView) setEnabled:NO];
    }
}

- (void)reload:(__unused id)sender {
    
    NSURLSessionTask *task = [BDWMPopularReader getPopularTopicsOfType: popType WithBlock:^(NSMutableArray *topics, NSError *error) {
        if (!error) {
            self.popularTopics = topics;
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        } else {
            [BDWMAlertMessage alertAndAutoDismissMessage:@"未取到数据！可能是网络或其他原因导致。"];
        }
    }];

//    [self.refreshControl setRefreshingWithStateOfTask:task];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"选项" style:UIBarButtonItemStylePlain target:self action:@selector(buttonPressed)];
    // TODO: Remove UI because feature is removed.
    //self.navigationItem.rightBarButtonItem = button;
    
//    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [button1 setTitle:@"更多" forState:UIControlStateNormal];
//    [button1 setFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 44.0)];
//    [button1 addTarget:self action:@selector(showMore) forControlEvents:UIControlEventTouchUpInside];
//    [self.tableView setTableFooterView:button1];

    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 100.0f)];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    [self.tableView.tableHeaderView addSubview:self.refreshControl];
    
    [self reload:nil];
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
    /*
    if ([BDWMUserModel getEnterAppAndAutoLogin]==YES && [BDWMUserModel isLogined]==NO) {
        NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
        NSString *userName = [userDefaultes stringForKey:@"saved_username"];
        NSString *password = [userDefaultes stringForKey:@"saved_password"];
        
        if (userName==nil || password==nil ) {
            return;
        }
        [BDWMAlertMessage startSpinner:@"正在登录..."];
        
        [BDWMUserModel checkLogin:userName userPass:password blockFunction:^(NSString *name, NSError *error){
            if ( !error && name!=nil ) {
                // I find it annoying when I want to read the content but alert comes up
                //[BDWMAlertMessage alertAndAutoDismissMessage:@"登录成功！"];
                [BDWMUserModel setEnterAppAndAutoLogin:NO];
                [BDWMAlertMessage stopSpinner];
            }else{
                [BDWMAlertMessage alertMessage:@"登录失败!"];
            }
        }];
        
        
    }
     */
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (popularTopics != nil && popularTopics.count == 0) {
        NSString *alertTitle = @"消息";
#ifdef DEBUG
        alertTitle = @"热点列表";
#endif
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:alertTitle message:@"未取到数据！可能是网络或其他原因导致。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert performSelector:@selector(show) withObject:nil afterDelay:0.5];
        [alert show];
        popularTopics = nil;
        return 0;
    }
    NSInteger num = MIN([popularTopics count], numLimit);
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PopularCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *topic = [popularTopics objectAtIndex:[indexPath row]];
    cell.textLabel.text = [topic valueForKey:@"title"];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    
    NSString *detail = [NSString stringWithFormat:@"%@  -  %@  -  %@",[topic valueForKey:@"date"], [topic valueForKey:@"author"], [topic valueForKey:@"boardDescription"]];
    cell.detailTextLabel.text = detail;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *topic = [popularTopics objectAtIndex:[indexPath row]];
    TopicViewController *topicViewController = [[TopicViewController alloc] initWithStyle:UITableViewStylePlain];
    topicViewController.title = [topic valueForKey:@"title"];
    topicViewController.topicURI = [NSString stringWithFormat:@"%@/%@", [topic valueForKey:@"boardName"], [topic valueForKey:@"threadid"]];
    [self.navigationController pushViewController:topicViewController animated:YES];
} 

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // check if indexPath.row is last row
    // Perform operation to load new Cell's.
    if ( indexPath.row == numLimit-1 ) {
        [self showMore];
    }
}

@end
