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

+ (NSMutableDictionary *)loadReplyMailNeed:(NSString *)href{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSString *url = [BDWMString linkString:BDWM_PREFIX string:href];
    
    TFHpple * doc;
    NSData *htmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    
    NSData *htmlDataUTF8 = [BDWMString DataConverse_GB2312_to_UTF8:htmlData];
    
    doc = [[TFHpple alloc] initWithHTMLData:htmlDataUTF8];
    NSArray *arr = [doc searchWithXPathQuery:@"//form[@name='frmpost']//table[@class='post']//tr"];

    if (arr.count<MAIL_REPLY_TABLE_TR_NUMBER) {
        return nil;
    }
    
    //parse username and signature.
    TFHppleElement *e = [arr objectAtIndex:0];
    NSArray *arr_tr = [e searchWithXPathQuery:@"//input[@name='to']"];
    TFHppleElement *ee = [arr_tr objectAtIndex:0];
    NSString *recever = [ee objectForKey:@"value"];
    [dict setObject:recever forKey:@"to"];
    //Todo: handle signature in later version.
    
    //parse title and quote type
    e = [arr objectAtIndex:1];
    arr_tr = [e searchWithXPathQuery:@"//input[@name='title']"];
    ee = [arr_tr objectAtIndex:0];
    NSString *title = [ee objectForKey:@"value"];
    [dict setObject:title forKey:@"title"];
    //Todo: handle quote type in later version.

    //parse content.
    e = [arr objectAtIndex:2];
    arr_tr = [e searchWithXPathQuery:@"//textarea[@name='text']"];
    ee = [arr_tr objectAtIndex:0];
    NSString *content = [ee text];
    [dict setObject:content forKey:@"content"];
    
    return dict;
}

//Press view button when view mail list.
+ (NSDictionary *)loadMailByhref:(NSString *)href{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSString *url = [BDWMString linkString:BDWM_PREFIX string:href];
    NSMutableString *content = [[NSMutableString alloc]init];
    
    TFHpple * doc;
    NSData *htmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    
    NSData *htmlDataUTF8 = [BDWMString DataConverse_GB2312_to_UTF8:htmlData];
    
    doc = [[TFHpple alloc] initWithHTMLData:htmlDataUTF8];
    NSArray *arr = [doc searchWithXPathQuery:@"//table[@class='doc']//td[@class='doc']//pre"];
    TFHppleElement *e = [arr objectAtIndex:0];
    
    //The code below may be some what complicated, but very useful.
    //The code below collect all message, includeing reply, quote, signature and otherthings else.
    //We must make sure every object added is not nil.
    NSArray *child = e.children;
    NSLog(@"child:%lu",(unsigned long)child.count);
    for (int i=0; i<child.count; i++) {
        TFHppleElement *ee = [child objectAtIndex:i];
        if ([ee content]==nil) {//surround by <span>, like quote.
            //search span then,
            if ([ee text]==nil) {//handle last message, for example "ip source" and "reedit by who and when."
                //search <b>
                NSArray *post = [ee searchWithXPathQuery:@"//span"];
                if (post.count<=0) {
                    continue;
                }
                TFHppleElement *span = [post objectAtIndex:0];
                if ([span text]==nil) {
                    continue;
                }
                NSLog(@"==i:%i %@",i,[span text]);
            
                [content appendString:[span text]];
            }else{
                NSLog(@"==i:%i %@",i,[ee text]);
                [content appendString:[ee text]];
            }
        }else{
            [content appendString:[ee content]];
        }
    }
    NSLog(@"content:%@",content);
    
    //parse reply mail link
    arr = [doc searchWithXPathQuery:@"//center/table[@class='foot']//table[@class='foot']"];
    
    if (arr.count==MAIL_DETAIL_FOOTER_ELEMENT_NUMBER) {
        e = [arr objectAtIndex:3];
    }else if(arr.count==MAIL_DETAIL_FOOTER_ELEMENT_NUMBER-1){
        e = [arr objectAtIndex:2];//no previous page or next page
    }else if(arr.count==MAIL_DETAIL_FOOTER_ELEMENT_NUMBER-2){
        //only one mail.
        e = [arr objectAtIndex:1];
    }else{
        return nil;
    }
    
    
    NSArray *reply = [e searchWithXPathQuery:@"//th[@class='foot']//a"];
    if (reply.count<=0) {//no reply link, means didn't login or something.
        [dict setValue:@"" forKey:@"reply_href"];
    }else{
        TFHppleElement *reply_link = [reply objectAtIndex:0];
        NSString *reply_href = [reply_link objectForKey:@"href"];
        [dict setValue:reply_href forKey:@"href"];
    }
    
    [dict setValue:content forKey:@"content"];
    return dict;
}

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
        [mail setObject:mail_href forKey:@"href"];
        [results addObject:mail];
    }
    
    return results;
}

@end
