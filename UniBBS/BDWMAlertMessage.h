//
//  BDWMAlertMessage.h
//  BDWM
//
//  Created by fanyingming on 10/6/14.
//  Copyright (c) 2014 cn.pku.fanyingming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDWMAlertMessage : NSObject

+ (void)alertAndAutoDismissMessage:(NSString *)message;
+ (void)alertMessage:(NSString *)message;
+ (void)startSpinner:(NSString *)message;
+ (void)stopSpinner;
@end
