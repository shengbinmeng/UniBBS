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

#define CREATE_FAVOURITE_BOARD_TABLE [db executeUpdate:[NSString stringWithFormat:@"create table %@ (id integer primary key autoincrement not null, boardName text, boardTitle text, accessCount integer)", TABLE_NAME_BOARD]];

+(void) deleteFavouriteBoardTable
{
    // delete the old db.
    NSString *doc=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbPath=[doc stringByAppendingPathComponent:DB_NAME];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:dbPath error:nil];

}
+ (BOOL) deleteFavouriteBoard:(NSMutableDictionary *)dict
{
    FMDatabase *db = [self getDatabase];
    if (db==nil) {
        return NO;
    }
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where id=:id", TABLE_NAME_BOARD];
    [db executeUpdate:sql withParameterDictionary:dict];
    if ([db hadError]) {
        NSLog(@"%d: %@", [db lastErrorCode], [db lastErrorMessage]);
        return NO;
    }
    return YES;
}

+ (void) saveFavorateBoards:(NSMutableDictionary *)dict
{
    FMDatabase *db = [self getDatabase];
    if (db==nil) {
        return;
    }
    if (NO==[self isTableExist:db tableName:TABLE_NAME_BOARD]) {
        CREATE_FAVOURITE_BOARD_TABLE
    }
    if ([self isExistRecord:dict]) {
        return;
    }
    [dict setObject:[NSNumber numberWithInt:1] forKey:@"accessCount"];
    [dict setObject:[NSNull null] forKey:@"id"];
    NSLog(@"saving %@,accessCount:%@", [dict objectForKey:@"boardName"], [dict objectForKey:@"accessCount"]);
    NSString *sql = [NSString stringWithFormat:@"insert into %@ values (:id, :boardName, :boardTitle, :accessCount)", TABLE_NAME_BOARD];
    [db executeUpdate:sql withParameterDictionary:dict];
    if ([db hadError]) {
        NSLog(@"%d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
}

+ (BOOL) isExistRecord:(NSMutableDictionary *)dict
{
    FMDatabase *db = [self getDatabase];
    if (db==nil) {
        return YES;//return yes and do not do save operation.
    }
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where boardName=:boardName", TABLE_NAME_BOARD];
    FMResultSet *rs = [db executeQuery:sql withParameterDictionary:dict];
    if ([rs next]) {
        return YES;
    }else{
        return NO;
    }
}
//load fabourite boards result from db.
+ (void) loadFavouritesBoards
{
    if (_favouriteBoards==nil) {
        _favouriteBoards = [[NSMutableArray alloc] init];
    }else{
        [_favouriteBoards removeAllObjects];
    }
    
    FMDatabase *db = [self getDatabase];
    if (db==nil) {
        return;
    }
    //table not exist then creat one.
    if (YES==[self isTableExist:db tableName:TABLE_NAME_BOARD]) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@", TABLE_NAME_BOARD];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {//add all results.
            NSDictionary *resultDict = [rs resultDictionary];
            NSLog(@"load %@,id:%d,accessCount:%d", [resultDict objectForKey:@"boardName"],[[resultDict objectForKey:@"id"] integerValue],[[resultDict objectForKey:@"accessCount"] integerValue]);
            [_favouriteBoards addObject:[rs resultDictionary]] ;
        }
    }else{
        //this should never happen.
         CREATE_FAVOURITE_BOARD_TABLE
    }
    [db close];
}
//if favouriteBoards table not exist then create one.
+ (void) initFavouriteDataBase
{
    FMDatabase *db = [self getDatabase];
    if (db==nil) {
        return;
    }
    if (NO==[self isTableExist:db tableName:TABLE_NAME_BOARD]) {
        CREATE_FAVOURITE_BOARD_TABLE
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

+ (void) saveFavorateTopics:(NSDictionary *)arr
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingFormat:@"/fav-topic.plist"];
    [_favouriteTopics addObject:arr];
    [_favouriteTopics writeToFile:filePath atomically:YES];
}

+ (void) saveFavoratePosts:(NSDictionary *)arr
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    NSString *documentsDirectory = [paths objectAtIndex:0];  
    NSString *filePath = [documentsDirectory stringByAppendingFormat:@"/fav-post.plist"];
    [_favouritePosts addObject:arr];
    [_favouritePosts writeToFile:filePath atomically:YES];
}



@end
