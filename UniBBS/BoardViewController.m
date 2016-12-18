//
//  BoardViewController.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/7/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "BoardViewController.h"
#import "TopicViewController.h"
#import "BDWMBoardReader.h"
#import "BDWMFavouritesManager.h"
#import "WritingViewController.h"
#import "BDWMGlobalData.h"
#import "BDWMAlertMessage.h"
#import "BDWMUserModel.h"

@interface BoardViewController ()

@end

@implementation BoardViewController

@synthesize boardURI, boardName, boardReader, boardTopics;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
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

- (void) displayMore
{
    [self.boardReader getBoardNextTopicsWithBlock:^(NSMutableArray *topics_t, NSError *error) {
        if (!error) {
            NSMutableArray *topics = self.boardTopics;
            [topics addObjectsFromArray:topics_t];
            if(topics != nil && topics.count > 0) {
                self.boardTopics = topics;
                [self.tableView reloadData];
            } else {
                [((UIButton*)self.tableView.tableFooterView) setTitle:@"没有更多" forState:UIControlStateNormal];
            }
        } else {
            [BDWMAlertMessage alertAndAutoDismissMessage:@"网络错误"];
        }
    }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    NSUInteger index = buttonIndex - actionSheet.firstOtherButtonIndex;
    switch (index) {
        case 0:{
            if ([BDWMUserModel isLogined]) {
                // new post
                WritingViewController *newPost = [[WritingViewController alloc] initWithNibName:@"WrittingViewController" bundle:nil];
                newPost.fromWhere = @"compose";
                newPost.board  = self.boardURI;
                [self.navigationController pushViewController:newPost animated:YES];
            } else {
                //Todo: segue to login view, and if login success, segue to compose topic view.
                [BDWMAlertMessage alertAndAutoDismissMessage:@"登录以后才能发帖呢."];
            }
            
            break;
        }
        case 1:{
            NSMutableDictionary *boardInfo = [[NSMutableDictionary alloc] init];
            [boardInfo setObject:self.title forKey:@"boardTitle"];
            [boardInfo setObject:self.boardURI forKey:@"boardName"];
            [BDWMFavouritesManager saveFavouriteBoard:boardInfo];
            break;
        }
        default:
            break;
    }

}

- (void) barButtonPressed 
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选项" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"发表新帖", @"收藏本版", nil];
    [sheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

- (void)reload:(__unused id)sender {
    [self.boardReader getBoardTopicsWithBlock:^(NSMutableArray *topics, NSError *error) {
        if (!error) {
            self.boardTopics = topics;
            if (self.boardTopics.count == 0) {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"消息" message:@"未取到数据！可能是网络或其他原因导致。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            } else {
                [self.tableView reloadData];
            }
        } else {
            [BDWMAlertMessage alertAndAutoDismissMessage:[error localizedDescription]];
            [self.navigationController popViewControllerAnimated:YES];
        }
        [self.refreshControl endRefreshing];
    }];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"选项" style:UIBarButtonItemStylePlain target:self action:@selector(barButtonPressed)];
    self.navigationItem.rightBarButtonItem = barButton;

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    
    UIButton *bottomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [bottomButton setTitle:@"正在加载" forState:UIControlStateNormal];
    [bottomButton setFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 44.0)];
    [self.tableView setTableFooterView:bottomButton];
    [self.tableView.tableFooterView setHidden:YES];
    
    if (self.boardReader == nil) {
        BDWMBoardReader *reader = [[BDWMBoardReader alloc] initWithURI:self.boardURI];
        self.boardReader = reader;
        self.boardReader.showSticky = YES;
    }
    
    [self.refreshControl layoutIfNeeded];
    [self.refreshControl beginRefreshing];
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.boardTopics count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *topic = [boardTopics objectAtIndex:[indexPath row]];

    if ([[topic valueForKey:@"top"] intValue] == 1) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@%@", @"【置顶】", [topic valueForKey:@"title"]];
    } else {
        cell.textLabel.text = [topic valueForKey:@"title"];
    }
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    
    NSInteger timestamp = [[topic valueForKey:@"timestamp"] intValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM-dd HH:mm:ss"];
    NSString *time = [format stringFromDate:date];
    NSString *detail = [NSString stringWithFormat:@"%@    -   %@", time , [topic valueForKey:@"author"]];
    cell.detailTextLabel.text = detail;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    
    return cell;
}


- (CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSDictionary *topic = [boardTopics objectAtIndex:[indexPath row]];
    TopicViewController *topicViewController = [[TopicViewController alloc] initWithStyle:UITableViewStylePlain];
    topicViewController.title = [topic valueForKey:@"title"];
    topicViewController.topicURI = [NSString stringWithFormat:@"%@/%@", self.boardURI, [topic valueForKey:@"threadid"]];
    [self.navigationController pushViewController:topicViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger lastSectionIndex = [tableView numberOfSections] - 1;
    NSInteger lastRowIndex = [tableView numberOfRowsInSection:lastSectionIndex] - 1;
    if ((indexPath.section == lastSectionIndex) && (indexPath.row == lastRowIndex)) {
        // This is the last cell
        [self.tableView.tableFooterView setHidden:NO];
        [self displayMore];
    }
}

@end
