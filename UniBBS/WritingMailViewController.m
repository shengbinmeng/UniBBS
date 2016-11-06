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

- (void)doReply
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    dic = self.replyDict;
    
    [dic setObject:self.toTextField.text forKey:@"to"];
    [dic setObject:self.titleTextField.text forKey:@"title"];
    [dic setObject:self.contentTextView.text forKey:@"text"];
    
    NSString *url = [BDWMString linkString:BDWM_PREFIX string:BDWM_REPLY_MAIL_SUFFIX];
    [[AFAppDotNetAPIClient sharedClient] POST:url parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Reply mail success!");
        [BDWMAlertMessage stopSpinner];
        //Todo: segue to mail list view.
        [self.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Reply mail failed!");
        [BDWMAlertMessage stopSpinner];
        [BDWMAlertMessage alertAndAutoDismissMessage:@"回复失败"];
    }];
}

- (void)doCompose
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    dic = [MailModel loadComposeMailNeededData];
    
    [dic setObject:self.toTextField.text forKey:@"to"];
    [dic setObject:self.titleTextField.text forKey:@"title"];
    [dic setObject:self.contentTextView.text forKey:@"text"];
    
    NSString *url = [BDWMString linkString:BDWM_PREFIX string:BDWM_REPLY_MAIL_SUFFIX];
    [[AFAppDotNetAPIClient sharedClient] POST:url parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"compose mail success!");
        [BDWMAlertMessage stopSpinner];
        //Todo: segue to mail list view.
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"compose mail failed!");
        [BDWMAlertMessage stopSpinner];
        [BDWMAlertMessage alertAndAutoDismissMessage:@"发送失败"];
    }];
}

- (void) sendButtonPressed {
    if (self.toTextField.text.length == 0) {
        [BDWMAlertMessage alertAndAutoDismissMessage:@"哥! 给谁发呢?"];
        return;
    }
    if (self.titleTextField.text.length == 0) {
        [BDWMAlertMessage alertAndAutoDismissMessage:@"哥! 写个主题再发么!"];
        return;
    }
    if (self.contentTextView.text.length == 0) {
        [BDWMAlertMessage alertAndAutoDismissMessage:@"哥! 写点内容吧!"];
        return;
    }
    [BDWMAlertMessage startSpinner:@"发送数据中..."];
    if (self.href != nil) {//reply mode
        [self doReply];
    }else{
        [self doCompose];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    if (self.href != nil) {//reply mode
        [BDWMAlertMessage startSpinner:@"加载数据..."];
        self.replyDict = [MailModel loadReplyMailNeededData:self.href];
        if (self.replyDict == nil) {
            [BDWMAlertMessage stopSpinner];
            [BDWMAlertMessage alertMessage:@"不能回复!是不是登录过期了？"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        self.toTextField.text = [self.replyDict objectForKey:@"to"];
        self.titleTextField.text = [self.replyDict objectForKey:@"title"];
        self.contentTextView.text = [self.replyDict objectForKey:@"text"];
        [BDWMAlertMessage stopSpinner];
    }else{
        //compose mode do nothing here.
        [self.toTextField becomeFirstResponder];
    }
}

- (void) hideKeyboard {
    [self.contentTextView resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleBordered target:self action:@selector(sendButtonPressed)];
    self.navigationItem.rightBarButtonItem = button;
    
    int screenWidth = [[UIScreen mainScreen] bounds].size.width;
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 36)];
    [topView setBarStyle:UIBarStyleDefault];
    
    // Used as place holder
    UIBarButtonItem * button1 = [[UIBarButtonItem  alloc] initWithBarButtonSystemItem:                                        UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone  target:self action:@selector(hideKeyboard)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:button1, button1, button1, doneButton,nil];
    [topView setItems:buttonsArray];
    
    [self.contentTextView setInputAccessoryView:topView];
    
    self.titleTextField.delegate = self;
    self.toTextField.delegate = self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.toTextField) {
        [self.titleTextField becomeFirstResponder];
    } else if (theTextField == self.titleTextField){
        [self.contentTextView becomeFirstResponder];
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
