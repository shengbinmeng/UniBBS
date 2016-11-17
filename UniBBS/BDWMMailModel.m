//
//  BDWMMailModel.m
//  UniBBS
//
//  Created by fanyingming on 10/12/14.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import "BDWMMailModel.h"
#import "AFAppDotNetAPIClient.h"
#import "BDWMNetwork.h"
#import "BDWMGlobalData.h"

@implementation BDWMMailModel

+ (NSMutableDictionary *)loadComposeMailNeededData
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    return dict;
}

+ (NSMutableDictionary *)loadReplyMailNeededData:(NSString *)href{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    return dict;
}

//Press view button when view mail list.
+ (NSDictionary *)loadMailByhref:(NSString *)href{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    return dict;
}

+ (void)getAllMailWithBlock:(NSString *)userName blockFunction:(void (^)(NSArray *mails, NSString *error))block {
    [[BDWMNetwork sharedManager] requestWithMethod:POST WithParams:[NSDictionary dictionaryWithObjectsAndKeys:@"getmaillist", @"type",nil] WithSuccessBlock:^(NSDictionary *dic) {
        NSMutableArray *results = [[NSMutableArray alloc]init];
        int code = [[dic objectForKey:@"code"] intValue];
        if (code == 0) {
            block(results, nil);
        } else {
            block(results, (NSString *)[dic objectForKey:@"msg"]);
        }
        
    } WithFailurBlock:^(NSError *error) {
        block(nil, error.localizedDescription);
    }];
}

+ (NSMutableArray *)loadMails:(NSData *)htmlData{
    
    NSMutableArray *results = [[NSMutableArray alloc]init];
    
    return results;
}

+ (NSURLSessionDataTask *)deleteMailByHref:(NSString *)href{
    NSString *url = [BDWM_PREFIX stringByAppendingString:href];
    
    return [[AFAppDotNetAPIClient sharedClient] GET:url parameters:nil success:nil failure:nil];
}

@end
