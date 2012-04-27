//
//  BBSPopularReader.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/10/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "BBSPopularReader.h"
#import "Utility.h"

@implementation BBSPopularReader {
    NSMutableArray *popularTopics;
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

- (NSMutableArray*) readPopularTopics 
{
    if (popularTopics) {
        [popularTopics release];
    }
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    popularTopics = [[NSMutableArray alloc] init];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease]; 
    [request setURL:[NSURL URLWithString:self.dataAddress]];  
    [request setHTTPMethod:@"GET"]; 
    [request setTimeoutInterval:15];
    
    NSData *returnedData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (returnedData) {
        NSString *pageSource = [Utility convertDataToString:returnedData];
        
        if (pageSource == nil) {
            [pool drain];
            return popularTopics;
        }
        
        NSLog(@"%@",pageSource);        

        NSString *pattern = @"<td><a href='bbstop.php.board=([^']*)'>([^<]*)</a></td>[^<]*<td>(Anonymous|<a href='bbsqry.php.name=[^']*'>[^<]*</a>)</td>[^<]*<td>([^<]*)</td>[^<]*<td><a href='bbstcon.php.board=[^']*.threadid=([0-9]*)'>([^<]*)</a></td>";

        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
        NSArray *matches = [regex matchesInString:pageSource options:0 range:NSMakeRange(0, [pageSource length])];
        int c = [matches count];
        int num = MIN(c, 100);
        NSString *boardName, *boardDesc, *author, *time, *threadID, *title, *address;
        for (int i = 0; i < num; ++i) {
            NSMutableDictionary *topic = [[NSMutableDictionary alloc] init];
            NSTextCheckingResult *m = [matches objectAtIndex:i];
            boardName = [pageSource substringWithRange:[m rangeAtIndex:1]];
            [topic setValue:boardName forKey:@"boardName"];
            boardDesc = [pageSource substringWithRange:[m rangeAtIndex:2]];
            [topic setValue:boardDesc forKey:@"boardDesc"];
            author = [pageSource substringWithRange:[m rangeAtIndex:3]];
            if (![author isEqualToString:@"Anonymous"]) {
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"name=([^']*)'>" options:0 error:NULL];
                NSTextCheckingResult *result = [regex firstMatchInString:author options:0 range:NSMakeRange(0, author.length)];
                author = [author substringWithRange:[result rangeAtIndex:1]];
            }
            [topic setValue:author forKey:@"author"];

            time = [pageSource substringWithRange:[m rangeAtIndex:4]];
            [topic setValue:time forKey:@"time"];
            threadID = [pageSource substringWithRange:[m rangeAtIndex:5]];
            [topic setValue:threadID forKey:@"threadID"];
            title = [pageSource substringWithRange:[m rangeAtIndex:6]];
            [topic setValue:title forKey:@"title"];
            address = [NSString stringWithFormat:@"http://www.bdwm.net/bbs/bbstcon.php?board=%@&threadid=%@", boardName, threadID];
            [topic setValue:address forKey:@"address"];
            [popularTopics addObject:topic];
            [topic release];
        }
    }
    
    [pool drain];
    return popularTopics;
}

- (void) dealloc 
{
    [popularTopics release];
    [super dealloc];
}
@end
