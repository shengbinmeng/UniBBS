//
//  BoardListViewController.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/7/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "BoardListViewController.h"
#import "BBSBoardListExplorer.h"
#import "BoardViewController.h"

@implementation BoardListViewController {
    UISearchDisplayController *searchController;
    NSMutableArray *wholeBoardList;
    NSMutableArray *categaryBoardList;
    NSArray *searchResult;
    BOOL showingAll;
}

@synthesize listAddress, boardList, boardExplorer;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"分类讨论区";
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        showingAll = NO;
    }
    return self;
}


- (void) dealloc
{
    self.boardExplorer = nil;
    self.boardList = nil;
    self.listAddress = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


- (void) buttonPressed 
{
    NSString * option = @"全部版面";
    if (showingAll) {
        option = @"分类版面";
    }
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选项" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:option, nil];
    [sheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    NSInteger index = buttonIndex - actionSheet.firstOtherButtonIndex;
   
    switch (index) {
        case 0:
            showingAll = !showingAll;
            if (showingAll) self.boardList = wholeBoardList;
            else self.boardList = categaryBoardList;
            break;
        default:
            break;
    }
    
    [self.tableView reloadData];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if ([self.title isEqualToString:@"分类讨论区"]) {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"选项" style:UIBarButtonItemStyleBordered target:self action:@selector(buttonPressed)];
        self.navigationItem.rightBarButtonItem = button;
        [button release];
    }
        
    if ([self.title isEqualToString:@"分类讨论区"]) {
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        searchBar.placeholder = @"搜索讨论区（中文名称或英文ID）";
        searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.tableView.tableHeaderView = searchBar;
        searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
        [searchBar release];
        searchController.delegate = self;
        searchController.searchResultsDelegate = self;
        searchController.searchResultsDataSource = self;
    }
    
    if (self.boardExplorer == nil) {
        BBSBoardListExplorer *explorer = [[BBSBoardListExplorer alloc] initWithAddress:self.listAddress];
        self.boardExplorer = explorer;
        [explorer release];
    }
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view insertSubview:indicator aboveSubview:self.tableView];
    indicator.center = self.view.center;
    [indicator startAnimating];
    
    [self performSelectorInBackground:@selector(loadData:) withObject:indicator];
}

- (void) loadData:(UIActivityIndicatorView*) indicator {
    if ([self.title isEqualToString:@"分类讨论区"]) {
        BBSBoardListExplorer *explorer = [[BBSBoardListExplorer alloc] initWithAddress:self.listAddress];
        wholeBoardList = [[explorer getWholeBoardList] retain];
        [explorer release];
    }
    self.boardList = [self.boardExplorer getBoardList];
    categaryBoardList = [self.boardList retain];
    
    [self.tableView reloadData];
    [indicator stopAnimating];
    [indicator removeFromSuperview];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"name BEGINSWITH[c] %@ OR description CONTAINS %@",
                              searchString, searchString];
    searchResult = [[wholeBoardList filteredArrayUsingPredicate: predicate] retain];
    return YES;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [searchResult release];
    searchResult = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [searchController release];
    [wholeBoardList release];
    [categaryBoardList release];
    searchController = nil;
    wholeBoardList = nil;
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
        if (self.boardList != nil && self.boardList.count == 0) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"消息" message:@"未取到数据！可能是网络或其他原因导致。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert performSelector:@selector(show) withObject:nil afterDelay:0.5];
            [alert show];
            [alert release];
        }
        return boardList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BoardCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    NSDictionary *board;
    if (tableView == searchController.searchResultsTableView) {
        board = [searchResult objectAtIndex:[indexPath row]];
    } else {
        board = [boardList objectAtIndex:[indexPath row]];
    }
    NSString* boardDesc = [board objectForKey:@"description"];
    cell.textLabel.text = [boardDesc stringByAppendingFormat:@" (%@)",[board objectForKey:@"name"]];
    if ([[board objectForKey:@"isGroup"] isEqualToString:@"YES"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.font = [UIFont boldSystemFontOfSize:18];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   
    if (tableView == searchController.searchResultsTableView) {
        NSDictionary *board = [searchResult objectAtIndex:[indexPath row]];
        BoardViewController *boardViewController = [[BoardViewController alloc] initWithStyle:UITableViewStylePlain];
        boardViewController.title = [board objectForKey:@"description"];
        boardViewController.boardName = [board objectForKey:@"name"];
        [self.navigationController pushViewController:boardViewController animated:YES];
        [boardViewController release];
        return;
    }
    
    NSDictionary *board = [boardList objectAtIndex:[indexPath row]];
    if ([[board  valueForKey:@"isGroup"] isEqualToString:@"YES"]) {
        BoardListViewController * nextLevelBoardList = [[BoardListViewController alloc] initWithStyle:UITableViewStylePlain];
        nextLevelBoardList.listAddress = [board valueForKey:@"address"];
        nextLevelBoardList.title = [board objectForKey:@"description"];
        [self.navigationController pushViewController:nextLevelBoardList animated:YES];
        [nextLevelBoardList release];
    } else {
        BoardViewController *boardViewController = [[BoardViewController alloc] initWithStyle:UITableViewStylePlain];
        boardViewController.title = [board objectForKey:@"description"];
        boardViewController.boardName = [board objectForKey:@"name"];
        boardViewController.boardInfo = board;
        [self.navigationController pushViewController:boardViewController animated:YES];
        [boardViewController release];
    }
}

@end
