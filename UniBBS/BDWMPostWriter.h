//
//  BDWMPostWriter.h
//  UniBBS
//
//  Created by fanyingming on 10/6/14.
//  Copyright (c) 2014 cn.pku.fanyingming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDWMPostWriter : NSObject

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *reply_href;
@property (nonatomic, strong) NSString *mail_href;

+ (void) sendPosting:(NSString *)board WithTitle:(NSString *)title WithContent:(NSString *)content  WithAnonymous:(int)anonymous blockFunction:(void (^)(NSDictionary *responseDict, NSString *error))block;

+ (void) replyPosting:(NSString *)board WithTitle:(NSString *)title WithContent:(NSString *)content  WithAnonymous:(int)anonymous WithThreadid:(NSString *)threadid WithPostid:(NSString *)postid WithAuthor:(NSString *)author blockFunction:(void (^)(NSDictionary *responseDict, NSString *error))block;

@end
