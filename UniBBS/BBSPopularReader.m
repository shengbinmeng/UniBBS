//
//  BBSPopularReader.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/10/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "BBSPopularReader.h"

@implementation BBSPopularReader

+ (NSURLSessionDataTask *)getPopularTopicsOfType:(int)type WithBlock:(void (^)(NSMutableArray *topics, NSError *error))block {
    NSLog(@"Get popular topics");
    return nil;
}

@end
