//
//  WritingViewController.m
//  UniBBS
//
//  Created by fanyingming on 10/12/14.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import "WritingViewController.h"
#import "AFAppDotNetAPIClient.h"
#import "BDWMAlertMessage.h"
#import "BDWMSettings.h"
#import "BDWMUserModel.h"
#import "BDWMPostWriter.h"

@interface WritingViewController ()
@property (retain, nonatomic) IBOutlet UITextField *titleTextField;
@property (retain, nonatomic) IBOutlet UITextView *contentTextView;
@property (strong, nonatomic) NSDictionary *postDict;
@end

@implementation WritingViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nil bundle:nil];
    return self;
}

- (void)doReply
{
    NSString *title = self.titleTextField.text;
    NSString *content = self.contentTextView.text;
    
    if (title.length == 0) {
        [BDWMAlertMessage alertAndAutoDismissMessage:@"亲，忘记写标题了。"];
        return;
    }
    if (content.length == 0) {
        [BDWMAlertMessage alertAndAutoDismissMessage:@"怎么也得写点东西再发啊～"];
        return;
    }
    
    int anonymous = 0;
    
    [BDWMPostWriter replyPosting:self.board WithTitle:title WithContent:content WithAnonymous:anonymous WithThreadid:self.threadid  WithPostid:self.postid  WithAuthor:self.author blockFunction:^(NSDictionary *responseDict, NSString *error) {
        [BDWMAlertMessage stopSpinner];
        if (error == nil) {
            NSLog(@"Reply pose success!");
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            NSLog(@"Reply failed!");
            [BDWMAlertMessage alertMessage:error];
        }
    }];
}

- (void)doCompose
{
    NSString *title = self.titleTextField.text;
    NSString *content = self.contentTextView.text;
    
    if (title.length == 0) {
        [BDWMAlertMessage alertAndAutoDismissMessage:@"亲，忘记写标题了。"];
        return;
    }
    if (content.length == 0) {
        [BDWMAlertMessage alertAndAutoDismissMessage:@"怎么也得写点东西再发啊～"];
        return;
    }
    
    int anonymous = 0;
    
    [BDWMPostWriter sendPosting:self.board WithTitle:title WithContent:content WithAnonymous:anonymous blockFunction:^(NSDictionary *responseDict, NSString *error) {
        [BDWMAlertMessage stopSpinner];
        if (error == nil) {
            NSLog(@"Compose pose success!");
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            NSLog(@"Compose failed!");
            [BDWMAlertMessage alertMessage:error];
        }
    }];
}

- (void) sendButtonPressed {
    [BDWMAlertMessage startSpinner:@"正在发送..."];
    if ([self.fromWhere isEqualToString:@"reply"]) {
        [self doReply];
    } else if( [self.fromWhere isEqualToString:@"compose"]) {
        [self doCompose];
    } else {
        [BDWMAlertMessage stopSpinner];
        [BDWMAlertMessage alertAndAutoDismissMessage:@"我去！从哪里点过来的！"];
    }
}

- (void) hideKeyboard {
    [self.contentTextView resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([self.fromWhere isEqualToString:@"reply"]) {
        self.title = @"回帖";
    }else if( [self.fromWhere isEqualToString:@"compose"]){
        self.title = @"发布新帖";
    }else{
        self.title = @"我去！从哪里点过来的！";
    }
    
    if (self.board == nil || self.board.length == 0) {
        [BDWMAlertMessage alertMessage:@"从未知版面进入"];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    int screenWidth = [[UIScreen mainScreen] bounds].size.width;
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 36)];
    [topView setBarStyle:UIBarStyleDefault];
    
    // Used as place holder
    UIBarButtonItem * button1 =[[UIBarButtonItem  alloc] initWithBarButtonSystemItem:                                        UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone  target:self action:@selector(hideKeyboard)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:button1, button1, button1, doneButton,nil];
    [topView setItems:buttonsArray];
    
    [self.contentTextView setInputAccessoryView:topView];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendButtonPressed)];
    self.navigationItem.rightBarButtonItem = button;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [BDWMAlertMessage alertAndAutoDismissMessage:@"哈哈破手机！居然会内存不足！"];
}

@end
