//
//  BDWMPopularReader.m
//  UniBBS
//
//  Created by Shengbin Meng on 06/11/2016.
//  Copyright © 2016 Peking University. All rights reserved.
//

#import "BDWMPopularReader.h"
#import "BDWMNetwork.h"

@implementation BDWMPopularReader
+ (NSURLSessionDataTask *)getPopularTopicsOfType:(int)type WithBlock:(void (^)(NSMutableArray *topics, NSError *error))block
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"gettop", @"type", @"30", @"number", nil];
    
    [[BDWMNetwork sharedManager] requestWithMethod:GET WithParams:params WithSuccessBlock:^(NSDictionary *dic) {
        NSLog(@"%@", dic);
        NSArray *array = (NSArray*)dic;
        NSMutableArray *popularTopics = [[NSMutableArray alloc] initWithArray:array];
        block(popularTopics, nil);
    } WithFailurBlock:^(NSError *error) {
        block(nil, error);
    }];
    
    return nil;
}
@end
