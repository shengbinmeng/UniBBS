//
//  BDWMPosting.m
//  BDWM
//
//  Created by fanyingming on 10/6/14.
//  Copyright (c) 2014 cn.pku.fanyingming. All rights reserved.
//

#import "BDWMPosting.h"
#import "BDWMNetwork.h"
#import "BDWMGlobalData.h"
#import "SettingModel.h"

@implementation BDWMPosting

+ (void) sendPosting:(NSString *)board WithTitle:(NSString *)title WithContent:(NSString *)content  WithAnonymous:(int)anonymous blockFunction:(void (^)(NSDictionary *responseDict, NSString *error))block {
    if ([SettingModel boolUsePostSuffixString]) {
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
    if ([SettingModel boolUsePostSuffixString]) {
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

@end
