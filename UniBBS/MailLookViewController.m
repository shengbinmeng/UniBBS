//
//  MailLookViewController.m
//  UniBBS
//
//  Created by fanyingming on 10/12/14.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import "MailLookViewController.h"
#import "MailModel.h"
@interface MailLookViewController ()
@property (retain, nonatomic) IBOutlet UITextView *MailContentTextView;
@property (retain, nonatomic) NSDictionary *mail;
@end

@implementation MailLookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.mail = [MailModel loadMailByhref:self.href];
    self.MailContentTextView.text = [self.mail objectForKey:@"content"];
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
    [_MailContentTextView release];
    [super dealloc];
}
@end
