//
//  WebViewController.h
//  UniBBS
//
//  Created by Meng Shengbin on 4/13/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, retain) NSString *webAddress;
@property (nonatomic, retain) NSString *barTitle;

@end
