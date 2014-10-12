//
//  BDWMTopic.h
//  BDWM
//
//  Created by fanyingming on 10/6/14.
//  Copyright (c) 2014 cn.pku.fanyingming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFHpple.h"
#import "BDWMGlobalData.h"

@interface BDWMTopic : NSObject

@property (nonatomic, strong) NSString *topic_title;//topic name
@property (nonatomic, strong) NSString *topic_author;
@property (nonatomic, strong) NSString *topic_date;
@property (nonatomic, strong) NSString *topic_posting_number;
@property (nonatomic, strong) NSString *plate;//from which plate
@property (nonatomic, strong) NSString *topic_href;//link to detail page.

@end
