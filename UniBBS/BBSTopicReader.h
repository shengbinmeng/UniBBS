//
//  BBSTopicReader.h
//  UniBBS
//
//  Created by Meng Shengbin on 3/10/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBSTopicReader : NSObject

@property (nonatomic, retain) NSString *dataAddress;

- (id)initWithURI:(NSString *)uri;
- (NSURLSessionDataTask *)getTopicPostsWithBlock:(void (^)(NSMutableArray *topicPosts, NSError *error))block;
- (NSURLSessionDataTask *)getMorePostsWithBlock:(void (^)(NSMutableArray *topicPosts, NSError *error))block;

@end
