//
//  AboutViewController.m
//  UniBBS
//
//  Created by fanyingming on 10/19/14.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()
@property (retain, nonatomic) IBOutlet UITextView *aboutTextView;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"关于";
    self.aboutTextView.text = @"北大未名iOS客户端是Ying和noname在业余时间做的一个App。\n\n我们希望她是不断迭代更新的，她会有很多bug，我们会尽快修复并更新。\n\n如果有任何问题和建议，可以发信至2位开发者:\nhello@shengbin.me\nyingmingfan@gmail.com\n";
    self.aboutTextView.font = [UIFont boldSystemFontOfSize:17];
    self.aboutTextView.textAlignment = NSTextAlignmentJustified;
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
    [_aboutTextView release];
    [super dealloc];
}
@end
