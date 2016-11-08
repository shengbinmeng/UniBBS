//
//  PostViewController.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/7/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "PostViewController.h"
#import "BDWMPostReader.h"
#import "TopicViewController.h"
#import "BBSFavouritesManager.h"
#import "AttachmentsViewController.h"
#import "WritingViewController.h"
#import "WritingMailViewController.h"
#import "BDWMUserModel.h"
#import "BDWMAlertMessage.h"

@implementation PostViewController

@synthesize postURI, postAttributes, postReader;

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


- (void) showOptions
{
    UIActionSheet *sheet;
    if ([self.postAttributes valueForKey:@"attachments"] != nil) {
        sheet = [[UIActionSheet alloc] initWithTitle:@"选项" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"回复",@"发送站内信", @"收藏此贴", @"查看附件", nil];
    } else {
        sheet = [[UIActionSheet alloc] initWithTitle:@"选项" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"回复",@"发送站内信", @"收藏此贴", nil];
    }
    
    [sheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    NSInteger index = buttonIndex - actionSheet.firstOtherButtonIndex;
    switch (index) {
        case 0:{
            //check if logined
            if ([BDWMUserModel isLogined]) {
                // reply
                WritingViewController *reply = [[WritingViewController alloc] initWithNibName:@"WrittingViewController" bundle:nil];

                reply.href = [self.postAttributes objectForKey:@"replyAddress"];
                reply.fromWhere = @"reply";
                [self.navigationController pushViewController:reply animated:YES];
            }else{
                //did not logined
                //Todo: segue to login view, and if login success, segue to reply view.
                [BDWMAlertMessage alertAndAutoDismissMessage:@"登录以后才能回复呢."];
            }
            break;
        }
        case 1:{
            if ([BDWMUserModel isLogined]) {
                // reply mail
                WritingMailViewController *mail = [[WritingMailViewController alloc] initWithNibName:@"WritingMailViewController" bundle:nil] ;
                mail.href = [self.postAttributes objectForKey:@"replyMailAddress"];
                [self.navigationController pushViewController:mail animated:YES];
            }else{
                //did not logined
                //Todo: segue to login view, and if login success, segue to reply mail view.
                [BDWMAlertMessage alertAndAutoDismissMessage:@"登录以后才能写信呢."];
            }
            break;
        }
        case 2:{
            // add to favourites
            [BBSFavouritesManager saveFavouritePost:[self.postAttributes mutableCopy]];
            break;
        }
        case 3:{
            //view attachments
            AttachmentsViewController *attachViewController = [[AttachmentsViewController alloc] init];
            NSArray *attachments = [self.postAttributes valueForKey:@"attachments"];
            attachViewController.title = @"附件列表";
            attachViewController.attachments = attachments;
            [self.navigationController pushViewController:attachViewController animated:YES];
            break; 
        }
        default:
            break;
    }
}


- (void) displayPreviousPost
{
    NSDictionary *previousPost = [self.postReader getPreviousPost];
    if (previousPost == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"已没有上一篇" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    } else {
        self.postAttributes = previousPost;
        self.title = [self.postAttributes valueForKey:@"title"];
        [self.tableView reloadData];
        [self.tableView scrollsToTop];
    }
}

- (void) displayNextPost
{
    NSDictionary *nextPost = [self.postReader getNextPost];
    if (nextPost == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"已没有下一篇" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    } else {
        self.postAttributes = nextPost;
        self.title = [self.postAttributes valueForKey:@"title"];
        [self.tableView reloadData];
        [self.tableView scrollsToTop];
    }
}

- (void) expandSameTopic
{
    NSString *uri = [self.postReader getSameTopicUri];
    if (uri == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"展开失败，奇怪" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    } else {
        TopicViewController *topicViewController = [[TopicViewController alloc] initWithStyle:UITableViewStylePlain];
        topicViewController.title = @"同主题展开";
        topicViewController.topicURI = uri;
        [self.navigationController pushViewController:topicViewController animated:YES];   
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"选项" style:UIBarButtonItemStylePlain target:self action:@selector(showOptions)];
    self.navigationItem.rightBarButtonItem = button;
    
    UIBarButtonItem *prev = [[UIBarButtonItem alloc] initWithTitle:@"上一篇"
                                  style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(displayPreviousPost)];
    UIBarButtonItem *expan = [[UIBarButtonItem alloc] initWithTitle:@"同主题展开"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(expandSameTopic)];
    UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithTitle:@"下一篇"
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(displayNextPost)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *toolbarItems = [NSArray arrayWithObjects: 
                             prev,
                             space,
                             expan,
                             space,
                             next,
                             nil];

    [self setToolbarItems:toolbarItems animated:YES];
    
    if (self.postReader == nil) {
        // first time load, alloc the model
        BDWMPostReader *reader = [[BDWMPostReader alloc] initWithURI:self.postURI];
        self.postReader = reader;
        self.postAttributes = [self.postReader getPostAttributes];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:NO animated:YES];

    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:YES animated:YES];

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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PostCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    NSString *content = [self.postAttributes valueForKey:@"content"];
    CGFloat contentWidth = self.tableView.frame.size.width;
    UIFont *font = [UIFont systemFontOfSize:14];
    CGSize size = [content sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth, 8000) lineBreakMode:NSLineBreakByWordWrapping];
    CGRect rect = CGRectMake(0, 0, contentWidth, MAX(size.height, 44.0f) + 40);
    cell.textLabel.frame = rect;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.font = font;
    cell.textLabel.text = content;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showOptions];
}

- (CGFloat)tableView:(UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat contentWidth = self.tableView.frame.size.width;
    UIFont *font = [UIFont systemFontOfSize:14];
    
    NSString *content = [self.postAttributes valueForKey:@"content"];
    CGSize size = [content sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth, 8000) lineBreakMode:NSLineBreakByWordWrapping];
    
    return MAX(size.height, 44.0f) + 40; 
}

@end
