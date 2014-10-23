//
//  BBSBoardReader.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/11/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "BBSBoardReader.h"
#import "Utility.h"
#import "AFAppDotNetAPIClient.h"

@implementation BBSBoardReader {
    NSMutableArray *boardTopics;
    NSMutableArray *boardPosts;
    NSString *previousPage;
    NSString *nextPage;
    NSString *firstPage;
    NSString *lastPage;
    NSString *latestPage;
    BOOL readingTopics;
}

@synthesize boardName, dataAddress, showSticky;


- (id)initWithBoardName:(NSString *)name 
{
    self = [super init];
    if (self) {
        self.boardName = name;
    }
    return self;
}

- (NSURLSessionDataTask *)getBoardPostsWithBlock:(void (^)(NSMutableArray *posts, NSError *error))block {
    if (self.dataAddress == nil) {
        self.dataAddress = [NSString stringWithFormat:@"http://www.bdwm.net/bbs/bbsdoc.php?board=%@", self.boardName];
    }
    
    return [[AFAppDotNetAPIClient sharedClient] GET:self.dataAddress parameters:nil success:^(NSURLSessionDataTask * __unused task, id responseObject) {
        NSMutableArray *results = [self readBoardPosts:responseObject];
        if (block) {
            block( results, nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block([NSMutableArray array], error);
        }
    }];
    
}

- (NSURLSessionDataTask *)getBoardNextPostsWithBlock:(void (^)(NSMutableArray *posts, NSError *error))block {
    self.dataAddress = [NSString stringWithFormat:@"http://www.bdwm.net/bbs/%@", previousPage];
    self.showSticky = NO;//shen show more, do not include sticky.
    
    return [[AFAppDotNetAPIClient sharedClient] GET:self.dataAddress parameters:nil success:^(NSURLSessionDataTask * __unused task, id responseObject) {
        NSMutableArray *results = [self readBoardPosts:responseObject];
        if (block) {
            block( results, nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block([NSMutableArray array], error);
        }
    }];
    
}

- (NSURLSessionDataTask *)getBoardNextTopicsWithBlock:(void (^)(NSMutableArray *topics, NSError *error))block {
    self.dataAddress = [NSString stringWithFormat:@"http://www.bdwm.net/bbs/%@", previousPage];
    self.showSticky = NO;//shen show more, do not include sticky.
    
    return [[AFAppDotNetAPIClient sharedClient] GET:self.dataAddress parameters:nil success:^(NSURLSessionDataTask * __unused task, id responseObject) {
        NSMutableArray *results = [self readBoardTopics:responseObject];
        if (block) {
            block( results, nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block([NSMutableArray array], error);
        }
    }];
    
}

- (NSURLSessionDataTask *)getBoardTopicsWithBlock:(void (^)(NSMutableArray *topics, NSError *error))block {
    if (self.dataAddress == nil) {
        self.dataAddress = [NSString stringWithFormat:@"http://www.bdwm.net/bbs/bbstop.php?board=%@", self.boardName];
    }
    
    return [[AFAppDotNetAPIClient sharedClient] GET:self.dataAddress parameters:nil success:^(NSURLSessionDataTask * __unused task, id responseObject) {
        NSMutableArray *results = [self readBoardTopics:responseObject];
        if (block) {
            block( results, nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block([NSMutableArray array], error);
        }
    }];
    
}

- (NSMutableArray*) readBoardTopics:(NSData *)returnedData
{
    readingTopics = YES;
    if (boardTopics) {
        [boardTopics release];
    }
    
    boardTopics = [[NSMutableArray alloc] init];

    if (returnedData) {
        NSString *pageSource = [Utility convertDataToString:returnedData];
        
        if (pageSource == nil) {
            return boardTopics;
        }
        
        NSLog(@"%@",pageSource);
                 
        NSRegularExpression *regex;
        if (self.showSticky)//show stick and normal topics.
            regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=\"(bbst?con.php[^\"]*)\">([^<]*)</a>" options:0 error:NULL];
        else//show normal only.
            regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=\"(bbstcon.php[^\"]*)\">([^<]*)</a>" options:0 error:NULL];
        NSArray *result = [regex matchesInString:pageSource options:0 range:NSMakeRange(0, [pageSource length])];
        
        for (int i = 0; i < [result count]; ++i) {
            NSMutableDictionary *topic = [[NSMutableDictionary alloc] init];
            NSTextCheckingResult *r = [result objectAtIndex:i];
            NSRange range;
            range = [r rangeAtIndex:1];
            NSString *address = [pageSource substringWithRange:range];
            [topic setValue:[NSString stringWithFormat:@"http://www.bdwm.net/bbs/%@", address] forKey:@"address"];

            NSString *infoScope = [pageSource substringWithRange:NSMakeRange(range.location - 180, 180)];
            
            
            range = [[[NSRegularExpression regularExpressionWithPattern:@"class=col..>([^<]*)<" options:0 error:NULL] firstMatchInString:infoScope options:0 range:NSMakeRange(0, infoScope.length)] rangeAtIndex:1];
            NSString *time = [infoScope substringWithRange:range];
            [topic setValue:time forKey:@"time"];

            NSTextCheckingResult *res = [[NSRegularExpression regularExpressionWithPattern:@"<a href=\"(bbsqry.php.name=[^\"]*)\">([^<]*)</a>" options:0 error:NULL] firstMatchInString:infoScope options:0 range:NSMakeRange(0, infoScope.length)] ;
            //TODO: use author info address
            //range = [res rangeAtIndex:1];
            range = [res rangeAtIndex:2];
            NSString *author = [infoScope substringWithRange:range];
            [topic setValue:author forKey:@"author"];

            
            range = [r rangeAtIndex:2];
            range.location += 1;
            range.length -= 1;
            NSString *title = [pageSource substringWithRange:range];
            [topic setValue:title forKey:@"title"];
            
            if (self.showSticky){
                NSTextCheckingResult *res = [[NSRegularExpression regularExpressionWithPattern:@"dig" options:0 error:NULL] firstMatchInString:address options:0 range:NSMakeRange(0, address.length)] ;
                range = [res rangeAtIndex:0];
                 NSString *dig = [address substringWithRange:range];
                if ( dig!=nil && [dig isEqual:@"dig"] ) {
                    [topic setValue:@"YES" forKey:@"sticky"];
                }else{
                    [topic setValue:@"NO" forKey:@"sticky"];
                }

                
            }else{
                [topic setValue:@"NO" forKey:@"sticky"];
            }
            
            [boardTopics addObject:topic];
            [topic release];
        }
        
        regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=\"(bbstop.php[^\"]*)\">上页</a>" options:0 error:nil];
        NSTextCheckingResult *r = [regex firstMatchInString:pageSource options:0 range:NSMakeRange(0, [pageSource length])];
        NSRange range = [r rangeAtIndex:1];
        if (previousPage) {
            [previousPage release];
        }
        if (r && range.length) {
            previousPage = [[pageSource substringWithRange:range] retain];
        } else {
            previousPage = nil;
        }
        regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=\"(bbstop.php[^\"]*)\">下页</a>" options:0 error:nil];
        r = [regex firstMatchInString:pageSource options:0 range:NSMakeRange(0, [pageSource length])];
        range = [r rangeAtIndex:1];
        if (nextPage) {
            [nextPage release];
        }
        if (r && range.length) {
            nextPage = [[pageSource substringWithRange:range] retain];
        } else {
            nextPage = nil;
        }
        
        regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=\"(bbstop.php[^\"]*)\">最新</a>" options:0 error:NULL];
        r = [regex firstMatchInString:pageSource options:0 range:NSMakeRange(0, [pageSource length])];
        range = [r rangeAtIndex:1];
        if (latestPage) {
            [latestPage release];
        }
        if (r && range.length) {
            latestPage = [[pageSource substringWithRange:range] retain];
        } else {
            latestPage = nil;
        }
        
        [pageSource release];
    }

    if (self.showSticky) {
        NSMutableArray *stickyArray = [NSMutableArray array];
        for ( NSDictionary *dic in boardTopics) {
            if ([[dic objectForKey:@"sticky"] isEqualToString:@"YES"]) {
                [stickyArray addObject:dic];
            }else{
                break;
            }
        }
        NSArray *arr = [boardTopics subarrayWithRange:NSMakeRange(stickyArray.count, boardTopics.count-stickyArray.count)];
        [boardTopics removeAllObjects];
        [boardTopics addObjectsFromArray:stickyArray];
        [boardTopics addObjectsFromArray:[[arr reverseObjectEnumerator] allObjects]];
    }else{
        boardTopics = [[[boardTopics reverseObjectEnumerator] allObjects] mutableCopy];
    }

    return boardTopics;
}

