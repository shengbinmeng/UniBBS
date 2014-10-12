//
//  BDWMTopicModel.h
//  BDWM
//
//  Created by fanyingming on 10/6/14.
//  Copyright (c) 2014 cn.pku.fanyingming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDWMTopic.h"
#import "BDWMPosting.h"

@interface BDWMTopicModel : NSObject

+ (NSDictionary* )getNeededComposeData:(NSString *)href;
+ (NSDictionary* )getNeededReplyData:(NSString *)href;
+ (NSMutableArray *)LoadPosting:(NSString *)href;
+ (NSArray *)getPlateTopics:(NSString *)href;

@end
