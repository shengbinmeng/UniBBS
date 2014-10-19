//
//  SettingModel.h
//  UniBBS
//
//  Created by fanyingming on 10/19/14.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingModel : NSObject
+ (BOOL)boolUsePostSuffixString;
+ (void)setBoolUsePostSuffixString:(BOOL)value;
@end
