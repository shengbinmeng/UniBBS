//
//  BDWMString.m
//  BDWM
//
//  Created by fanyingming on 10/6/14.
//  Copyright (c) 2014 cn.pku.fanyingming. All rights reserved.
//

#import "BDWMString.h"

@implementation BDWMString

+ (NSData *)DataConverse_GB2312_to_UTF8:(NSData *)htmlData{
    NSStringEncoding gbEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    NSString *htmlStr = [[NSString alloc] initWithData:htmlData encoding:gbEncoding];
    
//    NSString *utf8HtmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=gb2312\" />"
//                                                               withString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />"];
    NSData *htmlDataUTF8 = [htmlStr dataUsingEncoding:NSUTF8StringEncoding];
    
    return htmlDataUTF8;
}

+ (NSMutableString *)linkString:(NSString *)string1 string:string2{
    NSMutableString * url = [[NSMutableString alloc] init];
    [url appendString:string1];
    [url appendString:string2];
    return url;
}

@end
