//
//  BDWMUserModel.m
//  UniBBS
//
//  Created by fanyingming on 10/6/14.
//  Copyright (c) 2014 cn.pku.fanyingming. All rights reserved.
//

#import "BDWMUserModel.h"
#import "AFAppDotNetAPIClient.h"
#import "BDWMNetwork.h"
#import "BDWMAlertMessage.h"

@implementation BDWMUserModel


static BOOL logined = NO;
static NSString *loginUser = nil;
static NSString *_token = nil;
static BOOL enterAppAndAutoLogin = NO;

+ (BOOL)getEnterAppAndAutoLogin{
    return enterAppAndAutoLogin;
}

+ (void)setEnterAppAndAutoLogin:(BOOL)status{
    enterAppAndAutoLogin = status;
}

+ (BOOL)isLogined {
    return logined;
}

+ (NSString*)getLoginUser {
    return loginUser;
}

+ (NSString*)getToken {
    return _token;
}

/**
 *  Logout - Just clean the cookies
 */
+ (void)logout {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [self deleteUsernameAndPassword];
    
}

+ (void)deleteUsernameAndPassword {
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    [userDefaultes removeObjectForKey:@"userInfo"];
    [userDefaultes synchronize];
    
    logined = NO;
    loginUser = nil;
    _token = nil;
}

+ (void)saveUserInformation:(NSDictionary *)userInfo {
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    [userDefaultes setObject:userInfo forKey:@"userInfo"];
    [userDefaultes synchronize];
    
    logined = YES;
    if (loginUser == nil) {
        loginUser = [[NSString alloc] init];
    }
    if (_token == nil) {
        _token = [[NSString alloc] init];
    }
    loginUser = [(NSString *)[userInfo objectForKey:@"username"] copy];
    _token = [(NSString *)[userInfo objectForKey:@"token"] copy];
}

+ (void)checkLogin:(NSString *)UserName userPass:(NSString *)UserPass blockFunction:(void (^)(NSDictionary *responseDict, NSString *error))block
{
    [[BDWMNetwork sharedManager] requestWithMethod:POST WithParams:[NSDictionary dictionaryWithObjectsAndKeys:@"login", @"type", UserName, @"username", UserPass, @"password",nil] WithSuccessBlock:^(NSDictionary *dic) {
        int code = [[dic objectForKey:@"code"] intValue];
        if (code == 0) {
            NSMutableDictionary * mutableDict = [NSMutableDictionary dictionary];
            [mutableDict addEntriesFromDictionary:dic];
            [mutableDict setObject:UserName forKey:@"username"];
            [mutableDict setObject:UserPass forKey:@"password"];
            [BDWMUserModel saveUserInformation:mutableDict];
            block(dic, nil);
        } else {
            block(dic, (NSString *)[dic objectForKey:@"msg"]);
        }
    } WithFailurBlock:^(NSError *error) {
        block(nil, error.localizedDescription);
    }];
}

+ (void)autoLogin:(void (^)())success WithFailurBlock:(void (^)())failure {
    NSDictionary * userInfo = [self getStoredUserInfo];
    if (userInfo != nil) {
        [BDWMAlertMessage startSpinner:@"正在自动登录"];
        [self checkLogin:(NSString *)[userInfo objectForKey:@"username"] userPass:(NSString *)[userInfo objectForKey:@"password"] blockFunction:^(NSDictionary *responseDict, NSString *error){
            [BDWMAlertMessage stopSpinner];
            if (error == nil) {
                NSLog(@"auto login success");
                success();
            } else {
                NSLog(@"auto login failed: %@", error);
                failure();
            }
        }];
    } else {
        NSLog(@"saved user info not found");
        failure();
    }
}

+ (NSDictionary *)getStoredUserInfo {
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSDictionary * userInfo = [userDefaultes dictionaryForKey:@"userInfo"];
    
    return userInfo;
}

@end
