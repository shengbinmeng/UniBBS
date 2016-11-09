//
//  BDWMTopicReader.m
//  UniBBS
//
//  Created by Shengbin Meng on 06/11/2016.
//  Copyright © 2016 Peking University. All rights reserved.
//

#import "BDWMTopicReader.h"
#import "BDWMNetwork.h"

@implementation BDWMTopicReader {
    NSString *_board;
    NSString *_threadid;
    int _page;
}

- (id)initWithURI:(NSString *)uri
{
    self = [super init];
    if (self) {
        NSInteger index = [uri rangeOfString:@"/"].location;
        _board = [uri substringToIndex:index];
        _threadid = [uri substringFromIndex:index+1];
        _page = 1;
    }
    return self;
}

- (NSURLSessionDataTask *)getTopicPostsWithBlock:(void (^)(NSMutableArray *topicPosts, NSError *error))block
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"getposts", @"type", _board, @"board", _threadid, @"threadid", [NSString stringWithFormat:@"%d", _page], @"page", @"50", @"pagesize", nil];
    
    [[BDWMNetwork sharedManager] requestWithMethod:GET WithParams:params WithSuccessBlock:^(NSDictionary *dic) {
        int code = [[dic objectForKey:@"code"] intValue];
        if (code == 0) {
            NSMutableArray *posts = [NSMutableArray arrayWithArray:[dic objectForKey:@"datas"]];
            block(posts, nil);
        } else {
            NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : [dic objectForKey:@"msg"]};
            NSError *error = [NSError errorWithDomain:@"BDWM API Error" code:code userInfo:errorDictionary];
            block(nil, error);
        }
    } WithFailurBlock:^(NSError *error) {
        block(nil, error);
    }];
    return nil;
}

- (NSURLSessionDataTask *)getNextPostsWithBlock:(void (^)(NSMutableArray *topicPosts, NSError *error))block
{
    _page++;
    return [self getTopicPostsWithBlock:block];
}

@end
