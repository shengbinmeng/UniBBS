//
//  BoardListViewController.h
//  UniBBS
//
//  Created by Meng Shengbin on 3/7/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BBSBoardListExplorer;
@interface BoardListViewController : UITableViewController 
<UIActionSheetDelegate, UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, retain) NSString *listAddress;
@property (nonatomic, retain) NSMutableArray *boardList;
@property (nonatomic, retain) BBSBoardListExplorer *boardExplorer;

@end
