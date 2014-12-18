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
    [db executeUpdate:@"delete from favouriteBorads where boardName=:boardName" withParameterDictionary:dict];
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
    if (NO==[self isTableExist:db tableName:@"favouriteBorads"]) {
        [db executeUpdate:@"create table favouriteBorads (boardName text, boardTitle text, accessCount integer)"];
    }
    if ([self isExistRecord:dict]) {
        return;
    }
    [dict setObject:[NSNumber numberWithInt:1] forKey:@"accessCount"];
    [db executeUpdate:@"insert into favouriteBorads values (:boardName, :boardTitle, :accessCount)" withParameterDictionary:dict];
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
    FMResultSet *rs = [db executeQuery:@"select * from favouriteBorads where boardName=:boardName" withParameterDictionary:dict];
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
    if (YES==[self isTableExist:db tableName:@"favouriteBorads"]) {
        FMResultSet *rs = [db executeQuery:@"select * from favouriteBorads"];
        while ([rs next]) {//add all results.
            [_favouriteBoards addObject:[rs resultDictionary]] ;
        }
    }else{
        //this should never happen.
         [db executeUpdate:@"create table favouriteBorads (boardName text, boardTitle text, accessCount integer)"];
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
    if (NO==[self isTableExist:db tableName:@"favouriteBorads"]) {
        [db executeUpdate:@"create table favouriteBorads (boardName text, boardTitle text, accessCount integer)"];
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
