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
#import "WritingViewController.h"
#import "BDWMString.h"
#import "BDWMGlobalData.h"
#import "BDWMAlertMessage.h"
#import "BDWMUserModel.h"
#import <CCBottomRefreshControl/UIScrollView+BottomRefreshControl.h>

@interface BoardViewController ()
@property (readwrite, nonatomic, strong) UIRefreshControl *refreshControl;
@property (readwrite, nonatomic, strong) UIRefreshControl *bottomRefreshControl;
@end

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

- (void)killScroll
{
    CGPoint offset = self.tableView.contentOffset;
    [self.tableView setContentOffset:offset animated:NO];
}

- (void) displayMore
{
    if (topicMode) {
        [self.boardReader getBoardNextTopicsWithBlock:^(NSMutableArray *topics_t, NSError *error) {
            if (!error) {
                NSMutableArray *topics = self.boardTopics;
                [topics addObjectsFromArray:topics_t];
                if(topics != nil && topics.count > 0) {
                    self.boardTopics = topics;
                    [self.tableView reloadData];
                    [self killScroll];
                    
                } else {
                    [BDWMAlertMessage alertAndAutoDismissMessage:@"没有啦～"];
                }
            }else{
                [BDWMAlertMessage alertAndAutoDismissMessage:@"网络错误"];
            }
            [self.tableView.bottomRefreshControl endRefreshing];
            
        }];
        
        
    } else {
        [self.boardReader getBoardNextPostsWithBlock:^(NSMutableArray *posts_t, NSError *error) {
            if (!error) {
                NSMutableArray *posts = self.boardPosts;
                [posts addObjectsFromArray:posts_t];
                if(posts != nil && posts.count > 0) {
                    self.boardPosts = posts;
                    [self.tableView reloadData];
                } else {
                    [BDWMAlertMessage alertAndAutoDismissMessage:@"没有啦～"];
                }
            }else{
                [BDWMAlertMessage alertAndAutoDismissMessage:@"网络错误"];
            }
            [self.tableView.bottomRefreshControl endRefreshing];
        }];
        
    }
    
    
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
                WritingViewController *newPost = [[[WritingViewController alloc] initWithNibName:@"WrittingViewController" bundle:nil] autorelease];
                newPost.fromWhere = @"compose";
                newPost.href  = [BDWMString linkString:@"bbspst.php?board=" string:self.boardName];
                NSLog(@"compose href:%@",newPost.href);
                [self.navigationController pushViewController:newPost animated:YES];
            }else{
                //Todo: segue to login view, and if login success, segue to compose topic view.
                [BDWMAlertMessage alertAndAutoDismissMessage:@"登录以后才能发帖呢."];
            }
            
            break;
        }
        case 1:
            topicMode = !topicMode;
            self.boardReader.dataAddress = nil;
            self.boardReader.showSticky = YES;
            [self reload:nil];
            break;
        case 2:
            [[BBSFavouritesManager favouriteBoards]addObject:self.boardInfo];
            break;
        default:
            break;
    }

}

- (void) barButtonPressed 
{
    NSString *option1 = @"主题模式";
    if (topicMode) {
        option1 = @"回帖模式";
    }
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选项" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"发表新帖", option1, @"收藏本版", nil];
    [sheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    [sheet release];
}

- (void)reload:(__unused id)sender {
  
    NSURLSessionTask *task;
    self.boardReader.dataAddress = nil;
    if (topicMode){
        task= [self.boardReader getBoardTopicsWithBlock:^(NSMutableArray *topics, NSError *error) {
        if (!error) {
            self.boardTopics = topics;
            if ( self.boardTopics==nil || self.boardTopics.count == 0 ) {
                //login session failed. then relogin.
                NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
                NSString *userName1 = [userDefaultes stringForKey:@"saved_username"];
                NSString *password = [userDefaultes stringForKey:@"saved_password"];
                
                [BDWMUserModel checkLogin:userName1 userPass:password blockFunction:^(NSString *name, NSError *error){
                    if ( !error && name!=nil ) {
                        //login success reload mail.
                        [self.boardReader getBoardTopicsWithBlock:^(NSMutableArray *topics, NSError *error){
                            if (!error){
                                self.boardTopics = topics;
                                //login success but no topics.
                                if (self.boardTopics==nil || self.boardTopics.count==0) {
                                    //
                                    [BDWMAlertMessage alertMessage:@"可能没有查看权限哦！"];
                                    [self.navigationController popViewControllerAnimated:YES];
                                }else{
                                    [self.tableView reloadData];
                                }
                                
                            }else{
                                [BDWMAlertMessage alertMessage:@"获取不到数据."];
                                [self.navigationController popViewControllerAnimated:YES];
                            }
                        }];
                    }else{
                        [BDWMAlertMessage alertMessage:@"获取不到数据."];
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }];
            }else{
                //find topics.
                [self.tableView reloadData];
                
            }
        }else{
            [BDWMAlertMessage alertAndAutoDismissMessage:@"获取不到数据."];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    }else{
        task= [self.boardReader getBoardPostsWithBlock:^(NSMutableArray *posts, NSError *error) {
            if (!error) {
                self.boardPosts = posts;
                if ( self.boardPosts==nil || self.boardPosts.count == 0 ) {
                    //login session failed. then relogin.
                    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
                    NSString *userName1 = [userDefaultes stringForKey:@"saved_username"];
                    NSString *password = [userDefaultes stringForKey:@"saved_password"];
                    
                    [BDWMUserModel checkLogin:userName1 userPass:password blockFunction:^(NSString *name, NSError *error){
                        if ( !error && name!=nil ) {
                            //login success reload mail.
                            [self.boardReader getBoardPostsWithBlock:^(NSMutableArray *posts, NSError *error){
                                if (!error){
                                    self.boardPosts = posts;
                                    //login success but no posts.
                                    if (self.boardPosts==nil || self.boardPosts.count==0) {
                                        //
                                        [BDWMAlertMessage alertMessage:@"可能没有查看权限哦！"];
                                        [self.navigationController popViewControllerAnimated:YES];
                                    }else{
                                        [self.tableView reloadData];
                                    }
                                    
                                }else{
                                    [BDWMAlertMessage alertMessage:@"获取不到数据."];
                                    [self.navigationController popViewControllerAnimated:YES];
                                }
                            }];
                        }else{
                            [BDWMAlertMessage alertMessage:@"获取不到数据."];
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                    }];
                }else{
                    //find posts.
                    [self.tableView reloadData];
                }
            }else{
                [BDWMAlertMessage alertAndAutoDismissMessage:@"获取不到数据."];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
    
    [self.refreshControl setRefreshingWithStateOfTask:task];
    

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

    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 100.0f)];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    [self.tableView.tableHeaderView addSubview:self.refreshControl];
    
    self.bottomRefreshControl = [UIRefreshControl new];
    [self.bottomRefreshControl addTarget:self action:@selector(displayMore) forControlEvents:UIControlEventValueChanged];
    self.tableView.bottomRefreshControl = self.bottomRefreshControl;
    
    if (self.boardReader == nil) {
        BBSBoardReader *reader = [[BBSBoardReader alloc] initWithBoardName:self.boardName];
        self.boardReader = reader;
        self.boardReader.showSticky = YES;
        [reader release];
    }
    
    [self reload:nil];
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
