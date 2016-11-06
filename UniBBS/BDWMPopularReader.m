//
//  BDWMPopularReader.m
//  UniBBS
//
//  Created by Shengbin Meng on 06/11/2016.
//  Copyright © 2016 Peking University. All rights reserved.
//

#import "BDWMPopularReader.h"

@implementation BDWMPopularReader
+ (NSURLSessionDataTask *)getPopularTopicsOfType:(int)type WithBlock:(void (^)(NSMutableArray *topics, NSError *error))block
{
    // TODO: Replace the following code to implement new reader using the API. 
    return [super getPopularTopicsOfType:type WithBlock:block];
}
@end
