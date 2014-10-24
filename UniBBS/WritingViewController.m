//
//  WritingViewController.m
//  UniBBS
//
//  Created by fanyingming on 10/12/14.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import "WritingViewController.h"
#import "BDWMTopicModel.h"
#import "AFAppDotNetAPIClient.h"
#import "BDWMAlertMessage.h"
#import "BDWMString.h"
#import "SettingModel.h"

@interface WritingViewController ()
@property (retain, nonatomic) IBOutlet UITextField *titleTextField;
@property (retain, nonatomic) IBOutlet UITextView *contentTextView;
@property (strong, nonatomic) NSDictionary *postDict;
@end

@implementation WritingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nil bundle:nil];
    
    if(self != nil)
    {
        
        
    }
    return self;
}

- (void)doReply
{
    NSDictionary *dic_needed_data = self.postDict;
    
    NSString *board         = [dic_needed_data objectForKey:@"board"];
    NSString *threadid      = [dic_needed_data objectForKey:@"threadid"];
    NSString *postid        = [dic_needed_data objectForKey:@"postid"];
    NSString *user_id       = [dic_needed_data objectForKey:@"user_id"];
    NSString *code          = [dic_needed_data objectForKey:@"code"];
    NSString *reply_title   = [dic_needed_data objectForKey:@"title_exp"];
    NSString *notice_author = [dic_needed_data objectForKey:@"notice_author"];
    NSString *quser         = [dic_needed_data objectForKey:@"quser"];
    
    NSLog(@"Reply_title:%@",reply_title);
    //This dictionary's data was actually needed for reply post.
    //Which data was need? We find needed data through poat data analyse by network of chrome developer tool.
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:board    forKey:@"board"];
    [dic setObject:threadid forKey:@"threadid"];
    [dic setObject:postid   forKey:@"postid"];
    [dic setObject:user_id  forKey:@"id"];
    
    [dic setObject:code             forKey:@"code"];
    [dic setObject:reply_title      forKey:@"title_exp"];
    [dic setObject:notice_author    forKey:@"notice_author"];
    [dic setObject:self.titleTextField.text     forKey:@"title"];
    
    //SecretGarden plate need weather anonymous flag.
    if ( [board  isEqual: @"SecretGarden"]) {
        [dic setObject:@"Y" forKey:@"anonymous"];
    }
    
    //some data below may be changeable for user in later version.
    [dic setObject:@"N" forKey:@"noreply"];
    [dic setObject:@"0" forKey:@"signature"];
    NSMutableString *content = [[NSMutableString alloc] init];
    if( [SettingModel boolUsePostSuffixString] ){
        content = [BDWMString linkString:self.contentTextView.text string:POST_SUFFIX_STRING];
    }else{
        content = [self.contentTextView.text mutableCopy];
    }
    
    [dic setObject:content forKey:@"text"];
    [dic setObject:quser forKey:@"quser"];
    [dic setObject:@"on" forKey:@"unfoldpic"];
    
    NSString *url = [BDWMString linkString:BDWM_PREFIX string:BDWM_COMPOSE_SUFFIX];
    [[AFAppDotNetAPIClient sharedClient] POST:url parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Reply success!");
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Reply failed!");
        [BDWMAlertMessage alertAndAutoDismissMessage:@"发布失败"];
    }];
}

