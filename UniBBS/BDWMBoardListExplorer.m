//
//  BDWMBoardListExplorer.m
//  UniBBS
//
//  Created by Shengbin Meng on 06/11/2016.
//  Copyright © 2016 Peking University. All rights reserved.
//

#import "BDWMBoardListExplorer.h"

// TODO: Re-implement with new API.
@implementation BDWMBoardListExplorer {
    NSMutableArray *_boardList;
    NSString *_dataAddress;
}

static int count;
+ (NSString*) convertDataToString: (NSData*) sourceData
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *pageSource = [[NSString alloc] initWithData:sourceData encoding:enc];
    if (pageSource == nil) {
        pageSource = [[NSString alloc] initWithData:sourceData encoding:NSUTF8StringEncoding];
    }
    if (pageSource == nil && count == 0) {
        NSMutableData *data = [NSMutableData dataWithData:sourceData];
        unsigned char *bytes = [data mutableBytes];
        for (int i=0; i<[data length]-1; ++i) {
            if (bytes[i] >= 0x80) {
                if (bytes[i] >= 0x81 && bytes[i] <= 0xfe && bytes[i+1] >= 0x40 && bytes[i+1] <= 0xfe && bytes[i+1] != 0x7f)
                    i++;
                else
                    bytes[i] = ' ';
            }
        }
        
        count = 1;
        // try again with the new modified data
        pageSource = [BDWMBoardListExplorer convertDataToString:data];
        count = 0;
    }
    
    return pageSource;
}


- (id)initWithURI:(NSString *)uri
{
    self = [super init];
    if (self) {
        _dataAddress = uri;
    }
    return self;
}

- (NSMutableArray*) getBoardList
{
    _boardList = [[NSMutableArray alloc] init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:_dataAddress]];
    [[NSURLCache sharedURLCache] setMemoryCapacity:1024*1024*2];
    [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:60];
    NSData *returnedData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (returnedData) {
        NSString *pageSource = [BDWMBoardListExplorer convertDataToString:returnedData];
        if (pageSource == nil) {
            return _boardList;
        }
#ifdef DEBUG
        NSLog(@"%@",pageSource);
#endif
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=\"bbs(xboa|top|top2).php.(group|board)=([^\"]*)\">([^<]*)</a>" options:0 error:NULL];
        NSArray *matches = [regex matchesInString:pageSource options:0 range:NSMakeRange(0, [pageSource length])];
        NSUInteger c = [matches count];
        
        NSString *name, *description, *groupID;
        for (int i = 0; i < c; i++) {
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
            } else if ([type isEqualToString:@"top2"]) {
                [board setValue:@"NO" forKey:@"isGroup"];
                NSString *name = [pageSource substringWithRange:[m rangeAtIndex:3]];
                [board setValue:name forKey:@"name"];
                [board setValue:[NSString stringWithFormat:@"http://www.bdwm.net/bbs/bbstop2.php?board=%@", name] forKey:@"address"];
                NSString *description = [pageSource substringWithRange:[m rangeAtIndex:4]];
                [board setValue:description forKey:@"description"];
            }
            [_boardList addObject:board];
        }
    }
    
    return _boardList;
}

- (NSMutableArray*) getWholeBoardList
{
    NSString *oldAddress = _dataAddress;
    _dataAddress = @"http://www.bdwm.net/bbs/bbsall.php";
    NSMutableArray* list = [self getBoardList];
    _dataAddress = oldAddress;
    return list;
}

@end
