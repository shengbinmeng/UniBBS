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

- (id)initWithAddress:(NSString *)address;

- (NSURLSessionDataTask *)getTopicPostsWithBlock:(NSString *)href blockFunction:(void (^)(NSMutableArray *topicPosts, NSError *error))block;
- (NSMutableArray*) readTopicPosts:(NSData *)returnedData;
-(NSString *)getNextPageHref;
@end
