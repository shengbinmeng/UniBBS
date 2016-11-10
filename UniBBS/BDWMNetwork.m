//
//  BDWMNetwork.m
//  UniBBS
//
//  Created by fanyingming on 2016/11/6.
//  Copyright © 2016年 Peking University. All rights reserved.
//

#import "BDWMNetwork.h"
#import "BDWMUserModel.h"
#import "BDWMGlobalData.h"

@implementation BDWMNetwork

+ (instancetype)sharedManager {
    static BDWMNetwork *manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        manager = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.bdwm.net/"]];
    });
    return manager;
}

-(instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        self.requestSerializer.timeoutInterval = DEFAULT_TIMEOUT_SECONDS;
        self.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [self.requestSerializer setValue:url.absoluteString forHTTPHeaderField:@"Referer"];
        
    //    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        
        self.securityPolicy.allowInvalidCertificates = YES;
        self.securityPolicy.validatesDomainName = NO;
        
        self.securityPolicy.allowInvalidCertificates = YES;
    }
    return self;
}

- (void)requestWithMethod:(HTTPMethod)method
                 WithPath:(NSString *)path
               WithParams:(NSDictionary*)params
         WithSuccessBlock:(requestSuccessBlock)success
          WithFailurBlock:(requestFailureBlock)failure
{
    switch (method) {
        case GET:{
            [self GET:path parameters:params progress:nil success:^(NSURLSessionTask *task, NSDictionary * responseObject) {
                NSLog(@"JSON: %@", responseObject);
                if ([responseObject isKindOfClass:[NSArray class]]) {
                    success(responseObject);
                } else {
                    int code = [[responseObject objectForKey:@"code"] intValue];
                    NSString * msg = (NSString *)[responseObject objectForKey:@"msg"];
                    
                    //token expire
                    if ([msg  isEqual: @"您所在的IP段被禁止访问该页面。"] && code == -1) {
                        [BDWMUserModel autoLogin:^() {
                            NSString *token = [BDWMUserModel getToken];
                            
                            NSMutableDictionary * mutableDict = [NSMutableDictionary dictionary];
                            [mutableDict addEntriesFromDictionary:params];
                            
                            if (token != nil) {
                                [mutableDict setObject:token forKey:@"token"];
                            }
                            [self GET:path parameters:mutableDict progress:nil  success:^(NSURLSessionTask *task, NSDictionary * responseObject1) {
                                success(responseObject1);
                            } failure:^(NSURLSessionTask *operation, NSError *error) {
                                success(responseObject);
                            }];
                        } WithFailurBlock:^(){
                            success(responseObject);
                        }];
                    } else {
                        success(responseObject);
                    }
                }
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                failure(error);
            }];
            break;
        }
        case POST:{
            [self POST:path parameters:params progress:nil success:^(NSURLSessionTask *task, NSDictionary * responseObject) {
                NSLog(@"JSON: %@", responseObject);
                int code = [[responseObject objectForKey:@"code"] intValue];
                NSString * msg = (NSString *)[responseObject objectForKey:@"msg"];
                
                //token expire
                if ([msg  isEqual: @"您所在的IP段被禁止访问该页面。"] && code == -1) {
                    [BDWMUserModel autoLogin:^() {
                        NSString *token = [BDWMUserModel getToken];
                        
                        NSMutableDictionary * mutableDict = [NSMutableDictionary dictionary];
                        [mutableDict addEntriesFromDictionary:params];
                        
                        if (token != nil) {
                            [mutableDict setObject:token forKey:@"token"];
                        }
                        [self POST:path parameters:mutableDict progress:nil  success:^(NSURLSessionTask *task, NSDictionary * responseObject1) {
                            success(responseObject1);
                        } failure:^(NSURLSessionTask *operation, NSError *error) {
                            success(responseObject);
                        }];
                    } WithFailurBlock:^(){
                        success(responseObject);
                    }];
                } else {
                    success(responseObject);
                }
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:error.localizedDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                failure(error);
            }];
            break;
        }
        default:
            break;
    }
}

- (void)requestWithMethod:(HTTPMethod)method
               WithParams:(NSDictionary*)params
         WithSuccessBlock:(requestSuccessBlock)success
          WithFailurBlock:(requestFailureBlock)failure
{
    NSString *token = [BDWMUserModel getToken];
    
    NSMutableDictionary * mutableDict = [NSMutableDictionary dictionary];
    [mutableDict addEntriesFromDictionary:params];
    
    if (token != nil) {
        [mutableDict setObject:token forKey:@"token"];
    }
    
    [self requestWithMethod:method WithPath:@"client/bbsclient.php" WithParams:mutableDict WithSuccessBlock:success WithFailurBlock:failure];
}
@end
