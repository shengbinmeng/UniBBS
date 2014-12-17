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

+ (void) initFavouriteDataBase
{
    FMDatabase *db = [self initDatabase];
    //table not exist then creat one.
    if (NO==[self isTableExist:db tableName:@"favouriteBorads"]) {
        [db executeUpdate:@"create table favouriteBorads (boardName text, boardTitle text)"];
    }
    [db close];
}
+ (BOOL) isTableExist:(FMDatabase *) db tableName:(NSString *)tableName
{
    FMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
    while ([rs next])
    {
        // just print out what we've got in a number of formats.
        NSInteger count = [rs intForColumn:@"count"];
        if (0 == count)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    
    return NO;
}

+ (FMDatabase *) initDatabase
{
    NSString *doc=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName=[doc stringByAppendingPathComponent:DB_NAME];
    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
    if (![db open]) {
        NSLog(@"Could not open db.");
        NSLog(@"%d: %@", [db lastErrorCode], [db lastErrorMessage]);
        return nil;
    }
    
    return db;
}

+ (BOOL) isExistRecord:(NSMutableDictionary *)dict
{
    FMDatabase *db = [self initDatabase];
    FMResultSet *rs = [db executeQuery:@"select * from favouriteBorads where boardName=:boardName" withParameterDictionary:dict];
    if ([rs next]) {
        return YES;
    }else{
        return NO;
    }
}

+ (void) loadFavouritesBoards
{
    if (_favouriteBoards==nil) {
        _favouriteBoards = [[NSMutableArray alloc] init];
    }else{
        [_favouriteBoards removeAllObjects];
    }
    
    FMDatabase *db = [self initDatabase];
    //table not exist then creat one.
    if (NO==[self isTableExist:db tableName:@"favouriteBorads"]) {
        [db executeUpdate:@"create table favouriteBorads (boardName text, boardTitle text)"];
    }else{
        FMResultSet *rs = [db executeQuery:@"select * from favouriteBorads"];
        while ([rs next]) {//add all results.
            [_favouriteBoards addObject:[rs resultDictionary]] ;
        }
    }
    [db close];
}

+ (void) loadData
{
    
    if (_favouriteTopics==nil) {
        _favouriteTopics = [[NSMutableArray alloc] init];
    }
    if (_favouritePosts==nil) {
        _favouritePosts = [[NSMutableArray alloc] init];
    }
    
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

+ (BOOL) deleteFavouriteBoard:(NSMutableDictionary *)dict
{
    FMDatabase *db = [self initDatabase];
    [db executeUpdate:@"delete from favouriteBorads where boardName=:boardName" withParameterDictionary:dict];
    if ([db hadError]) {
        NSLog(@"%d: %@", [db lastErrorCode], [db lastErrorMessage]);
        return NO;
    }
    return YES;
}

+ (void) saveFavorateBoards:(NSMutableDictionary *)dict
{
    FMDatabase *db = [self initDatabase];
    if ([self isExistRecord:dict]) {
        return;
    }
    [db executeUpdate:@"insert into favouriteBorads values (:boardName, :boardTitle)" withParameterDictionary:dict];
    if ([db hadError]) {
        NSLog(@"%d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
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
