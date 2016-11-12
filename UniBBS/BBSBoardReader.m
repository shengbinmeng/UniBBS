//
//  BBSBoardReader.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/11/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "BBSBoardReader.h"

@implementation BBSBoardReader

- (id)initWithURI:(NSString *)uri
{
    NSLog(@"Init with RUI");
    return [super init];
}

- (NSURLSessionDataTask *)getBoardTopicsWithBlock:(void (^)(NSMutableArray *topics, NSError *error))block
{
    NSLog(@"Get board topics");
    return nil;
}

- (NSURLSessionDataTask *)getBoardPostsWithBlock:(void (^)(NSMutableArray *posts, NSError *error))block
{
    NSLog(@"Get board posts");
    return nil;
}

- (NSURLSessionDataTask *)getBoardNextTopicsWithBlock:(void (^)(NSMutableArray *topics, NSError *error))block
{
    NSLog(@"Get board next topics");
    return nil;
}

- (NSURLSessionDataTask *)getBoardNextPostsWithBlock:(void (^)(NSMutableArray *posts, NSError *error))block
{
    NSLog(@"Get board next posts");
    return nil;
}

@end
