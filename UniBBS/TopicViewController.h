//
//  TopicViewController.h
//  UniBBS
//
//  Created by Meng Shengbin on 3/10/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BBSTopicReader;

@interface TopicViewController : UITableViewController <UIActionSheetDelegate>

@property (nonatomic, retain) NSString *topicURI;
@property (nonatomic, retain) NSMutableArray *topicPosts;
@property (nonatomic, retain) BBSTopicReader *topicReader;

@end
