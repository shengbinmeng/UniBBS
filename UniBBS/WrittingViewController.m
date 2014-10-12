//
//  WrittingViewController.m
//  UniBBS
//
//  Created by fanyingming on 10/12/14.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import "WrittingViewController.h"
#import "BDWMTopicModel.h"
#import "AFAppDotNetAPIClient.h"
#import "BDWMAlertMessage.h"
@interface WrittingViewController ()
@property (retain, nonatomic) IBOutlet UITextField *titleTextField;
@property (retain, nonatomic) IBOutlet UITextView *contentTextView;
@property (strong, nonatomic) NSDictionary *replyDict;
@end

@implementation WrittingViewController

- (IBAction)clickReplyButton:(id)sender {
    NSDictionary *dic_needed_data = self.replyDict;
    
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
    [dic setObject:self.contentTextView.text forKey:@"text"];
    [dic setObject:quser forKey:@"quser"];
    [dic setObject:@"on" forKey:@"unfoldpic"];
    
    
    [[AFAppDotNetAPIClient sharedClient] POST:@"http://www.bdwm.net/bbs/bbssnd.php" parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Reply success!");
        [self.navigationController popToRootViewControllerAnimated:YES];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Reply failed!");
        [BDWMAlertMessage alertMessage:@"发布失败"];
    }];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ( [self.fromWhere isEqualToString:@"reply"] ) {
        self.replyDict = [BDWMTopicModel getNeededReplyData:[self href]];
        self.titleTextField.text = [self.replyDict objectForKey:@"title_exp"];
        self.contentTextView.text = [self.replyDict objectForKey:@"quote"];
    }else if( [self.fromWhere isEqualToString:@"compose"] ){
        
    }else{
        [BDWMAlertMessage alertMessage:@"我去！从哪里点过来的！"];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_titleTextField release];
    [_contentTextView release];
    [super dealloc];
}
@end
