//
//  BDWMFavouritesManager.m
//  UniBBS
//
//  Created by Shengbin Meng on 06/11/2016.
//  Copyright © 2016 Peking University. All rights reserved.
//

#import "BDWMFavouritesManager.h"
#import "FMDB.h"
#import "BDWMGlobalData.h"
#import "DatabaseWrapper.h"

@implementation BDWMFavouritesManager

#define TABLE_NAME_BOARD @"FavouriteBoards"
#define TABLE_NAME_TOPIC @"FavouriteTopics"
#define TABLE_NAME_POST  @"FavouritePosts"
#define TABLE_NAME_POST_ATTACHMENT @"FavouritePostAttachments"

#pragma mark - create table

+(void) createFavouriteBoardsTable
{
    NSString *SQLStatement = [NSString stringWithFormat:@"create table %@ (id integer primary key autoincrement not null, boardName text, boardTitle text, accessCount integer)", TABLE_NAME_BOARD];
    
    [DatabaseWrapper createTable:SQLStatement];
}

+(void) createFavouriteTopicsTable
{
    NSString *SQLStatement = [NSString stringWithFormat:@"create table %@ (id integer primary key autoincrement not null, title text, address text)", TABLE_NAME_TOPIC];
    
    [DatabaseWrapper createTable:SQLStatement];
}

+(void) createFavouritePostsTable
{
    NSString *SQLStatement = [NSString stringWithFormat:@"create table %@ (id integer primary key autoincrement not null, content text, replyAddress text, replyMailAddress test)", TABLE_NAME_POST];
    
    [DatabaseWrapper createTable:SQLStatement];
}

+(void) createFavouritePostsAttachmentsTable
{
    NSString *SQLStatement = [NSString stringWithFormat:@"create table %@ (id integer primary key autoincrement not null, postId integer, url test, name test, constraint \"postId\" foreign key (\"postId\") references \"FavouritePosts\"(\"id\") on delete cascade on update cascade )", TABLE_NAME_POST_ATTACHMENT] ;
    
    [DatabaseWrapper createTable:SQLStatement];
}

#pragma mark - delete record

+(BOOL) deleteFavouriteBoard:(NSMutableDictionary *)board
{
    NSString *SQLStatement = [NSString stringWithFormat:@"delete from %@ where boardName=:boardName", TABLE_NAME_BOARD];
    
    return [DatabaseWrapper deleteRecord:board sql:SQLStatement];
}

+(BOOL) deleteFavouriteTopic:(NSMutableDictionary *)topic
{
    NSString *SQLStatement = [NSString stringWithFormat:@"delete from %@ where id=:id", TABLE_NAME_TOPIC];
    
    return [DatabaseWrapper deleteRecord:topic sql:SQLStatement];
}

+(BOOL) deleteFavouritePost:(NSMutableDictionary *)post
{
    NSString *SQLStatement = [NSString stringWithFormat:@"delete from %@ where id=:id", TABLE_NAME_POST];
    
    return [DatabaseWrapper deleteRecord:post sql:SQLStatement];
}

#pragma mark - isExist record

+ (BOOL) isExistThisBoard:(NSMutableDictionary *)board
{
    NSString *SQLStatement = [NSString stringWithFormat:@"select * from %@ where boardName=:boardName", TABLE_NAME_BOARD];
    
    return [DatabaseWrapper isExistRecord:board sql:SQLStatement];
}

+ (BOOL) isExistThisTopic:(NSMutableDictionary *)topic
{
    NSString *SQLStatement = [NSString stringWithFormat:@"select * from %@ where address=:address", TABLE_NAME_TOPIC];
    
    return [DatabaseWrapper isExistRecord:topic sql:SQLStatement];
}

+ (BOOL) isExistThisPost:(NSMutableDictionary *)post
{
    NSString *SQLStatement = [NSString stringWithFormat:@"select * from %@ where content=:content", TABLE_NAME_POST];
    
    return [DatabaseWrapper isExistRecord:post sql:SQLStatement];
}

#pragma mark - insert record

+ (void) saveFavouriteBoard:(NSMutableDictionary *)board
{
    if (NO == [DatabaseWrapper isTableExist:TABLE_NAME_BOARD]) [self createFavouriteBoardsTable];
    
    if ([self isExistThisBoard:board]) return;
    
    [board setObject:[NSNumber numberWithInt:1] forKey:@"accessCount"];
    [board setObject:[NSNull null] forKey:@"id"];
    NSString *SQLStatement = [NSString stringWithFormat:@"insert into %@ values (:id, :boardName, :boardTitle, :accessCount)", TABLE_NAME_BOARD];
    
#ifdef DEBUG
    NSLog(@"saving %@,accessCount:%@", [board objectForKey:@"boardName"], [board objectForKey:@"accessCount"]);
    NSLog(@"%@", SQLStatement);
#endif
    
    [DatabaseWrapper insertRecord:board sql:SQLStatement];
}

