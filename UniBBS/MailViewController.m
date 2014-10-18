//
//  MailViewController.m
//  UniBBS
//
//  Created by fanyingming on 10/12/14.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import "MailViewController.h"
#import "MailModel.h"
#import "WritingMailViewController.h"

@interface MailViewController ()
@property (retain, nonatomic) IBOutlet UITextView *mailContentTextView;
@property (retain, nonatomic) NSDictionary *mail;
@end

#define ACTION_FROM_BAR_BUTTON 8888
#define ACTION_FROM_VIEW_ATTACH 9999

@implementation MailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *barButton = [[[UIBarButtonItem alloc] initWithTitle:@"选项" style:UIBarButtonItemStyleBordered target:self action:@selector(barButtonPressed)] autorelease];
    self.navigationItem.rightBarButtonItem = barButton;
    
    self.mail = [MailModel loadMailByhref:self.href];
    if(self.mail==nil){
        NSLog(@"error: can't get mail.");
        [self.navigationController popViewControllerAnimated:YES];
    }
    self.mailContentTextView.text = [self.mail objectForKey:@"content"];
}

- (void) barButtonPressed
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选项" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"回信", @"删除", nil];
    [sheet setTag:ACTION_FROM_BAR_BUTTON];
    [sheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    [sheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    NSUInteger index = buttonIndex - actionSheet.firstOtherButtonIndex;
    if (actionSheet.tag == ACTION_FROM_BAR_BUTTON) {
        // action sheet form bar buttom
        switch (index) {
            case 0:{//reply
                WritingMailViewController *reply = [[[WritingMailViewController alloc] initWithNibName:@"WritingMailViewController" bundle:nil] autorelease];
                reply.href = [self.mail objectForKey:@"href"];
                [self.navigationController pushViewController:reply animated:YES];
                break;
            }
            case 1:{//delete
                NSString *delHref = [self.mail objectForKey:@"delete_href"];
                [MailModel deleteMailByHref:delHref];
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            default:
                break;
        }
    } else {
        
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
    [_mailContentTextView release];
    [super dealloc];
}
@end