- (NSMutableArray*) readBoardPosts:(NSData *)returnedData
{
    readingTopics = NO;
    if (boardPosts) {
        [boardPosts release];
    }
    
    boardPosts = [[NSMutableArray alloc] init];
    
    if (returnedData) {
        NSString *pageSource = [Utility convertDataToString:returnedData];
        if (pageSource == nil) {
            return boardPosts;
        }
#ifdef DEBUG
        NSLog(@"%@",pageSource);
#endif
        NSRegularExpression *regex;
        if (self.showSticky)
            regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=\"(bbscon.php[^\"]*)\">(<span style=\"font-weight:bold;\">)?([^<]*)(</span>)?</a>" options:0 error:NULL];
        else
            regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=\"(bbscon.php[^\"]*)\">([^<]*)</a>" options:0 error:NULL];
        NSArray *result = [regex matchesInString:pageSource options:0 range:NSMakeRange(0, [pageSource length])];
        
        for (int i = 0; i < [result count]; ++i) {
            NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
            NSTextCheckingResult *r = [result objectAtIndex:i];
            NSRange range = [r rangeAtIndex:1];
            NSString *address = [pageSource substringWithRange:range];
            [post setValue:[NSString stringWithFormat:@"http://www.bdwm.net/bbs/%@", address] forKey:@"address"];
            
            NSString *infoScope = [pageSource substringWithRange:NSMakeRange(range.location - 180, 180)];
            range = [[[NSRegularExpression regularExpressionWithPattern:@"class=col..>([^<]*)<" options:0 error:NULL] firstMatchInString:infoScope options:0 range:NSMakeRange(0, infoScope.length)] rangeAtIndex:1];
            NSString *time = [infoScope substringWithRange:range];
            [post setValue:time forKey:@"time"];
            
            NSTextCheckingResult *res = [[NSRegularExpression regularExpressionWithPattern:@"<a href=\"(bbsqry.php.name=[^\"]*)\">([^<]*)</a>" options:0 error:NULL] firstMatchInString:infoScope options:0 range:NSMakeRange(0, infoScope.length)] ;
            //range = [res rangeAtIndex:1]; //TODO: use author info address
            range = [res rangeAtIndex:2];
            NSString *author = [infoScope substringWithRange:range];
            [post setValue:author forKey:@"author"];
            
            if(self.showSticky) range = [r rangeAtIndex:3];
            else range = [r rangeAtIndex:2];
            NSString *title = [pageSource substringWithRange:range];
            [post setValue:title forKey:@"title"];
            
            if ([r numberOfRanges] == 5 && [r rangeAtIndex:4].length != 0){
                [post setValue:@"YES" forKey:@"sticky"];
            } else {
                [post setValue:@"NO" forKey:@"sticky"];
            }
            
            [boardPosts addObject:post];
            [post release];
        }
        
        regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=\"(bbsdoc.php[^\"]*)\">上页</a>" options:0 error:nil];
        NSTextCheckingResult *r = [regex firstMatchInString:pageSource options:0 range:NSMakeRange(0, [pageSource length])];
        NSRange range = [r rangeAtIndex:1];
        if (previousPage) {
            [previousPage release];
        }
        if (r && range.length) {
            previousPage = [[pageSource substringWithRange:range] retain];
        } else {
            previousPage = nil;
        }
        regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=\"(bbsdoc.php[^\"]*)\">下页</a>" options:0 error:nil];
        r = [regex firstMatchInString:pageSource options:0 range:NSMakeRange(0, [pageSource length])];
        range = [r rangeAtIndex:1];
        if (nextPage) {
            [nextPage release];
        }
        if (r && range.length) {
            nextPage = [[pageSource substringWithRange:range] retain];
        } else {
            nextPage = nil;
        }
        
        regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=\"(bbsdoc.php[^\"]*)\">最新</a>" options:0 error:NULL];
        r = [regex firstMatchInString:pageSource options:0 range:NSMakeRange(0, [pageSource length])];
        range = [r rangeAtIndex:1];
        if (latestPage) {
            [latestPage release];
        }
        if (r && range.length) {
            latestPage = [[pageSource substringWithRange:range] retain];
        } else {
            latestPage = nil;
        }
        
        [pageSource release];
    }
    //sort array. sticky topic should be front, normal topic should be sort by post time(reverse normal topics here).
    if (self.showSticky) {
        NSMutableArray *stickyArray = [NSMutableArray array];
        for ( NSDictionary *dic in boardPosts) {
            if ([[dic objectForKey:@"sticky"] isEqualToString:@"YES"]) {
                [stickyArray addObject:dic];
            }else{
                break;
            }
        }
        NSArray *arr = [boardPosts subarrayWithRange:NSMakeRange(stickyArray.count, boardPosts.count-stickyArray.count)];
        [boardPosts removeAllObjects];
        [boardPosts addObjectsFromArray:stickyArray];
        [boardPosts addObjectsFromArray:[[arr reverseObjectEnumerator] allObjects]];
    }else{
        boardPosts = [[[boardPosts reverseObjectEnumerator] allObjects] mutableCopy];
    }
    
    return boardPosts;
}

- (void) dealloc 
{
    [boardPosts release];
    [boardPosts release];
    [firstPage release];
    [lastPage release];
    [previousPage release];
    [nextPage release];
    [super dealloc];
}

@end
