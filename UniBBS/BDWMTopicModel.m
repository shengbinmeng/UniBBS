//
//  BDWMTopicModel.m
//  BDWM
//
//  Created by fanyingming on 10/6/14.
//  Copyright (c) 2014 cn.pku.fanyingming. All rights reserved.
//

#import "BDWMTopicModel.h"
#import "BDWMString.h"

@implementation BDWMTopicModel

+ (NSArray *)getPlateTopics:(NSString *)href{
    TFHpple * doc;
    NSMutableString * url = [BDWMString linkString:BDWM_PREFIX string:href];
    NSData *htmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    NSData *htmlDataUTF8 = [BDWMString DataConverse_GB2312_to_UTF8:htmlData];
    
    doc = [[TFHpple alloc] initWithHTMLData:htmlDataUTF8];
    
    NSArray *topics = [doc searchWithXPathQuery:@"//body/table[@class='body']//tr"];
    
    NSMutableArray *results = [[NSMutableArray alloc]init];
    //skip first node, because first node is title.
    for ( int i=1; i<topics.count; i++ ) {
        TFHppleElement *e = [topics objectAtIndex:i];
        BDWMTopic *topic = [[BDWMTopic alloc]init];
        
        NSArray *plate_element = [e searchWithXPathQuery:@"//td"];
        
        if ( plate_element.count< TOPIC_ELEMENT_NUMBER ) {
            continue;
        }
        
        //parse topic_author
        TFHppleElement *ee = [plate_element objectAtIndex:1];
        NSArray *element = [ee searchWithXPathQuery:@"//a"];
        TFHppleElement *element_e = [element objectAtIndex:0];
        topic.topic_author = [element_e text];
        
        //parse topic_date
        ee = [plate_element objectAtIndex:2];
        element = [ee searchWithXPathQuery:@"//span"];
        element_e = [element objectAtIndex:0];
        topic.topic_date = [element_e text];
        
        //parse topic_title and topic_href
        ee = [plate_element objectAtIndex:3];
        element = [ee searchWithXPathQuery:@"//a"];
        element_e = [element objectAtIndex:0];
        NSRange range1 = NSMakeRange(0, 2);
   //   NSRange range1 = [topic_title_before rangeOfString:@"●"]
        NSMutableString *topic_title_before = [[NSMutableString alloc]initWithString:[element_e text]];
        [topic_title_before deleteCharactersInRange:range1];
        
        topic.topic_title = topic_title_before;
        topic.topic_href  = [element_e objectForKey:@"href"];
        
        //parse topic_posting_number
        ee = [plate_element objectAtIndex:4];
        topic.topic_posting_number = [ee text];
        
        [results addObject:topic];
    }
    
    return results;

}

#pragma mark - Posting
//
+ (NSMutableArray *)LoadPosting:(NSString *)href{
    NSMutableArray *postings = [[NSMutableArray alloc]init];
    TFHpple * doc;
    
    NSString *string = [NSString stringWithFormat:@"%@%@", BDWM_PREFIX, href];
    
//    NSLog(@"href=%@",string);
    
    NSData *htmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:string]];
    
    NSData *htmlDataUTF8 = [BDWMString DataConverse_GB2312_to_UTF8:htmlData];
    
    doc = [[TFHpple alloc] initWithHTMLData:htmlDataUTF8];
    
    NSArray *news = [doc searchWithXPathQuery:@"//table[@class='doc']"];
    NSLog(@"news COUNT: %d", news.count);
    
    //get every cell's content by cell index.
    //we should find all message, includeing messages below quotes.
    for (int i=0; i<news.count; i++) {
        NSMutableString *content = [[NSMutableString alloc]init];
        TFHppleElement *e = [news objectAtIndex:i];
        NSArray *post = [e searchWithXPathQuery:@"//tr//td//pre"];
        if (post.count<=0) {
            continue;
        }
        e = [post objectAtIndex:0];
        
        //The code below may be some what complicated, but very useful.
        //The code below collect all message, includeing reply, quote, signature and otherthings else.
        //We must make sure every object added is not nil.
        NSArray *child = e.children;
        NSLog(@"child:%i",child.count);
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
                NSLog(@"==i:%i %@",i,[ee content]);
                [content appendString:[ee content]];
            }
        }
        NSLog(@"content:%@",content);
        
        BDWMPosting *posting = [[BDWMPosting alloc]init];
        posting.content      = content;
        
        //parse reply link
        e = [news objectAtIndex:i];
        NSArray *reply = [e searchWithXPathQuery:@"//table[@class='foot']//th[@class='postNew']//a"];
        if (reply.count<=0) {//no reply link, means didn't login.
            posting.reply_href = @"";
        }else{
            TFHppleElement *reply_link = [reply objectAtIndex:0];
            NSString *reply_href = [reply_link objectForKey:@"href"];
            posting.reply_href   = reply_href;
        }
        
        [postings addObject:posting];
    }
    
    return postings;
}

