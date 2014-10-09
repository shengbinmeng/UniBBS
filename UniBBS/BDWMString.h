//
//  BDWMString.h
//  BDWM
//
//  Created by fanyingming on 10/6/14.
//  Copyright (c) 2014 cn.pku.fanyingming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDWMString : NSObject

+ (NSData *)DataConverse_GB2312_to_UTF8:(NSData *)htmlData;
+ (NSMutableString *)linkString:(NSString *)string1 string:string2;
@end
