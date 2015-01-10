//
//  BBSFavouritesManager.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/31/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "BBSFavouritesManager.h"
#import "FMDB.h"
#import "BDWMGlobalData.h"

NSMutableArray* _favouriteBoards=nil;
NSMutableArray* _favouriteTopics=nil;
NSMutableArray* _favouritePosts=nil;

@implementation BBSFavouritesManager 
#define TABLE_NAME_BOARD @"FavouriteBoards"
#define TABLE_NAME_TOPIC @"FavouriteTopics"
#define TABLE_NAME_POST  @"FavouritePosts"
#define TABLE_NAME_POST_ATTACHMENT @"FavouritePostAttachments"

#define TYPE_BOARD 1
#define TYPE_TOPIC 2
#define TYPE_POST  3

#define CREATE_FAVOURITE_BOARD_TABLE [db executeUpdate:[NSString stringWithFormat:@"create table %@ (id integer primary key autoincrement not null, boardName text, boardTitle text, accessCount integer)", TABLE_NAME_BOARD]];

#define CREATE_FAVOURITE_TOPIC_TABLE [db executeUpdate:[NSString stringWithFormat:@"create table %@ (id integer primary key autoincrement not null, title text, address text)", TABLE_NAME_TOPIC]];

#define CREATE_FAVOURITE_POST_TABLE [db executeUpdate:[NSString stringWithFormat:@"create table %@ (id integer primary key autoincrement not null, content text, replyAddress text, replyMailAddress test)", TABLE_NAME_POST]];

