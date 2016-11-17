//
//  MailModel.h
//  UniBBS
//
//  Created by fanyingming on 10/12/14.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDWMMailModel : NSObject

+ (void)getAllMailWithBlock:(NSString *)userName blockFunction:(void (^)(NSArray *mails, NSString *error))block;

+ (NSMutableArray *)loadMails:(NSData *)htmlData;
+ (NSDictionary *)loadMailByhref:(NSString *)href;
+ (NSMutableDictionary *)loadReplyMailNeededData:(NSString *)href;
+ (NSMutableDictionary *)loadComposeMailNeededData;

+ (NSURLSessionDataTask *)deleteMailByHref:(NSString *)href;

@end
