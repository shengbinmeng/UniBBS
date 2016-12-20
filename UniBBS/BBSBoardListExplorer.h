//
//  BBSBoardListExplorer.h
//  UniBBS
//
//  Created by Meng Shengbin on 3/8/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBSBoardListExplorer : NSObject

- (id)initWithURI:(NSString *)uri;
- (NSURLSessionDataTask *)getWholeBoardListWithBlock:(void (^)(NSMutableArray *topics, NSError *error))block;
- (NSURLSessionDataTask *)getBoardListWithBlock:(void (^)(NSMutableArray *topics, NSError *error))block;

@end
