//
//  BBSPostReader.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/10/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "BBSPostReader.h"
#import "Utility.h"
#import "BDWMGlobalData.h"

@interface BBSPostReader ()
@property (nonatomic, retain) NSString *dataAddress;
@end

@implementation BBSPostReader {
    NSMutableDictionary *postAttributes;
}

@synthesize dataAddress;

- (id)initWithURI:(NSString *)uri
{
    self = [super init];
    if (self) {
        self.dataAddress = uri;
    }
    return self;
}

- (NSDictionary*) getPostAttributes 
{
    postAttributes = [[NSMutableDictionary alloc] init];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:self.dataAddress]];  
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:DEFAULT_TIMEOUT_SECONDS];
    
    NSData *returnedData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (returnedData) {
        NSString *pageSource = [Utility convertDataToString:returnedData];        
        if (pageSource == nil) {
            return postAttributes;
        }

        NSLog(@"%@",pageSource);
        
        NSRange rbeg, rend, range;
        range.location = 0;
        range.length = [pageSource length];
        rbeg = [pageSource rangeOfString:@"<pre>" options:0 range:range];
        rend = [pageSource rangeOfString:@"</pre>" options:0 range:range];
        if(rbeg.location == NSNotFound || rend.location == NSNotFound || rbeg.location >= rend.location) {
            return postAttributes;
        }
        
        NSMutableString *postContent = [[NSMutableString alloc] init];
        [postContent appendString:[pageSource substringWithRange:NSMakeRange(rbeg.location + 5, rend.location - rbeg.location - 5)]];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<[^>]+>" options:0 error:NULL];
        [regex replaceMatchesInString:postContent options:0 range:NSMakeRange(0, [postContent length]) withTemplate:@""];
        [postAttributes setValue:postContent forKey:@"content"];
        
        regex = [NSRegularExpression regularExpressionWithPattern:@"标  题: ([^\n]*)\n发信站" options:0 error:NULL];
        range = [[regex firstMatchInString:postContent options:0 range:NSMakeRange(0, [postContent length])] rangeAtIndex:1];
        NSString * title = [postContent substringWithRange:range];
        [postAttributes setValue:title forKey:@"title"];
        
        regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=\"(http://attach..bdwm.net/[^\"]*)\"[^>]*>([^<]*)</a>" options:0 error:NULL];
        NSArray *result = [regex matchesInString:postContent options:0 range:NSMakeRange(0, postContent.length)];
        if ([result count] != 0) {
            NSMutableArray * attachments = [[NSMutableArray alloc] init];
            for (int i = 0; i < [result count]; ++i) {
                NSMutableDictionary * attach = [[NSMutableDictionary alloc] init];
                NSTextCheckingResult *r = [result objectAtIndex:i];
                NSString *url = [pageSource substringWithRange:[r rangeAtIndex:1]];
                NSString *name = [pageSource substringWithRange:[r rangeAtIndex:2]];
                [attach setValue:url forKey:@"url"];
                [attach setValue:name forKey:@"name"];
                [attachments addObject:attach];
            }
            [postAttributes setValue:attachments forKey:@"attachments"];
        }
        
        NSTextCheckingResult *r;
        regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=.{0,6}(bbscon.php[^\"]*)\"([^>]*)>上篇</a>" options:0 error:NULL];
        r = [regex firstMatchInString:pageSource options:0 range:NSMakeRange(0, [pageSource length])];
        range = [r rangeAtIndex:1];
        if (r && range.length) {
            NSString *prevPost = [pageSource substringWithRange:range];
            [postAttributes setValue:[NSString stringWithFormat:@"http://www.bdwm.net/bbs/%@", prevPost] forKey:@"prevPostAddress"];
        }
        
        regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=.{0,6}(bbscon.php[^\"]*)\"([^>]*)>下篇</a>" options:0 error:NULL];
        r = [regex firstMatchInString:pageSource options:0 range:NSMakeRange(0, [pageSource length])];
        range = [r rangeAtIndex:1];
        if (r && range.length) {
            NSString *nextPost = [pageSource substringWithRange:range];
            [postAttributes setValue:[NSString stringWithFormat:@"http://www.bdwm.net/bbs/%@", nextPost] forKey:@"nextPostAddress"];
        }
        
        regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=.{0,6}(bbstcon.php[^\"]*)\"([^>]*)>同主题展开</a>" options:0 error:NULL];
        r = [regex firstMatchInString:pageSource options:0 range:NSMakeRange(0, [pageSource length])];
        range = [r rangeAtIndex:1];
        if (r && range.length) {
            NSString *sameTopic = [pageSource substringWithRange:range];
            [postAttributes setValue:[NSString stringWithFormat:@"http://www.bdwm.net/bbs/%@", sameTopic] forKey:@"sameTopicAddress"];
        }
        
        regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=\"bbspst.php.board=([^\"]*)\">回复</a>" options:0 error:NULL];
        r = [regex firstMatchInString:pageSource options:0 range:NSMakeRange(0, [pageSource length])];
        range = [r rangeAtIndex:1];
        if (r && range.length) {
            NSString *str = [pageSource substringWithRange:range];
            [postAttributes setValue:[NSString stringWithFormat:@"bbspst.php?board=%@", str] forKey:@"replyAddress"];
        }

        regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=\"bbspsm.php.board=([^\"]*)\">写信给作者</a>" options:0 error:NULL];
        r = [regex firstMatchInString:pageSource options:0 range:NSMakeRange(0, [pageSource length])];
        range = [r rangeAtIndex:1];
        if (r && range.length) {
            NSString *str = [pageSource substringWithRange:range];
            [postAttributes setValue:[NSString stringWithFormat:@"bbspsm.php?board=%@", str] forKey:@"replyMailAddress"];
        }
        
    }
        
    return postAttributes;
}


- (NSDictionary*) getPreviousPost
{
    NSString *address = [postAttributes valueForKey:@"prevPostAddress"];
    if (address == nil) {
        return nil;
    } else {
        self.dataAddress = address;
        return [self getPostAttributes];
    }
}

- (NSDictionary*) getNextPost
{
    NSString *address = [postAttributes valueForKey:@"nextPostAddress"];
    if (address == nil) {
        return nil;
    } else {
        self.dataAddress = address;
        return [self getPostAttributes];
    }
}

- (NSString*) getSameTopicUri
{
    return [postAttributes valueForKey:@"sameTopicAddress"];
}

@end
