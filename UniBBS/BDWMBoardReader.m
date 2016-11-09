//
//  BDWMBoardReader.m
//  UniBBS
//
//  Created by Shengbin Meng on 06/11/2016.
//  Copyright © 2016 Peking University. All rights reserved.
//

#import "BDWMBoardReader.h"
#import "BDWMNetwork.h"

@implementation BDWMBoardReader {
    NSString *_board;
    int _page;
}

- (id)initWithURI:(NSString *)uri
{
    self = [super init];
    if (self) {
        _board = uri;
        _page = 1;
    }
    return self;
}

- (NSURLSessionDataTask *)getBoardTopicsWithBlock:(void (^)(NSMutableArray *topics, NSError *error))block
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"getthreads", @"type", _board, @"board", [NSString stringWithFormat:@"%d", _page], @"page", nil];
    
    [[BDWMNetwork sharedManager] requestWithMethod:GET WithParams:params WithSuccessBlock:^(NSDictionary *dic) {
        int code = [[dic objectForKey:@"code"] intValue];
        if (code == 0) {
            NSMutableArray *topics = [NSMutableArray arrayWithArray:[dic objectForKey:@"datas"]];
            block(topics, nil);
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

- (NSURLSessionDataTask *)getBoardPostsWithBlock:(void (^)(NSMutableArray *posts, NSError *error))block
{
    // TODO: Override to implement with new API.
    return [super getBoardPostsWithBlock:block];
}

- (NSURLSessionDataTask *)getBoardNextTopicsWithBlock:(void (^)(NSMutableArray *topics, NSError *error))block
{
    _page++;
    return [self getBoardTopicsWithBlock:block];
}

- (NSURLSessionDataTask *)getBoardNextPostsWithBlock:(void (^)(NSMutableArray *posts, NSError *error))block
{
    // TODO: Override to implement with new API.
    return [super getBoardNextPostsWithBlock:block];
}

@end
