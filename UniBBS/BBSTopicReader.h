//
//  BBSTopicReader.h
//  UniBBS
//
//  Created by Meng Shengbin on 3/10/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBSTopicReader : NSObject

- (id)initWithURI:(NSString *)uri;
- (NSURLSessionDataTask *)getTopicPostsWithBlock:(void (^)(NSMutableArray *topicPosts, NSError *error))block;
- (NSURLSessionDataTask *)getNextPostsWithBlock:(void (^)(NSMutableArray *topicPosts, NSError *error))block;

@end
