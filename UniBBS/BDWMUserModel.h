//
//  BDWMUserModel.h
//  BDWM
//
//  Created by fanyingming on 10/6/14.
//  Copyright (c) 2014 cn.pku.fanyingming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFHpple.h"
@interface BDWMUserModel : NSObject

+ (void)logout;
+ (void)deleteUsernameAndPassword;
+ (void)saveUsernameAndPassword:(NSString *)userName userPassword:(NSString *)userPassword;
+ (BOOL)checkUserName:(TFHpple *)doc UserName:(NSString *)user_name;
+ (NSURLSessionDataTask *) checkLogin:(NSString *)UserName userPass:(NSString *)UserPass blockFunction:(void (^)(NSString *name, NSError *error))block;
+ (NSMutableDictionary *)LoadUserInfo:(NSString *)userName;

+ (BOOL) isLogined;
+ (NSString*) getLoginUser;
+(BOOL) getBoolShouldRelogin;
@end
