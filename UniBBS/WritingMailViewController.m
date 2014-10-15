//
//  WritingMailViewController.m
//  UniBBS
//
//  Created by fanyingming on 10/12/14.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import "WritingMailViewController.h"
#import "MailModel.h"
#import "BDWMGlobalData.h"
#import "BDWMString.h"
#import "AFAppDotNetAPIClient.h"
#import "BDWMAlertMessage.h"
#import "MailListViewController.h"

@interface WritingMailViewController ()
@property (retain, nonatomic) IBOutlet UITextField *toTextField;
@property (retain, nonatomic) IBOutlet UITextField *titleTextField;
@property (retain, nonatomic) IBOutlet UITextView *contentTextView;
@property (nonatomic, retain) NSMutableDictionary *replyDict;
@end

@implementation WritingMailViewController

- (IBAction)sendMailButtonPressed:(id)sender {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    dic = self.replyDict;
    
    [dic setObject:self.toTextField.text forKey:@"to"];
    [dic setObject:self.titleTextField.text forKey:@"title"];
    [dic setObject:self.contentTextView.text forKey:@"text"];
    
    NSString *url = [BDWMString linkString:BDWM_PREFIX string:BDWM_REPLY_MAIL_SUFFIX];
    [[AFAppDotNetAPIClient sharedClient] POST:url parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"Reply mail success!");
        //Todo: segue to mail list view.
        [self.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Reply mail failed!");
        [BDWMAlertMessage alertMessage:@"回复失败"];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.href != nil) {//reply mode
        self.replyDict = [MailModel loadReplyMailNeed:self.href];
        self.toTextField.text = [self.replyDict objectForKey:@"to"];
        self.titleTextField.text = [self.replyDict objectForKey:@"title"];
        self.contentTextView.text = [self.replyDict objectForKey:@"text"];
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
