//
//  BBSPopularReader.h
//  UniBBS
//
//  Created by Meng Shengbin on 3/10/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBSPopularReader : NSObject

@property (nonatomic, retain) NSString *dataAddress;

- (id)initWithAddress:(NSString *)address;
+ (NSMutableArray*)readPopularTopics:(NSData *)returnedData;
+ (NSURLSessionDataTask *)getPopularTopicsWithBlock:(NSString *)href blockFunction:(void (^)(NSMutableArray *topics, NSError *error))block;
@end