+(void) createFavouritePostAttachments:(FMDatabase *)db
{
    NSString *sql = [NSString stringWithFormat:@"create table %@ (id integer primary key autoincrement not null, postId integer, url test, name test, constraint \"postId\" foreign key (\"postId\") references \"FavouritePosts\"(\"id\") on delete cascade on update cascade )", TABLE_NAME_POST_ATTACHMENT] ;
    [db executeUpdate:sql];
    if ([db hadError]) {
        NSLog(@"%d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
}

+(void) deleteFavouriteTable
{
    // delete the old db.
    NSString *doc=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbPath=[doc stringByAppendingPathComponent:DB_NAME];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:dbPath error:nil];

}

+(BOOL) deleteFavouriteBoard:(NSMutableDictionary *)dict
{
   return [self deleteRecord:dict which:TYPE_BOARD];
}

+(BOOL) deleteFavouriteTopic:(NSMutableDictionary *)dict
{
    return [self deleteRecord:dict which:TYPE_TOPIC];
}

+(BOOL) deleteFavouritePost:(NSMutableDictionary *)dict
{
    return [self deleteRecord:dict which:TYPE_POST];
}

+ (BOOL) deleteRecord:(NSMutableDictionary *)dict which:(NSInteger)which
{
    FMDatabase *db = [self getDatabase];
    if (db==nil) {
        return NO;
    }
    NSString *sql;
    switch (which) {
        case TYPE_BOARD:
            if ([self isTableExist:db tableName:TABLE_NAME_BOARD]==NO) {
                NSLog(@"table %@ not exist.", TABLE_NAME_BOARD);
                return NO;
            }
            sql = [NSString stringWithFormat:@"delete from %@ where boardName=:boardName", TABLE_NAME_BOARD];
            break;
        case TYPE_TOPIC:
            if ([self isTableExist:db tableName:TABLE_NAME_TOPIC]==NO) {
                NSLog(@"table %@ not exist.", TABLE_NAME_TOPIC);
                return NO;
            }
            sql = [NSString stringWithFormat:@"delete from %@ where id=:id", TABLE_NAME_TOPIC];
            break;
        case TYPE_POST:
            if ([self isTableExist:db tableName:TABLE_NAME_POST]==NO) {
                NSLog(@"table %@ not exist.", TABLE_NAME_POST);
                return NO;
            }
            sql = [NSString stringWithFormat:@"delete from %@ where id=:id", TABLE_NAME_POST];
            break;
        default:
            return NO;
    }
#ifdef DEBUG
    NSLog(@"%@", sql);
#endif
    [db executeUpdate:sql withParameterDictionary:dict];
    if ([db hadError]) {
        NSLog(@"%d: %@", [db lastErrorCode], [db lastErrorMessage]);
        return NO;
    }
    [db close];
    return YES;
}

+ (void) saveFavouriteBoards:(NSMutableDictionary *)dict
{
    [self saveDataToDB:dict which:TYPE_BOARD];
}

+ (void) saveFavouriteTopics:(NSMutableDictionary *)dict
{
    [self saveDataToDB:dict which:TYPE_TOPIC];
}

+ (void) saveFavouritePosts:(NSMutableDictionary *)dict
{
    [self saveDataToDB:dict which:TYPE_POST];
}

+ (void) saveDataToDB:(NSMutableDictionary *)dict which:(NSInteger)which
{
    if (dict==nil) {
        NSLog(@"dict is nil");
        return;
    }
    FMDatabase *db = [self getDatabase];
    if (db==nil) {
        NSLog(@"db is nil");
        return;
    }
    
    NSString *sql;
    switch (which){
        case TYPE_BOARD:
            if (NO==[self isTableExist:db tableName:TABLE_NAME_BOARD]) {
                CREATE_FAVOURITE_BOARD_TABLE
            }
            if ([self isExistRecord:dict which:TYPE_BOARD db:db]) {
                return;
            }
            [dict setObject:[NSNumber numberWithInt:1] forKey:@"accessCount"];
            [dict setObject:[NSNull null] forKey:@"id"];
            sql = [NSString stringWithFormat:@"insert into %@ values (:id, :boardName, :boardTitle, :accessCount)", TABLE_NAME_BOARD];
#ifdef DEBUG
            NSLog(@"saving %@,accessCount:%@", [dict objectForKey:@"boardName"], [dict objectForKey:@"accessCount"]);
            NSLog(@"%@", sql);
#endif
            break;
        case TYPE_TOPIC:
            if (NO==[self isTableExist:db tableName:TABLE_NAME_TOPIC]) {
                CREATE_FAVOURITE_TOPIC_TABLE
            }
            if ([self isExistRecord:dict which:TYPE_TOPIC db:db]) {
                return;
            }
            [dict setObject:[NSNull null] forKey:@"id"];
            sql = [NSString stringWithFormat:@"insert into %@ values (:id, :title, :address)", TABLE_NAME_TOPIC];
#ifdef DEBUG
            NSLog(@"saving %@,address:%@", [dict objectForKey:@"title"], [dict objectForKey:@"address"]);
            NSLog(@"%@", sql);
#endif
            break;
        case TYPE_POST:
            if (NO==[self isTableExist:db tableName:TABLE_NAME_POST]) {
                CREATE_FAVOURITE_POST_TABLE
                [self createFavouritePostAttachments:db];
            }
            if ([self isExistRecord:dict which:TYPE_POST db:db]) {
                return;
            }
            [dict setObject:[NSNull null] forKey:@"id"];
            sql = [NSString stringWithFormat:@"insert into %@ values (:id, :content, :replyAddress, :replyMailAddress)", TABLE_NAME_POST];
#ifdef DEBUG
            NSLog(@"saving %@", [dict objectForKey:@"content"]);
            NSLog(@"%@", sql);
#endif
            break;
        default:
            return;
    }
    
    [db executeUpdate:sql withParameterDictionary:dict];
    
    if (TYPE_POST==which) {
        sql = [NSString stringWithFormat:@"select * from %@ where content=:content", TABLE_NAME_POST];
        FMResultSet *rs = [db executeQuery:sql withParameterDictionary:dict];
        if ([db hadError]) {
            NSLog(@"%d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        if ([rs next]) {
            NSDictionary *resultDict = [rs resultDictionary];
            NSInteger postId = [[resultDict objectForKey:@"id"] integerValue];
            NSArray *attachments = [dict objectForKey:@"attachments"];
            
            if (attachments!=nil) {
                for (int i=0; i< [attachments count]; i++) {
                    NSMutableDictionary *postAttachment = [attachments objectAtIndex:i];
                    [postAttachment setObject:[NSNumber numberWithInteger:postId]  forKey:@"postId"];
                    [postAttachment setObject:[NSNull null] forKey:@"id"];
                    sql = [NSString stringWithFormat:@"insert into %@ values (:id, :postId, :url, :name)", TABLE_NAME_POST_ATTACHMENT];
                    [db executeUpdate:sql withParameterDictionary:postAttachment];
                    if ([db hadError]) {
                        NSLog(@"%d: %@", [db lastErrorCode], [db lastErrorMessage]);
                    }
                }
            }
            
        }
    }
    
    if ([db hadError]) {
        NSLog(@"%d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db close];
}

+ (BOOL) isExistRecord:(NSMutableDictionary *)dict which:(NSInteger)which db:(FMDatabase *)db
{
    NSString *sql;
    switch (which) {
        case TYPE_BOARD:
            sql = [NSString stringWithFormat:@"select * from %@ where boardName=:boardName", TABLE_NAME_BOARD];
            break;
        case TYPE_TOPIC:
            sql = [NSString stringWithFormat:@"select * from %@ where address=:address", TABLE_NAME_TOPIC];
            break;
        case TYPE_POST:
            sql = [NSString stringWithFormat:@"select * from %@ where content=:content", TABLE_NAME_POST];
            break;
        default:
            return YES;
    }
    
    FMResultSet *rs = [db executeQuery:sql withParameterDictionary:dict];
    if ([rs next]) {
        return YES;
    }else{
        return NO;
    }
}

+ (void) loadFavourites
{
    FMDatabase *db = [self getDatabase];
    if (db==nil) {
        return;
    }
    
    [self loadFavouriteBoards:db];
    [self loadFavouriteTopics:db];
    [self loadFavouritePosts:db];
    
//    [db close];
}
//load fabourite boards result from db.
+ (void) loadFavouriteBoards:(FMDatabase *)db
{
    if (_favouriteBoards==nil) {
        _favouriteBoards = [[NSMutableArray alloc] init];
    }else{
        [_favouriteBoards removeAllObjects];
    }
    
    //table not exist then creat one.
    if (YES==[self isTableExist:db tableName:TABLE_NAME_BOARD]) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@", TABLE_NAME_BOARD];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {//add all results.
            NSDictionary *resultDict = [rs resultDictionary];
#ifdef DEBUG
            NSLog(@"load %@,id:%ld,accessCount:%ld", [resultDict objectForKey:@"boardName"],(long)[[resultDict objectForKey:@"id"] integerValue],(long)[[resultDict objectForKey:@"accessCount"] integerValue]);
#endif
            [_favouriteBoards addObject:[rs resultDictionary]] ;
        }
    }else{
        //this should never happen.
         CREATE_FAVOURITE_BOARD_TABLE
    }

}

+ (void) loadFavouriteTopics:(FMDatabase *)db
{
    if (_favouriteTopics==nil) {
        _favouriteTopics = [[NSMutableArray alloc] init];
    }else{
        [_favouriteTopics removeAllObjects];
    }
    
    //table not exist then creat one.
    if (YES==[self isTableExist:db tableName:TABLE_NAME_TOPIC]) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@", TABLE_NAME_TOPIC];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {//add all results.
            NSDictionary *resultDict = [rs resultDictionary];
#ifdef DEBUG
            NSLog(@"load %@,address:%@", [resultDict objectForKey:@"title"], [resultDict objectForKey:@"address"]);
#endif
            [_favouriteTopics addObject:[rs resultDictionary]] ;
        }
    }else{
        //this should never happen.
        CREATE_FAVOURITE_TOPIC_TABLE
    }

}

