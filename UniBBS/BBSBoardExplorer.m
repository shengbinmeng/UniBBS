//
//  BBSBoardExplorer.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/8/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "BBSBoardExplorer.h"

@implementation BBSBoardExplorer {
    NSString *rootAddress;
    NSMutableArray *subBoards;
}

- (id)initWithAddress:(NSString *)address {
    self = [super init];
    
    subBoards = [[NSMutableArray alloc] init];
    
    rootAddress = address;
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease]; 
    [request setURL:[NSURL URLWithString:rootAddress]];  
    [request setHTTPMethod:@"GET"]; 
    [request setTimeoutInterval:15];
    
    NSData *returnedData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (returnedData) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *content = [[[NSString alloc] initWithData:returnedData encoding:enc] autorelease];
        
        NSLog(@"%@",content);
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=\"bbs(xboa|top).php.(group|board)=([^\"]*)\">([^<]*)</a>" options:0 error:NULL];
        NSArray *matches = [regex matchesInString:content options:0 range:NSMakeRange(0, [content length])];
        int c = [matches count];
        
        NSString *name, *description, *groupID;
        for (int i = 0; i < c - 1; ++i) {
            NSMutableDictionary *board = [[NSMutableDictionary alloc] init];
            NSTextCheckingResult *m = [matches objectAtIndex:i];
            NSString *type = [content substringWithRange:[m rangeAtIndex:1]];
            if ([type isEqualToString:@"xboa"]) {
                [board setValue:@"YES" forKey:@"isGroup"];
                groupID = [content substringWithRange:[m rangeAtIndex:3]];
                [board setValue:groupID forKey:@"groupID"];
                name = [content substringWithRange:[m rangeAtIndex:4]];
                [board setValue:name forKey:@"name"];
                i++;
                NSTextCheckingResult *nm = [matches objectAtIndex:i];
                description = [content substringWithRange:[nm rangeAtIndex:4]];
                [board setValue:description forKey:@"description"];
            } else if ([type isEqualToString:@"top"]) {
                [board setValue:@"NO" forKey:@"isGroup"];
                NSString *name = [content substringWithRange:[m rangeAtIndex:3]];
                [board setValue:name forKey:@"name"];
                NSString *description = [content substringWithRange:[m rangeAtIndex:4]];
                [board setValue:description forKey:@"description"];
            }
            
            [subBoards addObject:board];
        }
    }
    
    return self;
}

- (int) numberOfSubBoards {
    return subBoards.count;
}

- (NSDictionary*) GetSubBoardsAtIndex:(int)index {
    return [subBoards objectAtIndex:index];
}

- (NSMutableArray*) GetAllSubBoards {
    return subBoards;
}
@end
