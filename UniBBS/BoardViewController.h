//
//  BoardViewController.h
//  UniBBS
//
//  Created by Meng Shengbin on 3/7/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBSBoardReader.h"

@interface BoardViewController : UITableViewController 
<UIActionSheetDelegate>

@property (nonatomic, retain) NSString *boardURI;
@property (nonatomic, retain) NSString *boardName;
@property (nonatomic, retain) BBSBoardReader *boardReader;
@property (nonatomic, retain) NSMutableArray *boardTopics;

@end
