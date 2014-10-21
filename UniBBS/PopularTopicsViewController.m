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
#import "BDWMUserModel.h"
#import "BDWMAlertMessage.h"

@interface PopularTopicsViewController ()
@property (readwrite, nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation PopularTopicsViewController {
    int numLimit;
    int popType; // 0 for instance, 1 for day, 2 for week
    
    NSString *href;
}

@synthesize popularReader, popularTopics;

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
    
    NSInteger index = buttonIndex - actionSheet.firstOtherButtonIndex;
    if (index == popType) {
        return;
    }
    switch (index) {
        case 0:
            href = @"http://www.bdwm.net/bbs/ListPostTops.php?halfLife=7";
            popType = 0;
            self.title = @"实时热点";
            break;
        case 1:
            href = @"http://www.bdwm.net/bbs/ListPostTops.php?halfLife=180";
            popType = 1;
            self.title = @"当天最热";
            break;
        case 2:
            href = @"http://www.bdwm.net/bbs/ListPostTops.php?halfLife=2520";
            popType = 2;
            self.title = @"一周热点";
            break;
        default:
            break;
    }

    numLimit = 20;
    [((UIButton*)self.tableView.tableFooterView) setTitle:@"更多" forState:UIControlStateNormal];
    [((UIButton*)self.tableView.tableFooterView) setEnabled:YES];
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
        [((UIButton*)self.tableView.tableFooterView) setTitle:@"没有更多" forState:UIControlStateNormal];
        [((UIButton*)self.tableView.tableFooterView) setEnabled:NO];
    }
}

- (void)reload:(__unused id)sender {
    
    NSURLSessionTask *task = [BBSPopularReader getPopularTopicsWithBlock:href blockFunction:^(NSMutableArray *topics, NSError *error) {
        if (!error) {
            self.popularTopics = topics;
            [self.tableView reloadData];
        }else{
            [BDWMAlertMessage alertMessage:@"哎呀～获取不到数据～"];
        }
    }];

    [self.refreshControl setRefreshingWithStateOfTask:task];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"选项" style:UIBarButtonItemStyleBordered target:self action:@selector(buttonPressed)];
    self.navigationItem.rightBarButtonItem = button;
    [button release];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button1 setTitle:@"更多" forState:UIControlStateNormal];
    [button1 setFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 44.0)];
    [button1 addTarget:self action:@selector(showMore) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView setTableFooterView:button1];

    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 100.0f)];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    [self.tableView.tableHeaderView addSubview:self.refreshControl];
    
    
    if (self.popularTopics == nil) {
        href = @"http://www.bdwm.net/bbs/ListPostTops.php?halfLife=180";
    }
    
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
    
    if (NO==[BDWMUserModel isLogined]) {
        NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
        NSString *userName = [userDefaultes stringForKey:@"saved_username"];
        NSString *password = [userDefaultes stringForKey:@"saved_password"];
        
        [BDWMUserModel checkLogin:userName userPass:password blockFunction:^(NSString *name, NSError *error){
            if ( !error && name!=nil ) {
                [BDWMAlertMessage alertMessage:@"登录成功！"];
                
            }else{

            }
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
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"消息" message:@"未取到数据！可能是网络或其他原因导致。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert performSelector:@selector(show) withObject:nil afterDelay:0.5];
        [alert show];
        [alert release];
    }
    NSInteger num = MIN([popularTopics count], numLimit);
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

@end
