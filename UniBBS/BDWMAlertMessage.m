//
//  BDWMAlertMessage.m
//  BDWM
//
//  Created by fanyingming on 10/6/14.
//  Copyright (c) 2014 cn.pku.fanyingming. All rights reserved.
//

#import "BDWMAlertMessage.h"

@implementation BDWMAlertMessage

UIAlertView *connectingAlert;

//show loading activity.
+ (void)startSpinner:(NSString *)message {
    //  Purchasing Spinner.
    if (!connectingAlert) {
        connectingAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(message,@"")
                                                     message:nil
                                                    delegate:self
                                           cancelButtonTitle:nil
                                           otherButtonTitles:nil];
        connectingAlert.tag = (NSUInteger)300;
        [connectingAlert show];
        
        UIActivityIndicatorView *connectingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        connectingIndicator.frame = CGRectMake(139.0f-18.0f,50.0f,37.0f,37.0f);
        [connectingAlert addSubview:connectingIndicator];
        [connectingIndicator startAnimating];
        
    }
}

//hide loading activity.
+ (void)stopSpinner {
    if (connectingAlert) {
        [connectingAlert dismissWithClickedButtonIndex:0 animated:YES];
        connectingAlert = nil;
    }
    // [self performSelector:@selector(showBadNews:) withObject:error afterDelay:0.1];
}

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