//When post reply request, we need get some post data first, like threadid postid...
+ (NSDictionary* )getNeededReplyData:(NSString *)href
{
    TFHpple * doc;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    
    NSString *string = [NSString stringWithFormat:@"%@%@", BDWM_PREFIX, href];
    
    
    NSData *htmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:string]];
    htmlData = [BDWMString DataConverse_GB2312_to_UTF8:htmlData];
    doc = [[TFHpple alloc] initWithHTMLData:htmlData];
    
    TFHppleElement *e;
    
    NSArray *titles = [doc searchWithXPathQuery:@"//form[@name='frmpost']//input[@name='title_exp']"];
    e = [titles objectAtIndex:0];
    NSString *reply_title = [e objectForKey:@"value"];
    [dic setValue:reply_title forKey:@"title_exp"];
   
    NSArray *boards = [doc searchWithXPathQuery:@"//form[@name='frmpost']//input[@name='board']"];
    e = [boards objectAtIndex:0];
    NSString *board = [e objectForKey:@"value"];
    [dic setValue:board forKey:@"board"];
    
    NSArray *threadids = [doc searchWithXPathQuery:@"//form[@name='frmpost']//input[@name='threadid']"];
    e = [threadids objectAtIndex:0];
    NSString *threadid = [e objectForKey:@"value"];
    [dic setValue:threadid forKey:@"threadid"];
    
    NSArray *postids = [doc searchWithXPathQuery:@"//form[@name='frmpost']//input[@name='postid']"];
    e = [postids objectAtIndex:0];
    NSString *postid = [e objectForKey:@"value"];
    [dic setValue:postid forKey:@"postid"];
    
    NSArray *userIds = [doc searchWithXPathQuery:@"//form[@name='frmpost']//input[@name='id']"];
    e = [userIds objectAtIndex:0];
    NSString *user_id = [e objectForKey:@"value"];
    [dic setValue:user_id forKey:@"user_id"];
    
    NSArray *codes = [doc searchWithXPathQuery:@"//form[@name='frmpost']//input[@name='code']"];
    e = [codes objectAtIndex:0];
    NSString *code = [e objectForKey:@"value"];
    [dic setValue:code forKey:@"code"];
    
    NSArray *notice_authors = [doc searchWithXPathQuery:@"//form[@name='frmpost']//input[@name='notice_author']"];
    e = [notice_authors objectAtIndex:0];
    NSString *notice_author = [e objectForKey:@"value"];
    [dic setValue:notice_author forKey:@"notice_author"];
    
    NSArray *qusers = [doc searchWithXPathQuery:@"//form[@name='frmpost']//input[@name='quser']"];
    e = [qusers objectAtIndex:0];
    NSString *quser = [e objectForKey:@"value"];
    [dic setValue:quser forKey:@"quser"];
    
    NSArray *reply_page = [doc searchWithXPathQuery:@"//table[@class='post']//td[@class='post']//textarea[@name='text']"];
    e = [reply_page objectAtIndex:0];
    NSString *quote = [e text];
    [dic setValue:quote forKey:@"quote"];
    
    return dic;
}

+ (NSDictionary* )getNeededComposeData:(NSString *)href
{
    TFHpple * doc;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    
    NSString *string = [NSString stringWithFormat:@"%@%@", BDWM_PREFIX, href];
    
    
    NSData *htmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:string]];
    htmlData = [BDWMString DataConverse_GB2312_to_UTF8:htmlData];
    doc = [[TFHpple alloc] initWithHTMLData:htmlData];
    
    TFHppleElement *e;
    
//    NSArray *titles = [doc searchWithXPathQuery:@"//form[@name='frmpost']//input[@name='title_exp']"];
//    e = [titles objectAtIndex:0];
//    NSString *reply_title = [e objectForKey:@"value"];
    [dic setValue:@"" forKey:@"title_exp"];
    
    NSArray *boards = [doc searchWithXPathQuery:@"//form[@name='frmpost']//input[@name='board']"];
    e = [boards objectAtIndex:0];
    NSString *board = [e objectForKey:@"value"];
    [dic setValue:board forKey:@"board"];
    
    NSArray *threadids = [doc searchWithXPathQuery:@"//form[@name='frmpost']//input[@name='threadid']"];
    e = [threadids objectAtIndex:0];
    NSString *threadid = [e objectForKey:@"value"];
    [dic setValue:threadid forKey:@"threadid"];
    
    NSArray *postids = [doc searchWithXPathQuery:@"//form[@name='frmpost']//input[@name='postid']"];
    e = [postids objectAtIndex:0];
    NSString *postid = [e objectForKey:@"value"];
    [dic setValue:postid forKey:@"postid"];
    
    NSArray *userIds = [doc searchWithXPathQuery:@"//form[@name='frmpost']//input[@name='id']"];
    e = [userIds objectAtIndex:0];
    NSString *user_id = [e objectForKey:@"value"];
    [dic setValue:user_id forKey:@"id"];
    
    NSArray *codes = [doc searchWithXPathQuery:@"//form[@name='frmpost']//input[@name='code']"];
    e = [codes objectAtIndex:0];
    NSString *code = [e objectForKey:@"value"];
    [dic setValue:code forKey:@"code"];
    
    NSArray *notice_authors = [doc searchWithXPathQuery:@"//form[@name='frmpost']//input[@name='notice_author']"];
    e = [notice_authors objectAtIndex:0];
    NSString *notice_author = [e objectForKey:@"value"];
    [dic setValue:notice_author forKey:@"notice_author"];
    
    return dic;
}

@end
