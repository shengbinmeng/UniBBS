//
//  BDWMTopicReader.m
//  UniBBS
//
//  Created by Shengbin Meng on 06/11/2016.
//  Copyright © 2016 Peking University. All rights reserved.
//

#import "BDWMTopicReader.h"

@implementation BDWMTopicReader

- (id)initWithURI:(NSString *)uri
{
    // TODO: Replace the following code to implement new reader using the API.
    return [super initWithURI:uri];
}

- (NSURLSessionDataTask *)getTopicPostsWithBlock:(void (^)(NSMutableArray *topicPosts, NSError *error))block
{
    // TODO: Replace the following code to implement new reader using the API.
    return [super getTopicPostsWithBlock:block];
}

- (NSURLSessionDataTask *)getNextPostsWithBlock:(void (^)(NSMutableArray *topicPosts, NSError *error))block
{
    // TODO: Replace the following code to implement new reader using the API. 
    return [super getNextPostsWithBlock:block];
}

@end
