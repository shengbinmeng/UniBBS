//
//  PostViewController.h
//  UniBBS
//
//  Created by Meng Shengbin on 3/7/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDWMPostReader.h"

@interface PostViewController : UITableViewController
<UIActionSheetDelegate>

@property (nonatomic, retain) NSString *postURI;
@property (nonatomic, retain) NSDictionary *postAttributes;
@property (nonatomic, retain) BDWMPostReader *postReader;

@end
