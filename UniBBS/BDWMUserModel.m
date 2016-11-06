//
//  BDWMUserModel.m
//  BDWM
//
//  Created by fanyingming on 10/6/14.
//  Copyright (c) 2014 cn.pku.fanyingming. All rights reserved.
//

#import "BDWMUserModel.h"
#import "AFAppDotNetAPIClient.h"
#import "BDWMNetwork.h"
#import "BDWMString.h"

@implementation BDWMUserModel


static BOOL logined = NO;
static NSString *loginUser = nil;
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
    [userDefaultes removeObjectForKey:@"saved_username"];
    [userDefaultes removeObjectForKey:@"saved_password"];
    [userDefaultes synchronize];
    
    logined = NO;
    loginUser = nil;
}

+ (void)saveUsernameAndPassword:(NSString *)userName userPassword:(NSString *)userPassword {
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    [userDefaultes setObject:userName forKey:@"saved_username"];
    [userDefaultes setObject:userPassword forKey:@"saved_password"];
    [userDefaultes synchronize];
    
    logined = YES;
    if (loginUser == nil) {
        loginUser = [[NSString alloc]init];
    }
    loginUser = [userName copy];
    
}

+ (void)checkLogin:(NSString *)UserName userPass:(NSString *)UserPass blockFunction:(void (^)(NSDictionary *responseDict, NSError *error))block
{
    [[BDWMNetwork sharedManager] requestWithMethod:POST WithParams:[NSDictionary dictionaryWithObjectsAndKeys:@"login", @"type", UserName, @"username", UserPass, @"password",nil] WithSuccessBlock:^(NSDictionary *dic) {
        block(dic, nil);
    } WithFailurBlock:^(NSError *error) {
        block(nil, error);
    }];
    
}

+ (BOOL)checkUserName:(TFHpple *)doc UserName:(NSString *)user_name{
    NSArray *usernameArray = [doc searchWithXPathQuery:@"//table[@class='loginbox']/tr[2]/td/a"];
    NSLog(@"doc size %lu",(unsigned long)doc.data.length);
    if ([usernameArray count] > 0) {
        NSString *username = [[[usernameArray objectAtIndex:0] objectForKey:@"href"] stringByReplacingOccurrencesOfString:@"bbsqry.php?name=" withString:@""];
        
        if ([[username lowercaseString] isEqualToString:[user_name lowercaseString]]) return YES;
    }
    return NO;
}

+ (NSMutableDictionary *)LoadUserInfo:(NSString *)userName
{
    TFHpple * doc;
    NSString *string = [NSString stringWithFormat:@"http://www.bdwm.net/bbs/bbsqry.php?name=%@", userName];
    
    NSURL *baseURL = [NSURL URLWithString:string];
    NSData * data = [NSData dataWithContentsOfURL:baseURL];
    data = [BDWMString DataConverse_GB2312_to_UTF8:data];
    
    doc = [[TFHpple alloc] initWithHTMLData:data];
    NSLog(@"url=%@",string);
    NSArray *arr = [doc searchWithXPathQuery:@"//table[@class='doc']//td[@class='doc']//span"];
    NSLog(@"arr size:%lu",(unsigned long)arr.count);
    TFHppleElement *e = [arr objectAtIndex:0];
    
    NSMutableDictionary *userInfoDict = [[NSMutableDictionary alloc] init];
    NSString *name = [e text];
    e = [arr objectAtIndex:1];
    NSString *byName = [e text];
    NSString *displayName = [NSString stringWithFormat:@"%@(%@)", name, byName ];
    [userInfoDict setObject:displayName forKey:@"userName"];
    
    e = [arr objectAtIndex:2];
    [userInfoDict setObject:[e text] forKey:@"loginTimes"];
    e = [arr objectAtIndex:3];
    [userInfoDict setObject:[e text] forKey:@"postingNum"];
    e = [arr objectAtIndex:4];
    [userInfoDict setObject:[e text] forKey:@"energyNum"];
    
    e = [arr objectAtIndex:6];
    NSString *totalScore = [e text];
    e = [arr objectAtIndex:7];
    NSString *rank = [e text];
    displayName = [NSString stringWithFormat:@"%@(%@)", totalScore, rank];
    
    [userInfoDict setObject:displayName forKey:@"totalScore"];
    e = [arr objectAtIndex:8];
    [userInfoDict setObject:[e text] forKey:@"originalScore"];
    
    e = [arr objectAtIndex:13];
    NSString *duties = [e text];
    if (duties == nil) duties = @"打酱油";
    [userInfoDict setObject:duties forKeyedSubscript:@"duties"];
    
    return userInfoDict;
}

@end
