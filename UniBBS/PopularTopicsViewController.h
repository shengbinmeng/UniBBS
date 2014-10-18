//
//  PopularTopicsViewController.h
//  UniBBS
//
//  Created by Meng Shengbin on 3/7/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "EGORefreshTableHeaderView.h"
@class BBSPopularReader;

@interface PopularTopicsViewController : UITableViewController
//<EGORefreshTableHeaderDelegate, UIActionSheetDelegate>

@property (nonatomic, retain) NSMutableArray *popularTopics;
@property (nonatomic, retain) BBSPopularReader *popularReader;

@end
