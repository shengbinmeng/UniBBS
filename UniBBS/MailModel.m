//
//  MailModel.m
//  UniBBS
//
//  Created by fanyingming on 10/12/14.
//  Copyright (c) 2014 Peking University. All rights reserved.
//

#import "MailModel.h"
#import "AFAppDotNetAPIClient.h"
#import "BDWMString.h"
#import "BDWMGlobalData.h"
#import "TFHpple.h"
@implementation MailModel

+ (NSURLSessionDataTask *)getAllMailWithBlock:(NSString *)userName blockFunction:(void (^)(NSArray *mails, NSError *error))block {
    NSString *url = [BDWMString linkString:BDWM_PREFIX string:BDWM_MAIL_LIST_SUFFIX];
    return [[AFAppDotNetAPIClient sharedClient] GET:url parameters:nil success:^(NSURLSessionDataTask * __unused task, id responseObject) {
        NSArray *results = [self loadMails:responseObject];
        if (block) {
            block( results, nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
}

+ (NSMutableArray *)loadMails:(NSData *)htmlData{
    TFHpple * doc;
    
    NSData *htmlDataUTF8 = [BDWMString DataConverse_GB2312_to_UTF8:htmlData];
    
    doc = [[TFHpple alloc] initWithHTMLData:htmlDataUTF8];
    
    NSArray *mails = [doc searchWithXPathQuery:@"//form[@id='myform']//table[@class='body']//tr"];
    
    
    NSMutableArray *results = [[NSMutableArray alloc]init];
    //index 0 is title.
    for ( int i=1; i<mails.count; i++ ) {
        TFHppleElement *e = [mails objectAtIndex:i];
        
        NSArray *mail_element = [e searchWithXPathQuery:@"//td"];
        
        if ( mail_element.count< MAIL_LIST_ELEMENT_NUMBER ) {
            continue;
        }
        
        //parse mail author
        TFHppleElement *ee = [mail_element objectAtIndex:3];
        NSArray *a = [ee searchWithXPathQuery:@"//a"];
        TFHppleElement *eee = [a objectAtIndex:0];
        NSString *author = [eee text];
        
        //parse mail data
        ee = [mail_element objectAtIndex:4];
        a = [ee searchWithXPathQuery:@"//font"];
        eee = [a objectAtIndex:0];
        NSString *date = [eee text];
        
        //parse mail title
        ee = [mail_element objectAtIndex:5];
        a = [ee searchWithXPathQuery:@"//a"];
        eee = [a objectAtIndex:0];
        NSString *title = [eee text];
        NSString *mail_href = [eee objectForKey:@"href"];
        
        NSMutableDictionary *mail = [[NSMutableDictionary alloc] init];
        [mail setObject:author forKey:@"author"];
        [mail setObject:date forKey:@"date"];
        [mail setObject:title forKey:@"title"];
        [mail setObject:mail_href forKey:@"mail_href"];
        [results addObject:mail];
    }
    
    return results;
}

@end
