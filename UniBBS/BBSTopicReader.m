//
//  BBSTopicReader.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/10/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "BBSTopicReader.h"
#import "Utility.h"
#import "AFAppDotNetAPIClient.h"

@implementation BBSTopicReader {

    NSString *previousPage;
    NSString *nextPage;
    NSString *firstPage;
    NSString *lastPage;
}

@synthesize dataAddress;

-(NSString *)getNextPageHref
{
    self.dataAddress = [NSString stringWithFormat:@"http://www.bdwm.net/bbs/%@", nextPage];
    return self.dataAddress;
}

- (id)initWithAddress:(NSString *)address 
{
    self = [super init];
    if (self) {
        self.dataAddress = address;
    }
    return self;
}

- (NSURLSessionDataTask *)getTopicPostsWithBlock:(NSString *)href blockFunction:(void (^)(NSMutableArray *topicPosts, NSError *error))block {
    return [[AFAppDotNetAPIClient sharedClient] GET:href parameters:nil success:^(NSURLSessionDataTask * __unused task, id responseObject) {
        NSMutableArray *results = [self readTopicPosts:responseObject];
        if (block) {
            block( results, nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block([NSMutableArray array], error);
        }
    }];
    
}

- (NSMutableArray*) readTopicPosts:(NSData *)returnedData
{    
    NSMutableArray *topicPosts = [NSMutableArray array];
    
    if (returnedData) {
        NSString *pageSource = [Utility convertDataToString:returnedData];        
        if (pageSource == nil) {
            return topicPosts;
        }
#ifdef DEBUG    
        NSLog(@"%@",pageSource);
#endif
        NSRange rbeg, rend, range;
        
        range.location = 0;
        range.length = [pageSource length];
        
        while (range.length > 0) {
            rbeg = [pageSource rangeOfString:@"<pre>" options:0 range:range];
            rend = [pageSource rangeOfString:@"</pre>" options:0 range:range];
            if(rbeg.location == NSNotFound || rend.location == NSNotFound || rbeg.location >= rend.location)
                break;
            NSMutableDictionary *post = [[[NSMutableDictionary alloc] init] autorelease];
            NSMutableString *postContent = [[[NSMutableString alloc] init] autorelease];
            [postContent appendString:[pageSource substringWithRange:NSMakeRange(rbeg.location + 5, rend.location - rbeg.location - 5)]];
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<[^>]+>" options:0 error:NULL];
            [regex replaceMatchesInString:postContent options:0 range:NSMakeRange(0, [postContent length]) withTemplate:@""];
            
            [post setValue:postContent forKey:@"content"];
            
            range.location = rend.location + 5;
            range.length = [pageSource length] - range.location;
            
            NSRange next = [pageSource rangeOfString:@"<pre>" options:0 range:range];
            NSRange attachRange;
            if (next.location == NSNotFound) {
                attachRange = range;
            } else {
                attachRange = NSMakeRange(range.location, next.location - range.location);
            }
            
            regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=\"bbspst.php.board=([^\"]*)\">回文章</a>" options:0 error:NULL];
            
            NSTextCheckingResult *m = [regex firstMatchInString:pageSource options:0 range:attachRange];
            NSString *str = [pageSource substringWithRange:[m rangeAtIndex:1]];
            NSString *address = [NSString stringWithFormat:@"bbspst.php?board=%@", str];
            [post setValue:address forKey:@"replyAddress"];
            
            regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=\"bbspsm.php.board=([^\"]*)\">回信给作者</a>" options:0 error:NULL];
            m = [regex firstMatchInString:pageSource options:0 range:attachRange];
            str = [pageSource substringWithRange:[m rangeAtIndex:1]];
            address = [NSString stringWithFormat:@"bbspsm.php?board=%@", str];
            [post setValue:address forKey:@"replyMailAddress"];
            
            regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=\"(http://attach..bdwm.net/[^\"]*)\"[^>]*>([^<]*)</a>" options:0 error:NULL];
            NSArray *result = [regex matchesInString:pageSource options:0 range:attachRange];
            if ([result count] != 0) {
                NSMutableArray * attachments = [[[NSMutableArray alloc] init] autorelease];
                for (int i = 0; i < [result count]; ++i) {
                    NSMutableDictionary * attach = [[[NSMutableDictionary alloc] init] autorelease];
                    NSTextCheckingResult *r = [result objectAtIndex:i];
                    NSString *url = [pageSource substringWithRange:[r rangeAtIndex:1]];
                    NSString *name = [pageSource substringWithRange:[r rangeAtIndex:2]];
                    [attach setValue:url forKey:@"url"];
                    [attach setValue:name forKey:@"name"];
                    [attachments addObject:attach];
                }
                [post setValue:attachments forKey:@"attachments"];
            }
            
            [topicPosts addObject:post];
        }
                
                
        NSTextCheckingResult *r;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=.{0,6}(bbstcon.php[^\"]*)\"([^>]*)>上一页</a>" options:0 error:NULL];
        r = [regex firstMatchInString:pageSource options:0 range:NSMakeRange(0, [pageSource length])];
        range = [r rangeAtIndex:1];
        if (r && range.length) {
            [previousPage release];
            previousPage = [[pageSource substringWithRange:range] retain];
        } else {
            [previousPage release];
            previousPage = nil;
        }
        
        regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=.{0,6}(bbstcon.php[^\"]*)\"([^>]*)>下一页</a>" options:0 error:NULL];
        r = [regex firstMatchInString:pageSource options:0 range:NSMakeRange(0, [pageSource length])];
        range = [r rangeAtIndex:1];
        if (r && range.length) {
            [nextPage release];
            nextPage = [[pageSource substringWithRange:range] retain];
        } else {
            [nextPage release];
            nextPage = nil;
        }
        
        regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=.{0,6}(bbstcon.php[^\"]*\")([^>]*)>第一页</a>" options:0 error:NULL];
        r = [regex firstMatchInString:pageSource options:0 range:NSMakeRange(0, [pageSource length])];
        range = [r rangeAtIndex:1];
        if (r && range.length) {
            [firstPage release];
            firstPage = [[pageSource substringWithRange:range] retain];
        } else {
            [firstPage release];
            firstPage = nil;
        }
        
        regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=.{0,6}(bbstcon.php[^\"]*)\"([^>]*)>末页</a>" options:0 error:NULL];
        r = [regex firstMatchInString:pageSource options:0 range:NSMakeRange(0, [pageSource length])];
        range = [r rangeAtIndex:1];
        if (r && range.length) {
            [lastPage release];
            lastPage = [[pageSource substringWithRange:range] retain];
        } else {
            [lastPage release];
            lastPage = nil;
        }
    }
    
    return topicPosts;
}

- (NSMutableArray*) readPreviousPage
{
    if (previousPage == nil) {
        return nil;
    }
    //TODO: if has cached, return cache
    
    self.dataAddress = [NSString stringWithFormat:@"http://www.bdwm.net/bbs/%@", previousPage];
    return [self readTopicPosts];
}

- (NSMutableArray*) readNextPage
{
    if (nextPage == nil) {
        return nil;
    }
    self.dataAddress = [NSString stringWithFormat:@"http://www.bdwm.net/bbs/%@", nextPage];
    
    return [self readTopicPosts];
}

- (NSMutableArray*) readFirstPage
{
    if (firstPage == nil) {
        return nil;
    }
    self.dataAddress = [NSString stringWithFormat:@"http://www.bdwm.net/bbs/%@", firstPage];
    return [self readTopicPosts];
}

- (NSMutableArray*) readLastPage
{
    if (lastPage == nil) {
        return nil;
    }
    self.dataAddress = [NSString stringWithFormat:@"http://www.bdwm.net/bbs/%@", lastPage];
    return [self readTopicPosts];
}


@end
