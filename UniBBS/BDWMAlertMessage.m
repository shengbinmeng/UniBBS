//
//  BDWMAlertMessage.m
//  BDWM
//
//  Created by fanyingming on 10/6/14.
//  Copyright (c) 2014 cn.pku.fanyingming. All rights reserved.
//

#import "BDWMAlertMessage.h"

@implementation BDWMAlertMessage

+(void)alertMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
    [alert show];
}

@end
