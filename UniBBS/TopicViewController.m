//
//  TopicViewController.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/10/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "TopicViewController.h"
#import "BDWMTopicReader.h"
#import "BDWMFavouritesManager.h"
#import "AttachmentsViewController.h"
#import "WritingViewController.h"
#import "WritingMailViewController.h"
#import "BDWMUserModel.h"
#import "BDWMAlertMessage.h"

#define ACTION_FROM_BAR_BUTTON 8888
#define ACTION_FROM_VIEW_ATTACH 9999

@interface TopicViewController ()

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
    [self.topicReader getTopicPostsWithBlock:^(NSMutableArray *topicPosts_t, NSError *error) {
        if (!error) {
            self.topicPosts = topicPosts_t;
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }else{
            [BDWMAlertMessage alertMessage:[error localizedDescription]];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void) displayMore
{
    [self.topicReader getNextPostsWithBlock:^(NSMutableArray *topicPosts_t, NSError *error) {
        if (!error) {
            [self.topicPosts addObjectsFromArray:topicPosts_t];
            [self.tableView reloadData];
        } else {
            [((UIButton*)self.tableView.tableFooterView) setTitle:@"没有更多" forState:UIControlStateNormal];
        }
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
                [BDWMFavouritesManager saveFavouriteTopic:topicInfo];
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
                    reply.number = (NSString *)[postDict objectForKey:@"number"];
                    reply.timestamp = (NSString *)[postDict objectForKey:@"timestamp"];
                    reply.replyTitle = self.title;
                    
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
                [BDWMFavouritesManager saveFavouritePost:[post mutableCopy]];
                break;
            }
            case 3:{
                // attachments
                AttachmentsViewController *attachViewController = [[AttachmentsViewController alloc] init];
                NSDictionary *post = [self.topicPosts objectAtIndex:self.tableView.indexPathForSelectedRow.row];
                [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
                NSString *attaches = [post valueForKey:@"attaches"];
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=\"([^\"]*)\"[^>]*>([^<]*)</a>" options:0 error:NULL];
                NSArray *result = [regex matchesInString:attaches options:0 range:NSMakeRange(0, attaches.length)];
                NSMutableArray * attachments = [[NSMutableArray alloc] init];
                if ([result count] != 0) {
                    for (int i = 0; i < [result count]; ++i) {
                        NSMutableDictionary * attach = [[NSMutableDictionary alloc] init];
                        NSTextCheckingResult *r = [result objectAtIndex:i];
                        NSString *url = [attaches substringWithRange:[r rangeAtIndex:1]];
                        // Note that the API doesn't document the URL encoding. Now it is GB18030 and they may change it later.
                        url = [url stringByAddingPercentEscapesUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
                        NSString *name = [attaches substringWithRange:[r rangeAtIndex:2]];
                        [attach setValue:url forKey:@"url"];
                        [attach setValue:name forKey:@"name"];
                        [attachments addObject:attach];
                    }
                }
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

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    [self.tableView.tableHeaderView addSubview:self.refreshControl];
    
    UIButton *bottomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [bottomButton setTitle:@"正在加载" forState:UIControlStateNormal];
    [bottomButton setFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 44.0)];
    [self.tableView setTableFooterView:bottomButton];
    [self.tableView.tableFooterView setHidden:YES];

    if (self.topicReader == nil) {
        // first time load, alloc the model
        BDWMTopicReader *reader = [[BDWMTopicReader alloc] initWithURI:self.topicURI];
        self.topicReader = reader;
    }
    
    [self.refreshControl layoutIfNeeded];
    [self.refreshControl beginRefreshing];
    [self reload:nil];
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
    
    NSString *orignalContent = [[self.topicPosts objectAtIndex:indexPath.row] valueForKey:@"content"];
    
    NSMutableString *content = [[NSMutableString alloc] initWithString:orignalContent];
    // Remove all embeded image because we can not display them in text label. And the problem is they will also make it slower to create attributed string below.
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<img[^>]+>" options:0 error:NULL];
    [regex replaceMatchesInString:content options:0 range:NSMakeRange(0, [content length]) withTemplate:@""];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:[content dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    
    UIFont *font = [UIFont systemFontOfSize:14];
    NSDictionary *attributes = @{NSFontAttributeName:font};
    [attributedString addAttributes:attributes range:NSMakeRange(0, attributedString.length)];
    
    cell.textLabel.attributedText = attributedString;
    cell.textLabel.font = font;
    cell.textLabel.numberOfLines = 0;
    cell.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    cell.textLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIActionSheet *sheet;
    NSDictionary * post = [self.topicPosts objectAtIndex:indexPath.row];
    NSString *attaches = [post valueForKey:@"attaches"];
    if (attaches != nil && attaches.length != 0) {
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
    NSMutableString *postText = [[NSMutableString alloc] initWithString:content];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<[^>]+>" options:0 error:NULL];
    [regex replaceMatchesInString:postText options:0 range:NSMakeRange(0, [postText length]) withTemplate:@""];
    
    CGSize size = [postText sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth, 8000) lineBreakMode:NSLineBreakByWordWrapping];
    
    return MAX(size.height, 44.0f) + 40;
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
