//
//  BoardListViewController.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/7/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "BoardListViewController.h"
#import "BBSBoardExplorer.h"
#import "PostListViewController.h"

@implementation BoardListViewController {
    BBSBoardExplorer* dataSource;
    NSMutableArray *boardList;
}

@synthesize listAddress;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"分类讨论区";
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


- (void) buttonPressed {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithTitle:@"Top" style:UIBarButtonItemStyleBordered target:self action:@selector(buttonPressed)] autorelease];
    self.navigationItem.rightBarButtonItem = button;
    
    BBSBoardExplorer *explorer = [[BBSBoardExplorer alloc] initWithAddress:listAddress];
    boardList = [explorer GetAllSubBoards];
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
    int n = [boardList count];
    return n;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BoardCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary *board = [boardList objectAtIndex:[indexPath row]];
    NSString* boardName = [board objectForKey:@"description"];
    NSString *extra = @"";
    if ([[board objectForKey:@"isGroup"] isEqualToString:@"YES"]) {
        extra = @"->";
    }
    cell.textLabel.text = [boardName stringByAppendingString:extra];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *board = [boardList objectAtIndex:[indexPath row]];
    if ([[board  valueForKey:@"isGroup"] isEqualToString:@"YES"]) {
        NSString* groupID = [board objectForKey:@"groupID"];
        BoardListViewController * nextLevelBoardList = [[[BoardListViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
        nextLevelBoardList.listAddress = [NSString stringWithFormat:@"http://www.bdwm.net/bbs/bbsxboa.php?group=%@", groupID];
        nextLevelBoardList.title = [board objectForKey:@"description"];
        [self.navigationController pushViewController:nextLevelBoardList animated:YES];

    } else {
        PostListViewController *boardPosts = [[PostListViewController alloc] init];
        boardPosts.title = [board objectForKey:@"description"];
        [self.navigationController pushViewController:boardPosts animated:YES];
    }
}

@end
