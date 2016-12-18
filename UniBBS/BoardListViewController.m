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

@implementation BoardListViewController {
    UISearchController *searchController;
    NSMutableArray *wholeBoardList;
    NSMutableArray *categaryBoardList;
    NSArray *searchResult;
    BOOL showingAll;
}

@synthesize listURI, boardList, boardExplorer;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"分类讨论区";
        self.tabBarItem.image = [UIImage imageNamed:@"boards"];
        showingAll = NO;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIBarButtonItem *optionButton = [[UIBarButtonItem alloc] initWithTitle:@"选项" style:UIBarButtonItemStylePlain target:self action:@selector(optionButtonPressed:)];
    self.navigationItem.rightBarButtonItem = optionButton;
    
    searchController = [[UISearchController alloc] initWithSearchResultsController:self];
    searchController.searchResultsUpdater = self;
    searchController.searchBar.placeholder = @"搜索讨论区（中文名称或英文ID）";
    self.tableView.tableHeaderView = searchController.searchBar;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    
    self.boardExplorer = [[BDWMBoardListExplorer alloc] initWithURI:listURI];
    
    [self.refreshControl beginRefreshing];
    [self reloadData];
}

- (void)optionButtonPressed:(UIBarButtonItem *)sender
{
    NSString *current = [NSString stringWithFormat:@"当前选择: %@", showingAll ? @"全部版面" : @"分类版面"];
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"选择" message:current preferredStyle:UIAlertControllerStyleActionSheet];
    [sheet addAction:[UIAlertAction actionWithTitle:@"分类版面" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        showingAll = FALSE;
        self.boardList = categaryBoardList;
        [self.tableView reloadData];
    }]];
    [sheet addAction:[UIAlertAction actionWithTitle:@"全部版面" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        showingAll = TRUE;
        self.boardList = wholeBoardList;
        [self.tableView reloadData];
    }]];
    [sheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL]];
    sheet.popoverPresentationController.barButtonItem = sender;
    [self presentViewController:sheet animated:true completion:NULL];
}

- (void)reloadData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        wholeBoardList = [self.boardExplorer getWholeBoardList];
        categaryBoardList = [self.boardExplorer getBoardList];
        self.boardList = categaryBoardList;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.boardList.count == 0) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"未取到数据！可能是网络或其他原因导致。" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:NULL]];
                [self presentViewController:alert animated: TRUE completion:^{
                    [self.refreshControl endRefreshing];
                }];
            } else {
                [self.tableView reloadData];
                [self.refreshControl endRefreshing];
            }
        });
    });
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)aSearchController
{
    NSString *searchString = aSearchController.searchBar.text;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"name BEGINSWITH[c] %@ OR description CONTAINS %@",
                              searchString, searchString];
    searchResult = [wholeBoardList filteredArrayUsingPredicate:predicate];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (searchController.active) {
        return searchResult.count;
    } else {
        return boardList.count;
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
    if (searchController.active) {
        board = [searchResult objectAtIndex:[indexPath row]];
    } else {
        board = [boardList objectAtIndex:[indexPath row]];
    }
    NSString *boardDesc = [board objectForKey:@"description"];
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
    if (searchController.active) {
        NSDictionary *board = [searchResult objectAtIndex:[indexPath row]];
        BoardViewController *boardViewController = [[BoardViewController alloc] initWithStyle:UITableViewStylePlain];
        boardViewController.title = [board objectForKey:@"description"];
        boardViewController.boardURI = [board objectForKey:@"name"];
        [self.navigationController pushViewController:boardViewController animated:YES];
        return;
    }
    
    NSDictionary *board = [boardList objectAtIndex:[indexPath row]];
    if ([[board  valueForKey:@"isGroup"] isEqualToString:@"YES"]) {
        BoardListViewController * nextLevelBoardList = [[BoardListViewController alloc] initWithStyle:UITableViewStylePlain];
        nextLevelBoardList.listURI = [board valueForKey:@"address"];
        nextLevelBoardList.title = [board objectForKey:@"description"];
        [self.navigationController pushViewController:nextLevelBoardList animated:YES];
    } else {
        BoardViewController *boardViewController = [[BoardViewController alloc] initWithStyle:UITableViewStylePlain];
        boardViewController.title = [board objectForKey:@"description"];
        boardViewController.boardURI = [board objectForKey:@"name"];
        [self.navigationController pushViewController:boardViewController animated:YES];
    }
}

@end
