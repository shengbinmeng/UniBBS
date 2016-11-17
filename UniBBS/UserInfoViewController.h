//
//  UserInfoViewController.h
//  UniBBS
//
//  Created by fanyingming on 10/11/14.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfoViewController : UITableViewController<UIActionSheetDelegate>
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSDictionary *userInfoDict;
@end
