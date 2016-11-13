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
    int _page, _postCount, _postTotalNumber;
    BOOL _gettingNext;
}

- (id)initWithURI:(NSString *)uri
{
    self = [super init];
    if (self) {
        NSInteger index = [uri rangeOfString:@"/"].location;
        _board = [uri substringToIndex:index];
        _threadid = [uri substringFromIndex:index+1];
        _page = 1;
        _postCount = 0;
        _postTotalNumber = 0;
        _gettingNext = FALSE;
    }
    return self;
}

- (NSURLSessionDataTask *)getTopicPostsWithBlock:(void (^)(NSMutableArray *topicPosts, NSError *error))block
{
    // Store the value for using in block.
    BOOL gettingNext = _gettingNext;
    if (!gettingNext) {
        _page = 1;
    }
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"getposts", @"type", _board, @"board", _threadid, @"threadid", [NSString stringWithFormat:@"%d", _page], @"page", @"20", @"pagesize", nil];
    [[BDWMNetwork sharedManager] requestWithMethod:GET WithParams:params WithSuccessBlock:^(NSDictionary *dic) {
        int code = [[dic objectForKey:@"code"] intValue];
        if (code == 0) {
            NSMutableArray *posts = [NSMutableArray arrayWithArray:[dic objectForKey:@"datas"]];
            if (gettingNext) {
                _postCount += (int)posts.count;
            } else {
                // First time or refresh.
                _postCount = (int)posts.count;
                _postTotalNumber = [[dic objectForKey:@"totalnum"] intValue];
            }
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
    if (_postCount < _postTotalNumber) {
        _page++;
        _gettingNext = TRUE;
        NSURLSessionDataTask *task = [self getTopicPostsWithBlock:block];
        _gettingNext = FALSE;
        return task;
    } else {
        NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : @"已经读完所有帖子"};
        NSError *error = [NSError errorWithDomain:@"BDWM Reader Error" code:-1 userInfo:errorDictionary];
        block(nil, error);
        return nil;
    }
}

@end
