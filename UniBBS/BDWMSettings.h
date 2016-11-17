//
//  BDWMSettings.h
//  UniBBS
//
//  Created by fanyingming on 10/19/14.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDWMSettings : NSObject

+ (BOOL)boolUsePostSuffixString;
+ (void)setBoolUsePostSuffixString:(BOOL)value;

+ (BOOL)boolAutoLogin;
+ (void)setBoolAutoLogin:(BOOL)value;

@end
