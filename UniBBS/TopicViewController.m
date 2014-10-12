//
//  TopicViewController.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/10/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "TopicViewController.h"
#import "BBSTopicReader.h"
#import "PostViewController.h"
#import "BBSFavouritesManager.h"
#import "AttachmentsViewController.h"
#import "WrittingViewController.h"
#import "MailViewController.h"
#define ACTION_FROM_BAR_BUTTON 8888
#define ACTION_FROM_VIEW_ATTACH 9999

@implementation TopicViewController 

@synthesize topicAddress, topicPosts, topicReader, topicInfo;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.topicPosts = nil;
    self.topicReader = nil;
    self.topicAddress = nil;
    self.topicInfo = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) displayNextPage
{
    NSMutableArray *posts = [self.topicReader readNextPage];
    if(posts != nil) {
        self.topicPosts = posts;
        [self.tableView reloadData];
        if (posts.count == 0) {
            // should not continu to scrollToRow
            return;
        }
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"消息" message:@"已没有下一页" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
}

- (void) displayPreviousPage
{
    NSMutableArray *posts = [self.topicReader readPreviousPage];
    if(posts != nil) {
        self.topicPosts = posts;
        [self.tableView reloadData];
        if (posts.count == 0) {
            // should not continu to scrollToRow
            return;
        }
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"消息" message:@"已没有上一页" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
}

- (void) displayLastPage
{
    NSMutableArray *posts = [self.topicReader readLastPage];
    if(posts != nil) {
        self.topicPosts = posts;
        [self.tableView reloadData];
        if (posts.count == 0) {
            // should not continu to scrollToRow
            return;
        }
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:topicPosts.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    } else {
        if (self.topicPosts.count != 0) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:topicPosts.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}
 
- (void) displayFirstPage
{
    NSMutableArray *posts = [self.topicReader readFirstPage];
    if(posts != nil) {
        self.topicPosts = posts;
        [self.tableView reloadData];
        if (posts.count == 0) {
            // should not continu to scrollToRow
            return;
        }
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    } else {
        if (self.topicPosts.count != 0) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    int index = buttonIndex - actionSheet.firstOtherButtonIndex;
    if (actionSheet.tag == ACTION_FROM_BAR_BUTTON) {
        // action sheet form bar buttom
        switch (index) {
            case 0:{
                [self.tableView scrollRectToVisible:self.tableView.tableFooterView.frame animated:YES];
                break;
            }
            case 1:{
                if (self.topicInfo == nil) {
                    self.topicInfo = [[NSDictionary alloc] init];
                    [self.topicInfo setValue:self.title forKey:@"title"];
                    [self.topicInfo setValue:self.topicAddress forKey:@"address"];
                }
                [[BBSFavouritesManager favouriteTopics] addObject:self.topicInfo];                
                break;
            }
            default:
                break;
        }
    } else {
        // action from select row
        switch (index) {
            case 0:{
                // reply
                WrittingViewController *reply = [[[WrittingViewController alloc] initWithNibName:@"WrittingViewController" bundle:nil] autorelease];
                NSDictionary * post = [self.topicPosts objectAtIndex:self.tableView.indexPathForSelectedRow.row];
                reply.href = [post objectForKey:@"replyAddress"];
                reply.fromWhere = @"reply";
                [self.navigationController pushViewController:reply animated:YES];
                break;
            }
            case 1:{
                // reply mail
                MailViewController *mail = [[[MailViewController alloc] initWithNibName:@"MailViewController" bundle:nil] autorelease];
                [self.navigationController pushViewController:mail animated:YES];
                break;
            }
            case 2:{
                // favourite
                NSDictionary * post = [self.topicPosts objectAtIndex:self.tableView.indexPathForSelectedRow.row];
                [[BBSFavouritesManager favouritePosts] addObject:post];
                [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
                break;
            }
            case 3:{
                // attachments
                AttachmentsViewController *attachViewController = [[[AttachmentsViewController alloc] init] autorelease];
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
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选项" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"底部工具栏", @"收藏此话题", nil];
    [sheet setTag:ACTION_FROM_BAR_BUTTON];
    [sheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    [sheet release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *barButton = [[[UIBarButtonItem alloc] initWithTitle:@"选项" style:UIBarButtonItemStyleBordered target:self action:@selector(barButtonPressed)] autorelease];
    self.navigationItem.rightBarButtonItem = barButton;
    
    UIToolbar *toolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 44.0)] autorelease];
    UIBarButtonItem *prev = [[[UIBarButtonItem alloc] initWithTitle:@"上一页" style:UIBarButtonItemStyleBordered target:self action:@selector(displayPreviousPage)] autorelease];
    UIBarButtonItem *next = [[[UIBarButtonItem alloc] initWithTitle:@"下一页" style:UIBarButtonItemStyleBordered target:self action:@selector(displayNextPage)] autorelease];
    //UIBarButtonItem *first = [[[UIBarButtonItem alloc] initWithTitle:@"最旧贴" style:UIBarButtonItemStyleBordered target:self action:@selector(displayFirstPage)] autorelease];
    //UIBarButtonItem *last = [[[UIBarButtonItem alloc] initWithTitle:@"最新贴" style:UIBarButtonItemStyleBordered target:self action:@selector(displayLastPage)] autorelease];
    UIBarButtonItem *space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    NSArray *toolbarItems = [NSArray arrayWithObjects: prev, space, next, nil];
    [toolBar setItems:toolbarItems];
    [self.tableView setTableFooterView:toolBar];

    if (self.topicReader == nil) {
        // first time load, alloc the model
        BBSTopicReader *reader = [[BBSTopicReader alloc] initWithAddress:self.topicAddress];
        self.topicReader = reader;
        [reader release];
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.view insertSubview:indicator aboveSubview:self.tableView];
        indicator.center = self.navigationController.view.window.center;
        [indicator startAnimating];
        
        [self.tableView.tableFooterView setHidden:YES];
        [self loadData:indicator];
    }
}

- (void) loadData:(UIActivityIndicatorView*) indicator {
    self.topicPosts = [self.topicReader readTopicPosts];
    [self.tableView reloadData];
    [indicator stopAnimating];
    [indicator removeFromSuperview];
    [self.tableView.tableFooterView setHidden:NO];
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
        [alert release];
    }
    return [self.topicPosts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    //CGFloat contentWidth = self.tableView.frame.size.width;
    UIFont *font = [UIFont systemFontOfSize:14];
    NSString *content = [[self.topicPosts objectAtIndex:indexPath.row] valueForKey:@"content"];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = font;
    cell.textLabel.text = content;
    
    if ([indexPath row] % 2 == 0) {
        cell.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        cell.textLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];

    } else {
        cell.contentView.backgroundColor = [UIColor lightGrayColor];
        cell.textLabel.backgroundColor = [UIColor lightGrayColor];
    }
    
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
    [sheet showInView:self.view.window];
    [sheet release];
}

- (CGFloat)tableView:(UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat contentWidth = self.tableView.frame.size.width;
    UIFont *font = [UIFont systemFontOfSize:14];
    
    NSString *content = [[self.topicPosts objectAtIndex:indexPath.row] valueForKey:@"content"];
    CGSize size = [content sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth, 8000) lineBreakMode:NSLineBreakByWordWrapping];
    
    return MAX(size.height, 44.0f) + 40; 
}

@end
