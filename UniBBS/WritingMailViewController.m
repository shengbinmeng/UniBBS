//
//  WritingMailViewController.m
//  UniBBS
//
//  Created by fanyingming on 10/12/14.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import "WritingMailViewController.h"
#import "MailModel.h"
@interface WritingMailViewController ()
@property (retain, nonatomic) IBOutlet UITextField *toTextField;
@property (retain, nonatomic) IBOutlet UITextField *titleTextField;
@property (retain, nonatomic) IBOutlet UITextView *contentTextView;
@property (nonatomic, retain) NSMutableDictionary *replyDict;
@end

@implementation WritingMailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.href != nil) {//reply mode
        self.replyDict = [MailModel loadReplyMailNeed:self.href];
        self.toTextField.text = [self.replyDict objectForKey:@"to"];
        self.titleTextField.text = [self.replyDict objectForKey:@"title"];
        self.contentTextView.text = [self.replyDict objectForKey:@"content"];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_toTextField release];
    [_titleTextField release];
    [_contentTextView release];
    [super dealloc];
}
@end
