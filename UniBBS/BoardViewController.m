//
//  BoardViewController.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/7/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "BoardViewController.h"
#import "PostViewController.h"
#import "TopicViewController.h"
#import "BBSBoardReader.h"
#import "BBSFavouritesManager.h"
#import "WrittingViewController.h"
#import "BDWMString.h"
#import "BDWMGlobalData.h"
#import "BDWMAlertMessage.h"
#import "LoginViewController.h"
@implementation BoardViewController {
    BOOL topicMode;
}

@synthesize boardName, boardAddress, boardReader, boardPosts, boardTopics, boardInfo;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        topicMode = YES;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) displayNextPage
{
    if (topicMode) {
        NSMutableArray *topics = [self.boardReader readNextPage];
        if(topics != nil) {
            self.boardTopics = topics;
            [self.tableView reloadData];
            if (topics.count == 0) {
                // should not continu to scrollToRow
                return;
            }
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"已是最后一页" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
    } else {
        NSMutableArray *posts = [self.boardReader readNextPage];
        if(posts != nil) {
            self.boardPosts = posts;
            [self.tableView reloadData];
            if (posts.count == 0) {
                // should not continu to scrollToRow
                return;
            }
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"已是最后一页" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
    }
}

- (void) displayPreviousPage
{
    if (topicMode) {
        NSMutableArray *topics = [self.boardReader readPreviousPage];
        if(topics != nil && topics.count > 0) {
            self.boardTopics = topics;
            [self.tableView reloadData];
            if (topics.count == 0) {
                // should not continu to scrollToRow
                return;
            }
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"已是第一页" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
    } else {
        NSMutableArray *posts = [self.boardReader readPreviousPage];
        if(posts != nil && posts.count > 0) {
            self.boardPosts = posts;
            [self.tableView reloadData];
            if (posts.count == 0) {
                // should not continu to scrollToRow
                return;
            }
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"已是第一页" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    int index = buttonIndex - actionSheet.firstOtherButtonIndex;
    switch (index) {
        case 0:{
            if ([LoginViewController isLogined]) {
                // new post
                WrittingViewController *newPost = [[[WrittingViewController alloc] initWithNibName:@"WrittingViewController" bundle:nil] autorelease];
                newPost.fromWhere = @"compose";
                newPost.href  = [BDWMString linkString:@"bbspst.php?board=" string:self.boardName];
                NSLog(@"compose href:%@",newPost.href);
                [self.navigationController pushViewController:newPost animated:YES];
            }else{
                //Todo: segue to login view, and if login success, segue to compose topic view.
                [BDWMAlertMessage alertMessage:@"登陆以后才能发帖呢."];
            }
            
            break;
        }
        case 1:
            topicMode = !topicMode;
            self.boardReader.dataAddress = nil;
            if (topicMode) {
                self.boardTopics = [self.boardReader readBoardTopics];
            } else {
                self.boardPosts = [self.boardReader readBoardPosts];
            }
            break;
        case 2:
            self.boardReader.showSticky = !(self.boardReader.showSticky);
            if (topicMode) {
                self.boardTopics = [self.boardReader readBoardTopics];
            } else {
                self.boardPosts = [self.boardReader readBoardPosts];
            }
            break;
        case 3:
            [[BBSFavouritesManager favouriteBoards]addObject:self.boardInfo];
            break;
        default:
            break;
    }
    
    [self.tableView reloadData];
}

- (void) barButtonPressed 
{
    NSString *option1 = @"主题模式";
    if (topicMode) {
        option1 = @"回帖模式";
    }
    NSString *option2 = @"显示置顶";
    if (self.boardReader.showSticky) {
        option2 = @"不显示置顶";
    }
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选项" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"发表新帖", option1, option2, @"收藏本版", nil];
    [sheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    [sheet release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"选项" style:UIBarButtonItemStyleBordered target:self action:@selector(barButtonPressed)];
    self.navigationItem.rightBarButtonItem = barButton;
    [barButton release];
    
    /*
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button1 setTitle:@"下一页" forState:UIControlStateNormal];
    [button1 setFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 44.0)];
    [button1 addTarget:self action:@selector(displayNextPage) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button2 setTitle:@"上一页" forState:UIControlStateNormal];
    [button2 setFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 44.0)];
    [button2 addTarget:self action:@selector(displayPreviousPage) forControlEvents:UIControlEventTouchUpInside];
    
    [self.tableView setTableFooterView:button1];
    [self.tableView setTableHeaderView:button2];
     */
    
    UIToolbar *toolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 44.0)] autorelease];
    UIBarButtonItem *prev = [[[UIBarButtonItem alloc] initWithTitle:@"上一页" style:UIBarButtonItemStyleBordered target:self action:@selector(displayPreviousPage)] autorelease];
    UIBarButtonItem *next = [[[UIBarButtonItem alloc] initWithTitle:@"下一页" style:UIBarButtonItemStyleBordered target:self action:@selector(displayNextPage)] autorelease];
    UIBarButtonItem *space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    NSArray *toolbarItems = [NSArray arrayWithObjects: prev, space, next, nil];
    [toolBar setItems:toolbarItems];
    [self.tableView setTableFooterView:toolBar];
    
    if (self.boardReader == nil) {
        BBSBoardReader *reader = [[BBSBoardReader alloc] initWithBoardName:self.boardName];
        self.boardReader = reader;
        [reader release];
        self.boardReader.showSticky = NO;
        self.boardTopics = [self.boardReader readBoardTopics];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.boardName = nil;
    self.boardAddress = nil;
    self.boardReader = nil;
    self.boardTopics = nil;
    self.boardPosts = nil;
    self.boardInfo = nil;
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
    if (topicMode) {
        if (self.boardTopics != nil && self.boardTopics.count == 0) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"消息" message:@"未取到数据！可能是网络或其他原因导致。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert performSelector:@selector(show) withObject:nil afterDelay:0.5];
            [alert show];
            [alert release];
        }
        return [self.boardTopics count];
    } else {
        if (self.boardPosts != nil && self.boardPosts.count == 0) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"消息" message:@"未取到数据！可能是网络或其他原因导致。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert performSelector:@selector(show) withObject:nil afterDelay:0.5];
            [alert show];
            [alert release];
        }
        return [self.boardPosts count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    if (topicMode) {
        NSDictionary *topic = [boardTopics objectAtIndex:[indexPath row]];

        if ([[topic valueForKey:@"sticky"] isEqualToString:@"YES"]) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@%@", @"【置顶】", [topic valueForKey:@"title"]];
        } else {
            cell.textLabel.text = [topic valueForKey:@"title"];
        }
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        
        NSString *detail = [NSString stringWithFormat:@"%@    -   %@",[topic valueForKey:@"time"], [topic valueForKey:@"author"]];
        cell.detailTextLabel.text = detail;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];

    } else {
        NSDictionary *post = [boardPosts objectAtIndex:[indexPath row]];
        if ([[post valueForKey:@"sticky"] isEqualToString:@"YES"]) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@%@", @"【置顶】", [post valueForKey:@"title"]];
        } else {
            cell.textLabel.text = [post valueForKey:@"title"];
        }
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        
        NSString *detail = [NSString stringWithFormat:@"%@    -   %@",[ post valueForKey:@"time"], [post valueForKey:@"author"]];
        cell.detailTextLabel.text = detail;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    }
    
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
    
    if (topicMode) {
        NSDictionary *topic = [boardTopics objectAtIndex:[indexPath row]];
        TopicViewController *topicViewController = [[[TopicViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
        topicViewController.title = [topic valueForKey:@"title"];
        topicViewController.topicAddress = [topic valueForKey:@"address"];
        topicViewController.topicInfo = topic;
        [self.navigationController pushViewController:topicViewController animated:YES];    
    } else {
        NSDictionary *post = [boardPosts objectAtIndex:[indexPath row]];
        PostViewController *postViewController = [[[PostViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
        postViewController.title = [post valueForKey:@"title"];
        postViewController.postAddress = [post valueForKey:@"address"];
        [self.navigationController pushViewController:postViewController animated:YES];
    }
}

@end
