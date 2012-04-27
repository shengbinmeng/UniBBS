//
//  PopularTopicsViewController.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/7/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "PopularTopicsViewController.h"
#import "TopicViewController.h"
#import "BBSPopularReader.h"
#import "EGORefreshTableHeaderView.h"

@implementation PopularTopicsViewController {
    EGORefreshTableHeaderView *_refreshHeaderView; 
    BOOL _reloading; 
    int numLimit;
    int popType; // 0 for instance, 1 for day, 2 for week
}

@synthesize popularReader, popularTopics;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"热点话题";
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        numLimit = 20;
        popType = 1;
    }
    return self;
}

- (void) dealloc {
    [super dealloc];
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
    
    int index = buttonIndex - actionSheet.firstOtherButtonIndex;
    if (index == popType) {
        return;
    }
    switch (index) {
        case 0:
            self.popularReader.dataAddress = @"http://www.bdwm.net/bbs/ListPostTops.php?halfLife=7";
            popType = 0;
            break;
        case 1:
            self.popularReader.dataAddress = @"http://www.bdwm.net/bbs/ListPostTops.php?halfLife=180";
            popType = 1;
            break;
        case 2:
            self.popularReader.dataAddress = @"http://www.bdwm.net/bbs/ListPostTops.php?halfLife=2520";
            popType = 2;
            break;
        default:
            break;
    }
    self.popularTopics = [self.popularReader readPopularTopics];
    numLimit = 20;
    [((UIButton*)self.tableView.tableFooterView) setTitle:@"更多" forState:UIControlStateNormal];
    [((UIButton*)self.tableView.tableFooterView) setEnabled:YES];
    [self.tableView reloadData];
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
        [((UIButton*)self.tableView.tableFooterView) setTitle:@"没有更多" forState:UIControlStateNormal];
        [((UIButton*)self.tableView.tableFooterView) setEnabled:NO];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	// Do any additional setup after loading the view, typically from a nib.
    // Do any additional setup after loading the view, typically from a nib.
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"选项" style:UIBarButtonItemStyleBordered target:self action:@selector(buttonPressed)];
    self.navigationItem.rightBarButtonItem = button;
    [button release];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button1 setTitle:@"更多" forState:UIControlStateNormal];
    [button1 setFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 44.0)];
    [button1 addTarget:self action:@selector(showMore) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView setTableFooterView:button1];

    
    if (_refreshHeaderView == nil) { 
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, - 100.0f, self.tableView.frame.size.width, 100)]; 
        view.delegate = self; 
        [self.tableView addSubview:view]; //retained
        _refreshHeaderView = view; 
        [view release]; 
    }

    if (self.popularTopics == nil) {
        BBSPopularReader *reader = [[BBSPopularReader alloc] initWithAddress:@"http://www.bdwm.net/bbs/ListPostTops.php?halfLife=180"]; //7, 180, 2520
        self.popularReader = reader;
        [reader release];
        self.popularTopics = [self.popularReader readPopularTopics];
    }
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (popularTopics != nil && popularTopics.count == 0) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"消息" message:@"未取到数据！可能是网络或其他原因导致。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert performSelector:@selector(show) withObject:nil afterDelay:0.5];
        [alert show];
        [alert release];
    }
    int num = MIN([popularTopics count], numLimit);
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PopularCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary *topic = [popularTopics objectAtIndex:[indexPath row]];
    cell.textLabel.text = [topic valueForKey:@"title"];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    
    NSString *detail = [NSString stringWithFormat:@"%@    -   %@",[topic valueForKey:@"time"], [topic valueForKey:@"author"]];
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
    topicViewController.topicAddress = [topic valueForKey:@"address"];
    topicViewController.topicInfo = topic;
    [self.navigationController pushViewController:topicViewController animated:YES];
    [topicViewController release];
}


#pragma mark - Helper: Data Source Loading / Reloading Methods
- (void)doneLoadingTableViewData 
{
    _reloading = NO; 
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

- (void)reloadTableViewDataSource 
{   
    _reloading = YES;  
    self.popularTopics = [self.popularReader readPopularTopics];
    [self.tableView reloadData];
    sleep(1);
    [self doneLoadingTableViewData];
}

#pragma mark - UIScrollViewDelegate Methods 

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView]; 
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{ 
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView]; 
} 

#pragma mark - EGORefreshTableHeaderDelegate Methods 

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self performSelector:@selector(reloadTableViewDataSource) withObject:nil afterDelay:0.5];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return _reloading; 
} 

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return [NSDate date];     
} 

@end
