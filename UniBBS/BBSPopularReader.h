//
//  BBSPopularReader.h
//  UniBBS
//
//  Created by Meng Shengbin on 3/10/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBSPopularReader : NSObject

+ (NSURLSessionDataTask *)getPopularTopicsOfType:(int)type WithBlock:(void (^)(NSMutableArray *topics, NSError *error))block;

@end
