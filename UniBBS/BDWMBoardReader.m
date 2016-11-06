//
//  BDWMBoardReader.m
//  UniBBS
//
//  Created by Shengbin Meng on 06/11/2016.
//  Copyright © 2016 Peking University. All rights reserved.
//

#import "BDWMBoardReader.h"

@implementation BDWMBoardReader

- (id)initWithURI:(NSString *)uri
{
    // TODO: Override to implement with new API.
    return [super initWithURI:uri];
}

- (NSURLSessionDataTask *)getBoardTopicsWithBlock:(void (^)(NSMutableArray *topics, NSError *error))block
{
    // TODO: Override to implement with new API.
    return [super getBoardTopicsWithBlock:block];
}

- (NSURLSessionDataTask *)getBoardPostsWithBlock:(void (^)(NSMutableArray *posts, NSError *error))block
{
    // TODO: Override to implement with new API.
    return [super getBoardPostsWithBlock:block];
}

- (NSURLSessionDataTask *)getBoardNextTopicsWithBlock:(void (^)(NSMutableArray *topics, NSError *error))block
{
    // TODO: Override to implement with new API.
    return [super getBoardNextTopicsWithBlock:block];
}

- (NSURLSessionDataTask *)getBoardNextPostsWithBlock:(void (^)(NSMutableArray *posts, NSError *error))block
{
    // TODO: Override to implement with new API.
    return [super getBoardNextPostsWithBlock:block];
}

@end