+ (void) saveFavouriteTopic:(NSMutableDictionary *)topic
{
    if (NO == [DatabaseWrapper isTableExist:TABLE_NAME_TOPIC]) [self createFavouriteTopicsTable];
    
    if ([self isExistThisTopic:topic]) return;
    
    [topic setObject:[NSNull null] forKey:@"id"];
    NSString *SQLStatement = [NSString stringWithFormat:@"insert into %@ values (:id, :title, :address)", TABLE_NAME_TOPIC];
#ifdef DEBUG
    NSLog(@"saving %@,address:%@", [topic objectForKey:@"title"], [topic objectForKey:@"address"]);
    NSLog(@"%@", SQLStatement);
#endif
    
    [DatabaseWrapper insertRecord:topic sql:SQLStatement];
}

+ (void) saveFavouritePost:(NSMutableDictionary *)post
{
    if (NO == [DatabaseWrapper isTableExist:TABLE_NAME_POST]) [self createFavouritePostsTable];
    
    if ([self isExistThisPost:post]) return;
    
    [post setObject:[NSNull null] forKey:@"id"];
    NSString *SQLStatement = [NSString stringWithFormat:@"insert into %@ values (:id, :content, :replyAddress, :replyMailAddress)", TABLE_NAME_POST];
#ifdef DEBUG
    NSLog(@"saving %@,address:%@", [post objectForKey:@"title"], [post objectForKey:@"address"]);
    NSLog(@"%@", SQLStatement);
#endif
    
    [DatabaseWrapper insertRecord:post sql:SQLStatement];
    
    [self saveAttachments:post];
}

//save attachment address of a post.
+ (void) saveAttachments:(NSMutableDictionary *)post
{
    NSString *SQLStatement = [NSString stringWithFormat:@"select * from %@ where content=:content", TABLE_NAME_POST];
    
    NSDictionary *postInDB = [DatabaseWrapper getOneRecord:post sql:SQLStatement];
    
    if (postInDB != nil) {
        NSInteger postId = [[postInDB objectForKey:@"id"] integerValue];
        NSArray *attachments = [post objectForKey:@"attachments"];
        
        if (attachments != nil) {
            for (int i=0; i< [attachments count]; i++) {
                NSMutableDictionary *postAttachment = [attachments objectAtIndex:i];
                
                [postAttachment setObject:[NSNumber numberWithInteger:postId]  forKey:@"postId"];
                [postAttachment setObject:[NSNull null] forKey:@"id"];
                SQLStatement = [NSString stringWithFormat:@"insert into %@ values (:id, :postId, :url, :name)", TABLE_NAME_POST_ATTACHMENT];
                
                [DatabaseWrapper insertRecord:postAttachment sql:SQLStatement];
            }
        }
    }
}

#pragma mark - load Data

+ (NSMutableArray *) loadFavouriteBoards
{
    NSMutableArray *boardsArray = [[NSMutableArray alloc] init];
    
    if (YES == [DatabaseWrapper isTableExist:TABLE_NAME_BOARD]) {
        NSString *SQLStatement = [NSString stringWithFormat:@"select * from %@", TABLE_NAME_BOARD];
        
        boardsArray = [DatabaseWrapper getAllRecord:SQLStatement];
        return boardsArray;
    }else{
        [self createFavouriteBoardsTable];
        return nil;
    }
}

+ (NSMutableArray *) loadFavouriteTopics
{
    NSMutableArray *topicsArray = [[NSMutableArray alloc] init];
    
    if (YES == [DatabaseWrapper isTableExist:TABLE_NAME_TOPIC]) {
        NSString *SQLStatement = [NSString stringWithFormat:@"select * from %@", TABLE_NAME_TOPIC];
        
        topicsArray = [DatabaseWrapper getAllRecord:SQLStatement];
        return topicsArray;
    }else{
        [self createFavouriteTopicsTable];
        return nil;
    }
}

//load post and its attachments.
+ (NSMutableArray *) loadFavouritePosts
{
    NSMutableArray *postsArray = [[NSMutableArray alloc] init];
    
    if (YES == [DatabaseWrapper isTableExist:TABLE_NAME_POST]) {
        NSString *SQLStatement = [NSString stringWithFormat:@"select * from %@", TABLE_NAME_POST];
        
        postsArray = [DatabaseWrapper getAllRecord:SQLStatement];
        
        for (NSMutableDictionary *post in postsArray) {
            NSInteger postId = [[post objectForKey:@"id"] integerValue];
            NSString *postIdString = [NSString stringWithFormat:@"%ld", (long)postId];
            NSMutableArray *attachmentsArray = [[NSMutableArray alloc] init];
            
            SQLStatement = [NSString stringWithFormat:@"select * from %@ where postId=?", TABLE_NAME_POST_ATTACHMENT];
            
            attachmentsArray = [DatabaseWrapper getAllRecord:SQLStatement parameter:postIdString];
            
            if ([attachmentsArray count] >= 1) {
                [post setObject:attachmentsArray forKey:@"attachments"];
            }
            
#ifdef DEBUG
            NSLog(@"load %@", [post objectForKey:@"content"]);
#endif
        }
    }else{
        [self createFavouritePostsTable];
        [self createFavouritePostsAttachmentsTable];
    }
    
    return postsArray;
}

@end
