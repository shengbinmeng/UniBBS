//
//  BBSBoardListExplorer.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/8/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "BBSBoardListExplorer.h"

@implementation BBSBoardListExplorer

- (id)initWithURI:(NSString *)uri
{
    NSLog(@"Init with URI: %@", uri);
    return [super init];
}

- (NSURLSessionDataTask *)getBoardListWithBlock:(void (^)(NSMutableArray *topics, NSError *error))block
{
    NSLog(@"Get board list");
    return nil;
}

- (NSURLSessionDataTask *)getWholeBoardListWithBlock:(void (^)(NSMutableArray *topics, NSError *error))block
{
    NSLog(@"Get whole board list");
    return nil;
}

@end
