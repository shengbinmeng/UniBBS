//
//  WritingViewController.h
//  UniBBS
//
//  Created by fanyingming on 10/12/14.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WritingViewController : UIViewController
@property (strong, nonatomic) NSString *board;
@property (strong, nonatomic) NSString *fromWhere;
@property (strong, nonatomic) NSString *threadid;
@property (strong, nonatomic) NSString *postid;
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSString *replyTitle;
@property (strong, nonatomic) NSString *number;
@property (strong, nonatomic) NSString *timestamp;
@end
