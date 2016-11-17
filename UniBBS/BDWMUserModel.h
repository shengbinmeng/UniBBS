//
//  BDWMUserModel.h
//  UniBBS
//
//  Created by fanyingming on 10/6/14.
//  Copyright (c) 2014 cn.pku.fanyingming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDWMUserModel : NSObject

+ (void)logout;
+ (void)deleteUsernameAndPassword;
+ (void)saveUserInformation:(NSDictionary *)userInfo;
+ (void) checkLogin:(NSString *)UserName userPass:(NSString *)UserPass blockFunction:(void (^)(NSDictionary *name, NSString *error))block;

+ (void)autoLogin:(void (^)())success WithFailurBlock:(void (^)())failure;

+ (NSDictionary *)getStoredUserInfo;

+ (BOOL)isLogined;
+ (NSString*)getLoginUser;
+ (NSString*)getToken;
+ (BOOL)getEnterAppAndAutoLogin;
+ (void)setEnterAppAndAutoLogin:(BOOL)status;
@end
