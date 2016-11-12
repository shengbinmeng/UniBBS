//
//  BDWMSettings.m
//  UniBBS
//
//  Created by fanyingming on 10/19/14.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import "BDWMSettings.h"

@implementation BDWMSettings

+ (BOOL)boolUsePostSuffixString
{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString * ifUse = [userDefaultes stringForKey:@"bool_use_post_suffix_string"];
    if (ifUse == nil) {
        return YES;//default open.
    } else if ([ifUse isEqualToString:@"YES"]){
        return YES;
    } else {
        return NO;
    }
}

+ (void)setBoolUsePostSuffixString:(BOOL)value{
    NSString *saveString = [[NSString alloc] init];
    if (value) {
        saveString = @"YES";
    }else{
        saveString = @"NO";
    }
    
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    [userDefaultes setObject:saveString forKey:@"bool_use_post_suffix_string"];
    [userDefaultes synchronize];
}

+ (BOOL)boolAutoLogin
{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString * ifUse = [userDefaultes stringForKey:@"bool_auto_login"];
    if (ifUse == nil) {
        return YES;//default open.
    } else if ([ifUse isEqualToString:@"YES"]){
        return YES;
    } else {
        return NO;
    }
}

+ (void)setBoolAutoLogin:(BOOL)value{
    NSString *saveString = [[NSString alloc] init];
    if (value) {
        saveString = @"YES";
    }else{
        saveString = @"NO";
    }
    
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    [userDefaultes setObject:saveString forKey:@"bool_auto_login"];
    [userDefaultes synchronize];
}
@end
