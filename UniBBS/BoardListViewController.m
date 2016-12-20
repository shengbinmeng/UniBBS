//
//  BoardListViewController.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/7/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "BoardListViewController.h"
#import "BDWMBoardListExplorer.h"
#import "BoardViewController.h"
#import "BDWMAlertMessage.h"

@implementation BoardListViewController {
    UISearchDisplayController *searchController;
    NSArray *searchResult;
}

@synthesize listURI, boardList, boardExplorer;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"全部版面";
        self.tabBarItem.image = [UIImage imageNamed:@"boards"];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    searchBar.placeholder = @"搜索版面（中文名称或英文ID）";
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.tableView.tableHeaderView = searchBar;
    searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchController.delegate = self;
    searchController.searchResultsDelegate = self;
    searchController.searchResultsDataSource = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    
    if (self.boardExplorer == nil) {
        BDWMBoardListExplorer *explorer = [[BDWMBoardListExplorer alloc] initWithURI:self.listURI];
        self.boardExplorer = explorer;
    }
    
    [self.refreshControl layoutIfNeeded];
    [self.refreshControl beginRefreshing];
    [self reload:nil];
}

- (void)reload:(__unused id)sender {
        
    [self.boardExplorer getWholeBoardListWithBlock:^(NSMutableArray *allboards, NSError *error) {
        if (!error) {
            self.boardList = allboards;
            if (self.boardList.count == 0) {
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

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"board CONTAINS[c] %@ OR name CONTAINS %@",
                              searchString, searchString];
    searchResult = [self.boardList filteredArrayUsingPredicate: predicate];
    return YES;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    searchResult = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    searchController = nil;
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
    if (tableView == searchController.searchResultsTableView) {
        return searchResult.count;
    } else {
        return self.boardList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BoardCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    NSDictionary *board;
    if (tableView == searchController.searchResultsTableView) {
        board = [searchResult objectAtIndex:[indexPath row]];
    } else {
        board = [boardList objectAtIndex:[indexPath row]];
    }
    NSString *boardName = [board objectForKey:@"name"];
    cell.textLabel.text = [boardName stringByAppendingFormat:@" (%@)", [board objectForKey:@"board"]];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *board = [boardList objectAtIndex:[indexPath row]];
    if (tableView == searchController.searchResultsTableView) {
        board = [searchResult objectAtIndex:[indexPath row]];
    }
    BoardViewController *boardViewController = [[BoardViewController alloc] initWithStyle:UITableViewStylePlain];
    boardViewController.title = [board objectForKey:@"name"];
    boardViewController.boardURI = [board objectForKey:@"board"];
    [self.navigationController pushViewController:boardViewController animated:YES];
}

@end
