//
//  BBSTopicReader.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/10/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "BBSTopicReader.h"

@implementation BBSTopicReader

- (id)initWithURI:(NSString *)uri
{
    NSLog(@"Init with URI");
    return [super init];
}

- (NSURLSessionDataTask *)getTopicPostsWithBlock:(void (^)(NSMutableArray *topicPosts, NSError *error))block
{
    NSLog(@"Get topic posts");
    return nil;
}

- (NSURLSessionDataTask *)getNextPostsWithBlock:(void (^)(NSMutableArray *topicPosts, NSError *error))block
{
    NSLog(@"Get next topic posts");
    return nil;
}

@end
