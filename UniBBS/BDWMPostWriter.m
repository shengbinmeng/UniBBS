//
//  BDWMPostWriter.m
//  UniBBS
//
//  Created by fanyingming on 10/6/14.
//  Copyright (c) 2014 cn.pku.fanyingming. All rights reserved.
//

#import "BDWMPostWriter.h"
#import "BDWMNetwork.h"
#import "BDWMGlobalData.h"
#import "BDWMSettings.h"

@implementation BDWMPostWriter

+ (void) sendPosting:(NSString *)board WithTitle:(NSString *)title WithContent:(NSString *)content  WithAnonymous:(int)anonymous blockFunction:(void (^)(NSDictionary *responseDict, NSString *error))block {
    if ([BDWMSettings boolUsePostSuffixString]) {
        content = [content stringByAppendingString:POST_SUFFIX_STRING];
    }
    
    NSDictionary *param = @{
                            @"type" : @"post",
                            @"board" : board,
                            @"title" : title,
                            @"text" : content,
                            @"anonymous": [NSNumber numberWithInt: anonymous]
                            };
    
    [[BDWMNetwork sharedManager] requestWithMethod:POST WithParams:param WithSuccessBlock:^(NSDictionary *dic) {
        int code = [[dic objectForKey:@"code"] intValue];
        if (code == 0) {
            block(dic, nil);
        } else {
            block(dic, (NSString *)[dic objectForKey:@"msg"]);
        }
    } WithFailurBlock:^(NSError *error) {
        block(nil, error.localizedDescription);
    }];
}

+ (void) replyPosting:(NSString *)board WithTitle:(NSString *)title WithContent:(NSString *)content  WithAnonymous:(int)anonymous WithThreadid:(NSString *)threadid WithPostid:(NSString *)postid WithAuthor:(NSString *)author blockFunction:(void (^)(NSDictionary *responseDict, NSString *error))block {
    if ([BDWMSettings boolUsePostSuffixString]) {
        content = [content stringByAppendingString:POST_SUFFIX_STRING];
    }
    
    NSDictionary *param = @{
                            @"type" : @"post",
                            @"board" : board,
                            @"title" : title,
                            @"text" : content,
                            @"anonymous": [NSNumber numberWithInt: anonymous],
                            @"threadid" : threadid,
                            @"postid" : postid,
                            @"author" : author
                            };
    
    [[BDWMNetwork sharedManager] requestWithMethod:POST WithParams:param WithSuccessBlock:^(NSDictionary *dic) {
        int code = [[dic objectForKey:@"code"] intValue];
        if (code == 0) {
            block(dic, nil);
        } else {
            block(dic, (NSString *)[dic objectForKey:@"msg"]);
        }
    } WithFailurBlock:^(NSError *error) {
        block(nil, error.localizedDescription);
    }];
}

+ (void) getReplyQuote:(NSString *)board WithNumber:(NSString *)number WithTimestamp:(NSString *)timestamp blockFunction:(void (^)(NSDictionary *responseDict, NSString *error))block {
    NSDictionary *param = @{
                            @"type" : @"quote",
                            @"board" : board,
                            @"number" : number,
                            @"timestamp" : timestamp
                            };
    
    [[BDWMNetwork sharedManager] requestWithMethod:POST WithParams:param WithSuccessBlock:^(NSDictionary *dic) {
        int code = [[dic objectForKey:@"code"] intValue];
        if (code == 0) {
            block(dic, nil);
        } else {
            block(dic, (NSString *)[dic objectForKey:@"msg"]);
        }
    } WithFailurBlock:^(NSError *error) {
        block(nil, error.localizedDescription);
    }];
}

+ (void) getThreadsWithFirstPage:(NSString *)board blockFunction:(void (^)(NSDictionary *responseDict, NSString *error))block {
    NSDictionary *param = @{
                            @"type" : @"getthreads",
                            @"board" : board,
                            @"page" : @"1"
                            };
    
    [[BDWMNetwork sharedManager] requestWithMethod:POST WithParams:param WithSuccessBlock:^(NSDictionary *dic) {
        int code = [[dic objectForKey:@"code"] intValue];
        if (code == 0) {
            block(dic, nil);
        } else {
            block(dic, (NSString *)[dic objectForKey:@"msg"]);
        }
    } WithFailurBlock:^(NSError *error) {
        block(nil, error.localizedDescription);
    }];
}

@end
