//
//  BDWMNetwork.h
//  UniBBS
//
//  Created by fanyingming on 2016/11/6.
//  Copyright © 2016年 Peking University. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

typedef void (^requestSuccessBlock)(id dic);

typedef void (^requestFailureBlock)(NSError *error);

typedef enum {
    GET,
    POST,
    PUT,
    DELETE,
    HEAD
} HTTPMethod;

@interface BDWMNetwork : AFHTTPSessionManager

+ (instancetype)sharedManager;

- (void)requestWithMethod:(HTTPMethod)method
                 WithPath:(NSString *)path
               WithParams:(NSDictionary*)params
         WithSuccessBlock:(requestSuccessBlock)success
          WithFailurBlock:(requestFailureBlock)failure;

- (void)requestWithMethod:(HTTPMethod)method
               WithParams:(NSDictionary*)params
         WithSuccessBlock:(requestSuccessBlock)success
          WithFailurBlock:(requestFailureBlock)failure;

@end
