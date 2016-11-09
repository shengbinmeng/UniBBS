//
//  TopicViewController.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/10/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "TopicViewController.h"
#import "BDWMTopicReader.h"
#import "PostViewController.h"
#import "BBSFavouritesManager.h"
#import "AttachmentsViewController.h"
#import "WritingViewController.h"
#import "WritingMailViewController.h"
#import "BDWMUserModel.h"
#import "BDWMAlertMessage.h"
#import <CCBottomRefreshControl/UIScrollView+BottomRefreshControl.h>

#define ACTION_FROM_BAR_BUTTON 8888
#define ACTION_FROM_VIEW_ATTACH 9999

@interface TopicViewController ()
@property (readwrite, nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation TopicViewController

@synthesize topicURI, topicPosts, topicReader;

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

- (void)reload:(__unused id)sender {
    
    NSURLSessionTask *task = [self.topicReader getTopicPostsWithBlock:^(NSMutableArray *topicPosts_t, NSError *error) {
        if (!error) {
            self.topicPosts = topicPosts_t;
            if ( self.topicPosts==nil || self.topicPosts.count == 0 ) {
                //login session failed. then relogin.
                NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
                NSString *userName1 = [userDefaultes stringForKey:@"saved_username"];
                NSString *password = [userDefaultes stringForKey:@"saved_password"];
                /*
                [BDWMUserModel checkLogin:userName1 userPass:password blockFunction:^(NSString *name, NSError *error){
                    if ( !error && name!=nil ) {
                        //login success reload topicposts.
                        [self.topicReader getTopicPostsWithBlock:^(NSMutableArray *topicPosts_t, NSError *error){
                            if (!error){
                                self.topicPosts = topicPosts_t;
                                //login success but no topicposts. seems impossible.
                                if (self.topicPosts==nil || self.topicPosts.count==0) {
                                    //
                                    [BDWMAlertMessage alertAndAutoDismissMessage:@"怎么会没有帖子！"];
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
                }];*/
            }else{
                //find topicposts.
                [self.tableView reloadData];
            }
        }else{
            [BDWMAlertMessage alertMessage:[error localizedDescription]];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];

    //    [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
//    [self.refreshControl setRefreshingWithStateOfTask:task];
    
    [((UIButton*)self.tableView.tableFooterView) setTitle:@"上拉载入更多" forState:UIControlStateNormal];
}

- (void)killScroll
{
    CGPoint offset = self.tableView.contentOffset;
    [self.tableView setContentOffset:offset animated:NO];
}

- (void) displayMore
{
    [self.topicReader getNextPostsWithBlock:^(NSMutableArray *topicPosts_t, NSError *error) {
        if (!error) {
            [self.topicPosts addObjectsFromArray:topicPosts_t];
            [self.tableView reloadData];
            [self killScroll];
        } else {
            [((UIButton*)self.tableView.tableFooterView) setTitle:@"没有更多" forState:UIControlStateNormal];
        }
        
        [self.tableView.bottomRefreshControl endRefreshing];
    }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    NSInteger index = buttonIndex - actionSheet.firstOtherButtonIndex;
    if (actionSheet.tag == ACTION_FROM_BAR_BUTTON) {
        // action sheet form bar buttom
        switch (index) {
            case 0:{
                [self.tableView scrollRectToVisible:self.tableView.tableFooterView.frame animated:YES];
                break;
            }
            case 1:{
                NSMutableDictionary *topicInfo = [[NSMutableDictionary alloc] init];
                [topicInfo setValue:self.title forKey:@"title"];
                [topicInfo setValue:self.topicURI forKey:@"address"];
                [BBSFavouritesManager saveFavouriteTopic:topicInfo];
                break;
            }
            default:
                break;
        }
    } else {
        // action from select row
        switch (index) {
            case 0:{
                //check if logined
                if ([BDWMUserModel isLogined]) {
                    // reply
                    WritingViewController *reply = [[WritingViewController alloc] initWithNibName:@"WrittingViewController" bundle:nil];
                    NSDictionary * postDict = [self.topicPosts objectAtIndex:self.tableView.indexPathForSelectedRow.row];
                    NSInteger index = [self.topicURI rangeOfString:@"/"].location;
                    NSString* board = [self.topicURI substringToIndex:index];
                    NSString* threadid = [self.topicURI substringFromIndex:index+1];
                    
                    reply.fromWhere = @"reply";
                    reply.board = board;
                    reply.threadid = threadid;
                    reply.postid = (NSString *)[postDict objectForKey:@"postid"];
                    reply.author = (NSString *)[postDict objectForKey:@"author"];
                    
                    [self.navigationController pushViewController:reply animated:YES];
                } else {
                    //did not logined
                    //Todo: segue to login view, and if login success, segue to reply view.
                    [BDWMAlertMessage alertAndAutoDismissMessage:@"登录以后才能回复呢."];
                }
                
                break;
            }
            case 1:{
                [BDWMAlertMessage alertMessage:@"站内信功能暂时下线啦，请在web端进行处理~"];
                /*
                 if ([BDWMUserModel isLogined]) {
                     // reply mail
                     WritingMailViewController *mail = [[WritingMailViewController alloc] initWithNibName:@"WritingMailViewController" bundle:nil];
                     NSDictionary * post = [self.topicPosts objectAtIndex:self.tableView.indexPathForSelectedRow.row];
                     mail.href = [post objectForKey:@"replyMailAddress"];
                     [self.navigationController pushViewController:mail animated:YES];
                 }else{
                     //did not logined
                     //Todo: segue to login view, and if login success, segue to reply mail view.
                     [BDWMAlertMessage alertAndAutoDismissMessage:@"登录以后才能写信呢."];
                 }
                */
                break;
            }
            case 2:{
                // favourite
                NSMutableDictionary * post = [self.topicPosts objectAtIndex:self.tableView.indexPathForSelectedRow.row];
                [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
                // TODO: Fix this.
                //[BBSFavouritesManager saveFavouritePost:post];
                break;
            }
            case 3:{
                // attachments
                AttachmentsViewController *attachViewController = [[AttachmentsViewController alloc] init];
                NSDictionary * post = [self.topicPosts objectAtIndex:self.tableView.indexPathForSelectedRow.row];
                [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
                NSArray *attachments = [post valueForKey:@"attachments"];
                attachViewController.title = @"附件列表";
                attachViewController.attachments = attachments;
                [self.navigationController pushViewController:attachViewController animated:YES];
                break;
            }
            default:
                [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
                break;
        }

    }
}


- (void) barButtonPressed
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选项" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"滚动到底部", @"收藏此话题", nil];
    [sheet setTag:ACTION_FROM_BAR_BUTTON];
    [sheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"选项" style:UIBarButtonItemStylePlain target:self action:@selector(barButtonPressed)];
    self.navigationItem.rightBarButtonItem = barButton;

    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 100.0f)];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    [self.tableView.tableHeaderView addSubview:self.refreshControl];
    
    UIRefreshControl *bottomRefreshControl = [UIRefreshControl new];
    [bottomRefreshControl addTarget:self action:@selector(displayMore) forControlEvents:UIControlEventValueChanged];
    self.tableView.bottomRefreshControl = bottomRefreshControl;
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button1 setTitle:@"上拉载入更多" forState:UIControlStateNormal];
    [button1 setFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 44.0)];
    [self.tableView setTableFooterView:button1];
    [self.tableView.tableFooterView setHidden:YES];

    if (self.topicReader == nil) {
        // first time load, alloc the model
        BDWMTopicReader *reader = [[BDWMTopicReader alloc] initWithURI:self.topicURI];
        self.topicReader = reader;
        [self reload:nil];
    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tableView.separatorColor = [UIColor colorWithRed:246.0/255 green:18.0/255 blue:81.0/255 alpha:1.0];
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
    if (self.topicPosts != nil && self.topicPosts.count == 0) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"消息" message:@"未取到数据！可能是网络或其他原因导致。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert performSelector:@selector(show) withObject:nil afterDelay:0.5];
        [alert show];
    }
    return [self.topicPosts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UIFont *font = [UIFont systemFontOfSize:14];
    NSString *content = [[self.topicPosts objectAtIndex:indexPath.row] valueForKey:@"content"];

    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = font;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:[content dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    
    NSDictionary *attributes = @{NSFontAttributeName:font};
    [attributedString addAttributes:attributes range:NSMakeRange(0, attributedString.length)];
    
    cell.textLabel.attributedText = attributedString;
    cell.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    cell.textLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIActionSheet *sheet;
    NSDictionary * post = [self.topicPosts objectAtIndex:indexPath.row];
    if ([post valueForKey:@"attachments"] != nil) {
        sheet = [[UIActionSheet alloc] initWithTitle:@"操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"回复", @"回信给作者", @"收藏此帖", @"查看附件", nil];
    } else {
        sheet = [[UIActionSheet alloc] initWithTitle:@"操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"回复", @"回信给作者", @"收藏此帖", nil];
    }
    [sheet showInView:self.view];
}

- (CGFloat)tableView:(UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat contentWidth = self.tableView.frame.size.width;
    UIFont *font = [UIFont systemFontOfSize:14];
    
    NSString *content = [[self.topicPosts objectAtIndex:indexPath.row] valueForKey:@"content"];
    CGSize size = [content sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth, 8000) lineBreakMode:NSLineBreakByWordWrapping];
    
    return MAX(size.height, 44.0f) + 40; 
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // check if indexPath.row is last row
    if (indexPath.row == self.topicPosts.count - 1) {
        [self.tableView.tableFooterView setHidden:NO];
    }
}

@end
