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
@property (nonatomic, retain) UIActivityIndicatorView *indicator;
@end

@implementation PopularTopicsViewController {
    int numLimit;
}

@synthesize popularTopics;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"当天最热";
        self.tabBarItem.image = [UIImage imageNamed:@"popular"];
        numLimit = 20;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void) showMore
{
    if (numLimit < self.popularTopics.count) {
        numLimit += 20;
        [self.tableView reloadData];
    }
}

- (void)reload:(__unused id)sender {
    [BDWMPopularReader getPopularTopicsOfType:0 WithBlock:^(NSMutableArray *topics, NSError *error) {
        if (!error) {
            self.popularTopics = topics;
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
            [self.indicator stopAnimating];
        } else {
            [BDWMAlertMessage alertAndAutoDismissMessage:@"未取到数据！可能是网络或其他原因导致。"];
        }
    }];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    
    if (self.indicator == nil) {
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.view insertSubview:indicator aboveSubview:self.tableView];
        indicator.center = self.tableView.center;
        self.indicator = indicator;
    }
    [self.indicator startAnimating];
    
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
    
    if ([BDWMUserModel getEnterAppAndAutoLogin] == YES && [BDWMUserModel isLogined] == NO && [BDWMUserModel getStoredUserInfo] != nil) {
        [BDWMUserModel autoLogin:^() {
        //    [BDWMAlertMessage alertMessage:@"登录成功!"];
        } WithFailurBlock:^(){
            [BDWMAlertMessage alertMessage:@"登录失败!"];
        }];
    }
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
    if (indexPath.row == numLimit - 1) {
        [self showMore];
    }
}

@end
