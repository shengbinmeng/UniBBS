//
//  FavouritesViewController.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/10/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "FavouritesViewController.h"
#import "BBSFavouritesManager.h"
#import "BoardViewController.h"
#import "TopicViewController.h"
#import "AttachmentsViewController.h"
#import "BDWMAlertMessage.h"

@implementation FavouritesViewController {
    NSMutableArray* favouriteBoards;
    NSMutableArray* favouriteTopics;
    NSMutableArray* favouritePosts;
    NSMutableArray* favourites;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"本地收藏";
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        // just assign, for easy using
        [BBSFavouritesManager loadFavourites];
        favouriteBoards = [BBSFavouritesManager favouriteBoards];
        favouriteTopics = [BBSFavouritesManager favouriteTopics];
        favouritePosts = [BBSFavouritesManager favouritePosts];
        favourites = [[NSMutableArray alloc] initWithObjects:favouriteBoards,favouriteTopics, favouritePosts, nil];
    }
    return self;
}

- (void) dealloc
{
    [favourites release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.editButtonItem.title = @"清除";
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    
//    // Make sure you call super first
//    [super setEditing:editing animated:animated];
//    
//    if (editing) {
//        self.editButtonItem.title = @"完成";
//    } else {
//        self.editButtonItem.title = @"编辑";
//    }
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
    [self.tableView reloadData];
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
    return [favourites count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[favourites objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *PostCellIdentifier = @"PostCell";

    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:([indexPath section] == 2 ? PostCellIdentifier : CellIdentifier)];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:([indexPath section] == 2 ? PostCellIdentifier : CellIdentifier)] autorelease];
    }
    
    // Configure the cell...
    if ([indexPath section] == 0) {
        NSDictionary *board = [favouriteBoards objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)",[board valueForKey:@"boardTitle"], [board valueForKey:@"boardName"]];
    } else if ([indexPath section] == 1) {
        cell.textLabel.text = [[favouriteTopics objectAtIndex:indexPath.row] valueForKey:@"title"];
    } else if ([indexPath section] == 2) {
        NSString *content = [[favouritePosts objectAtIndex:indexPath.row] valueForKey:@"content"];
        CGFloat contentWidth = self.tableView.frame.size.width;
        UIFont *font = [UIFont systemFontOfSize:14];
        CGSize size = [content sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth, 8000) lineBreakMode:NSLineBreakByWordWrapping];
        CGRect rect = CGRectMake(0, 0, contentWidth, MAX(size.height, 44.0f) + 40);
        cell.textLabel.frame = rect;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.font = font;
        cell.textLabel.text = content;
        if ([indexPath row] % 2 == 1) {
            cell.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
            cell.textLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
            
        } else {
            cell.contentView.backgroundColor = [UIColor lightGrayColor];
            cell.textLabel.backgroundColor = [UIColor lightGrayColor];
        }
    }
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSMutableDictionary *dict = [[favourites objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
        //delete from db.
        BOOL deleteSuccess = NO;
        if ([indexPath section] == 0) {
            deleteSuccess = [BBSFavouritesManager deleteFavouriteBoard:dict];
        } else if ([indexPath section] == 1) {
            deleteSuccess = [BBSFavouritesManager deleteFavouriteTopic:dict];
        } else if ([indexPath section] == 2) {
            deleteSuccess = [BBSFavouritesManager deleteFavouritePost:dict];
        }
        //delete from view.
        if (deleteSuccess==YES) {
            [[favourites objectAtIndex:[indexPath section]] removeObjectAtIndex:[indexPath row]];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }else{
            [BDWMAlertMessage alertMessage:@"删除失败。"];
        }
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


- (NSString *)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *header = @"";
    if (section == 0) {
        header = @"版面";
    } else if (section == 1) {
        header = @"话题";
    } else if (section == 2) {
        header = @"帖子";
    }
	return header;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    NSInteger index = buttonIndex - actionSheet.firstOtherButtonIndex;
    switch (index) {
        case 0:{
            AttachmentsViewController *attachViewController = [[[AttachmentsViewController alloc] init] autorelease];
            NSDictionary * post = [favouritePosts objectAtIndex:self.tableView.indexPathForSelectedRow.row];
            [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
            NSArray *attachments = [post valueForKey:@"attachments"];
            attachViewController.title = @"附件列表";
            attachViewController.attachments = attachments;
            [self.navigationController pushViewController:attachViewController animated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        NSDictionary *board = [favouriteBoards objectAtIndex:indexPath.row];
        BoardViewController *boardViewController = [[[BoardViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
        boardViewController.title = [board objectForKey:@"boardTitle"];
        boardViewController.boardName = [board objectForKey:@"boardName"];
        [self.navigationController pushViewController:boardViewController animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];

    }else if ([indexPath section] == 1) {
        NSDictionary *topic = [favouriteTopics objectAtIndex:[indexPath row]];
        TopicViewController *topicViewController = [[[TopicViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
        topicViewController.title = [topic valueForKey:@"title"];
        topicViewController.topicAddress = [topic valueForKey:@"address"];
        [self.navigationController pushViewController:topicViewController animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    } else if ([indexPath section] == 2) {
        NSDictionary * post = [favouritePosts objectAtIndex:indexPath.row];
        if ([post valueForKey:@"attachments"] != nil) {
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"查看附件", nil];
            [sheet showInView:self.view];
            [sheet release];
        } else {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath 
       toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath{
    if(sourceIndexPath.section != proposedDestinationIndexPath.section){
        return sourceIndexPath;
    }
    return proposedDestinationIndexPath;
}

- (CGFloat)tableView:(UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 2) {
        CGFloat contentWidth = self.tableView.frame.size.width;
        UIFont *font = [UIFont systemFontOfSize:14];
        NSString *content = [[favouritePosts objectAtIndex:indexPath.row] valueForKey:@"content"];
        CGSize size = [content sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth, 8000) lineBreakMode:NSLineBreakByWordWrapping];
        return MAX(size.height, 44.0f) + 40; 
    } else {
        return 44.0;
    }
}

@end
