//
//  BoardListViewController.h
//  UniBBS
//
//  Created by Meng Shengbin on 3/7/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBSBoardListExplorer.h"

@interface BoardListViewController : UITableViewController<UISearchResultsUpdating>

@property (nonatomic, copy) NSString *listURI;
@property (nonatomic, strong) NSMutableArray *boardList;
@property (nonatomic, strong) BBSBoardListExplorer *boardExplorer;

@end
