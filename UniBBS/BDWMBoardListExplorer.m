//
//  BDWMBoardListExplorer.m
//  UniBBS
//
//  Created by Shengbin Meng on 06/11/2016.
//  Copyright © 2016 Peking University. All rights reserved.
//

#import "BDWMBoardListExplorer.h"
#import "BDWMNetwork.h"

@implementation BDWMBoardListExplorer {
    NSString *_listURI;
}

- (id)initWithURI:(NSString *)uri
{
    self = [super init];
    if (self) {
        _listURI = uri;
    }
    return self;
}

- (NSURLSessionDataTask *)getWholeBoardListWithBlock:(void (^)(NSMutableArray *topics, NSError *error))block
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"getallboards", @"type", nil];
    
    [[BDWMNetwork sharedManager] requestWithMethod:GET WithParams:params WithSuccessBlock:^(NSDictionary *dic) {
        NSLog(@"%@", dic);
        NSArray *array = (NSArray*)dic;
        NSMutableArray *allboards = [[NSMutableArray alloc] initWithArray:array];
        block(allboards, nil);
    } WithFailurBlock:^(NSError *error) {
        block(nil, error);
    }];
    
    return nil;
}

@end
