//
//  BBSBoardListExplorer.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/8/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "BBSBoardListExplorer.h"
#import "Utility.h"

@implementation BBSBoardListExplorer {
    NSMutableArray *boardList;
}

@synthesize dataAddress;

- (id)initWithAddress:(NSString *)address 
{
    self = [super init];
    if (self) {
        self.dataAddress = address;
    }
    return self;
}

- (NSMutableArray*) getBoardList 
{
    if (boardList) {
        [boardList release];
    }
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    boardList = [[NSMutableArray alloc] init];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease]; 
    [request setURL:[NSURL URLWithString:self.dataAddress]]; 
    [[NSURLCache sharedURLCache] setMemoryCapacity:1024*1024*2];
    [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    [request setHTTPMethod:@"GET"]; 
    [request setTimeoutInterval:15];
    NSData *returnedData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (returnedData) {
        NSString *pageSource = [Utility convertDataToString:returnedData];
        if (pageSource == nil) {
            [pool drain];
            return boardList;
        }
#ifdef DEBUG     
        NSLog(@"%@",pageSource);
#endif
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=\"bbs(xboa|top).php.(group|board)=([^\"]*)\">([^<]*)</a>" options:0 error:NULL];
        NSArray *matches = [regex matchesInString:pageSource options:0 range:NSMakeRange(0, [pageSource length])];
        NSUInteger c = [matches count];
        
        NSString *name, *description, *groupID;
        for (int i = 0; i < c - 1; ++i) {
            NSMutableDictionary *board = [[NSMutableDictionary alloc] init];
            NSTextCheckingResult *m = [matches objectAtIndex:i];
            NSString *type = [pageSource substringWithRange:[m rangeAtIndex:1]];
            if ([type isEqualToString:@"xboa"]) {
                [board setValue:@"YES" forKey:@"isGroup"];
                groupID = [pageSource substringWithRange:[m rangeAtIndex:3]];
                [board setValue:groupID forKey:@"groupID"];
                [board setValue:[NSString stringWithFormat:@"http://www.bdwm.net/bbs/bbsxboa.php?group=%@", groupID] forKey:@"address"];
                name = [pageSource substringWithRange:[m rangeAtIndex:4]];
                [board setValue:name forKey:@"name"];
                i++;
                NSTextCheckingResult *nm = [matches objectAtIndex:i];
                description = [pageSource substringWithRange:[nm rangeAtIndex:4]];
                [board setValue:description forKey:@"description"];
            } else if ([type isEqualToString:@"top"]) {
                [board setValue:@"NO" forKey:@"isGroup"];
                NSString *name = [pageSource substringWithRange:[m rangeAtIndex:3]];
                [board setValue:name forKey:@"name"];
                [board setValue:[NSString stringWithFormat:@"http://www.bdwm.net/bbs/bbstop.php?board=%@", name] forKey:@"address"];
                NSString *description = [pageSource substringWithRange:[m rangeAtIndex:4]];
                [board setValue:description forKey:@"description"];
            }            
            [boardList addObject:board];
            [board release];
        }
    }
    
    [pool drain];
    return boardList;
}

- (NSMutableArray*) getWholeBoardList 
{
    self.dataAddress = @"http://www.bdwm.net/bbs/bbsall.php";
    return [self getBoardList];
}

- (void) dealloc 
{
    [boardList release];
    [super dealloc];
}

@end
