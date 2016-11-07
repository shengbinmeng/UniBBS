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
+ (void) checkLogin:(NSString *)UserName userPass:(NSString *)UserPass blockFunction:(void (^)(NSDictionary *name, NSString *error))block;
+ (NSMutableDictionary *)LoadUserInfo:(NSString *)userName;

+ (BOOL)isLogined;
+ (NSString*)getLoginUser;
+ (NSString*)getToken;
+ (BOOL)getEnterAppAndAutoLogin;
+ (void)setEnterAppAndAutoLogin:(BOOL)status;
@end
