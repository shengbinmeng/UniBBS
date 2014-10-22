//
//  BDWMAlertMessage.m
//  BDWM
//
//  Created by fanyingming on 10/6/14.
//  Copyright (c) 2014 cn.pku.fanyingming. All rights reserved.
//

#import "BDWMAlertMessage.h"

@implementation BDWMAlertMessage

+ (void)alertAndAutoDismissMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
    [alert show];
    
    [self performSelector:@selector(dimissAlert:) withObject:alert afterDelay:0.8];
}

+ (void) dimissAlert:(UIAlertView *)alert
{
    if(alert)
    {
        [alert dismissWithClickedButtonIndex:[alert cancelButtonIndex] animated:YES];
        [alert release];
    }
}

+ (void)alertMessage:(NSString *)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
    [alert show];
}
@end
