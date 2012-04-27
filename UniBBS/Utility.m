//
//  Utility.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/31/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "Utility.h"
static int count = 0;
@implementation Utility

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
        pageSource = [Utility convertDataToString:data];
        count = 0;
    }
    
    return pageSource;
}

@end
