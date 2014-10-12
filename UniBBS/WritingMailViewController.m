//
//  WritingMailViewController.m
//  UniBBS
//
//  Created by fanyingming on 10/12/14.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import "WritingMailViewController.h"

@interface WritingMailViewController ()

@end

@implementation WritingMailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    int index = buttonIndex - actionSheet.firstOtherButtonIndex;
    if (actionSheet.tag == ACTION_FROM_BAR_BUTTON) {
        // action sheet form bar buttom
        switch (index) {
            case 0:{//reply
                MailViewController *reply = [[[MailViewController alloc] initWithNibName:@"MailViewController" bundle:nil] autorelease];
                reply.href = [self.mail objectForKey:@"href"];
                [self.navigationController pushViewController:reply animated:YES];
                break;
            }
            case 1:{//delete
                
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

@end
