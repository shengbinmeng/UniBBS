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
+ (NSDictionary* )getNeededReplyData:(NSData *)data;
+ (NSMutableArray *)LoadPosting:(NSString *)href;
+ (NSArray *)getPlateTopics:(NSString *)href;
+ (NSURLSessionDataTask *)loadReplyNeededDataWithBlock:(NSString *)href blockFunction:(void (^)(NSDictionary* data, NSError *error))block;
@end