+ (void) loadFavouritePosts:(FMDatabase *)db
{
    if (_favouritePosts==nil) {
        _favouritePosts = [[NSMutableArray alloc] init];
    }else{
        [_favouritePosts removeAllObjects];
    }
    
    //table not exist then creat one.
    if (YES==[self isTableExist:db tableName:TABLE_NAME_POST]) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@", TABLE_NAME_POST];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {//add all results.
            NSMutableDictionary *resultDict = [[rs resultDictionary] mutableCopy];
            NSInteger postId = [[resultDict objectForKey:@"id"] integerValue];
            NSString *postIdString = [NSString stringWithFormat:@"%ld", (long)postId];
            BOOL have_attachment=NO;
            NSMutableArray *attachmentsArray = [[NSMutableArray alloc] init];
            
            sql = [NSString stringWithFormat:@"select * from %@ where postId=?", TABLE_NAME_POST_ATTACHMENT];
            FMResultSet * attachmentsResultSet = [db executeQuery:sql, postIdString];
            
            while ([attachmentsResultSet next]) {
                NSDictionary *resultDict_t = [attachmentsResultSet resultDictionary];
                have_attachment=YES;
                [attachmentsArray addObject:resultDict_t];
            }
            if (YES==have_attachment) {
                [resultDict setObject:attachmentsArray forKey:@"attachments"];
            }
#ifdef DEBUG
            NSLog(@"load %@", [resultDict objectForKey:@"content"]);
#endif
            [_favouritePosts addObject:resultDict] ;
        }
    }else{
        CREATE_FAVOURITE_POST_TABLE
        [self createFavouritePostAttachments:db];
    }
    
}

//if favourite tables not exist then create one.
+ (void) initFavouriteDataBase
{
    FMDatabase *db = [self getDatabase];
    if (db==nil) {
        return;
    }
    if (NO==[self isTableExist:db tableName:TABLE_NAME_BOARD]) {
        CREATE_FAVOURITE_BOARD_TABLE
    }
    if (NO==[self isTableExist:db tableName:TABLE_NAME_TOPIC]) {
        CREATE_FAVOURITE_TOPIC_TABLE
    }
    if (NO==[self isTableExist:db tableName:TABLE_NAME_POST]) {
        CREATE_FAVOURITE_POST_TABLE
    }
    if (NO==[self isTableExist:db tableName:TABLE_NAME_POST_ATTACHMENT]) {
        [self createFavouritePostAttachments:db];
    }
    [db close];
}

+ (BOOL) isTableExist:(FMDatabase *) db tableName:(NSString *)tableName
{
    FMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
    if ([rs next])
    {
        // just print out what we've got in a number of formats.
        NSInteger count = [rs intForColumn:@"count"];
        if (0 == count){
            return NO;
        }else{
            return YES;
        }
    }
    return NO;
}
//get db object
+ (FMDatabase *) getDatabase
{
    NSString *doc=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbPath=[doc stringByAppendingPathComponent:DB_NAME];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"Could not open db.");
        NSLog(@"%d: %@", [db lastErrorCode], [db lastErrorMessage]);
        return nil;
    }
    
    return db;
}

+ (NSMutableArray*) favouriteBoards
{
    return _favouriteBoards;
}

+ (NSMutableArray*) favouriteTopics
{
    return _favouriteTopics;
}

+ (NSMutableArray*) favouritePosts
{
    return _favouritePosts;
}

@end
