//
//  PopularTopicsViewController.h
//  UniBBS
//
//  Created by Meng Shengbin on 3/7/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopularTopicsViewController : UITableViewController<UIActionSheetDelegate>

@property (nonatomic, retain) NSMutableArray *popularTopics;

@end