- (void)doCompose
{
    NSString *title = self.titleTextField.text;
    NSString *content = self.contentTextView.text;
    
    if (title.length==0) {
        [BDWMAlertMessage alertAndAutoDismissMessage:@"亲，忘记写标题了。"];
    }
    if(content.length==0){
        [BDWMAlertMessage alertAndAutoDismissMessage:@"怎么也得写点东西再发啊～"];
    }
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:[self.postDict objectForKey:@"board"]    forKey:@"board"];
    [dic setObject:[self.postDict objectForKey:@"threadid"] forKey:@"threadid"];
    [dic setObject:[self.postDict objectForKey:@"postid"]   forKey:@"postid"];
    [dic setObject:[self.postDict objectForKey:@"id"]  forKey:@"id"];
    
    [dic setObject:[self.postDict objectForKey:@"code"]             forKey:@"code"];
    [dic setObject:[self.postDict objectForKey:@"title_exp"]      forKey:@"title_exp"];
    [dic setObject:[self.postDict objectForKey:@"notice_author"]    forKey:@"notice_author"];
    [dic setObject:self.titleTextField.text     forKey:@"title"];
    
    //SecretGarden plate need weather anonymous flag.
    if ( [[self.postDict objectForKey:@"board"]  isEqual: @"SecretGarden"]) {
        [dic setObject:@"Y" forKey:@"anonymous"];
    }
    
    //some data below may be changeable for user in later version.
    [dic setObject:@"N" forKey:@"noreply"];
    [dic setObject:@"0" forKey:@"signature"];
    NSMutableString *content_t = [[NSMutableString alloc] init];
    
    if( [SettingModel boolUsePostSuffixString] ){
        content_t = [BDWMString linkString:content string:POST_SUFFIX_STRING];
    }else{
        content_t = [content mutableCopy];
    }
    
    [dic setObject:content_t forKey:@"text"];
    [dic setObject:@"on" forKey:@"unfoldpic"];
    
    NSString *url = [BDWMString linkString:BDWM_PREFIX string:BDWM_COMPOSE_SUFFIX];
    [[AFAppDotNetAPIClient sharedClient] POST:url parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Compose pose success!");
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Reply failed!");
        [BDWMAlertMessage alertAndAutoDismissMessage:@"发布失败"];
    }];

}

- (void) sendButtonPressed {
    if ([self.fromWhere isEqualToString:@"reply"]) {
        [self doReply];
    }else if( [self.fromWhere isEqualToString:@"compose"]){
        [self doCompose];
    }else{
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
    
    int screenWidth = [[UIScreen mainScreen] bounds].size.width;
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 36)];
    [topView setBarStyle:UIBarStyleDefault];
    
    // Used as place holder
    UIBarButtonItem * button1 =[[UIBarButtonItem  alloc] initWithBarButtonSystemItem:                                        UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone  target:self action:@selector(hideKeyboard)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:button1, button1, button1, doneButton,nil];
    [topView setItems:buttonsArray];
    
    [self.contentTextView setInputAccessoryView:topView];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleBordered target:self action:@selector(sendButtonPressed)];
    self.navigationItem.rightBarButtonItem = button;
    [button release];
    
}

- (void)viewDidAppear:(BOOL)animated{
    if ( [self.fromWhere isEqualToString:@"reply"] ) {
        self.postDict = [BDWMTopicModel getNeededReplyData:[self href]];
        if (self.postDict==nil) {
            [BDWMAlertMessage alertMessage:@"哎呦！不能回复！是登录过期了吗？"];
            [self.navigationController popViewControllerAnimated:NO];
        }
        self.titleTextField.text = [self.postDict objectForKey:@"title_exp"];
        self.contentTextView.text = [self.postDict objectForKey:@"quote"];
        
        if (self.href != nil) {
            //TODO: 1. what if href is nil? 2. getNeededReplayData has bugs, needs more error handling
            self.postDict = [BDWMTopicModel getNeededReplyData:[self href]];
            self.titleTextField.text = [self.postDict objectForKey:@"title_exp"];
            self.contentTextView.text = [self.postDict objectForKey:@"quote"];
        }else{
            [BDWMAlertMessage alertMessage:@"哎呦！没有找到回复链接！"];
            [self.navigationController popViewControllerAnimated:NO];
        }
    }else if( [self.fromWhere isEqualToString:@"compose"] ){
        self.postDict = [BDWMTopicModel getNeededComposeData:self.href];
        if (self.postDict==nil) {
             [BDWMAlertMessage alertMessage:@"哎呦！是不是没有发帖权限！还是登录过期了呢？"];
            [self.navigationController popViewControllerAnimated:NO];
        }
    }else{
        [BDWMAlertMessage alertAndAutoDismissMessage:@"我去！从哪里点过来的！"];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_titleTextField release];
    [_contentTextView release];
    [super dealloc];
}
@end
