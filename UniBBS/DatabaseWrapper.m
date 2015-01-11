//
//  BatabaseWrapper.m
//  UniBBS
//
//  Created by FanYingming on 15/1/10.
//  Copyright (c) 2015 Peking University. All rights reserved.
//

#import "DatabaseWrapper.h"
#import "BDWMGlobalData.h"

@implementation DatabaseWrapper

//get db object
+ (FMDatabase *)getDatabase
{
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbPath = [doc stringByAppendingPathComponent:DB_NAME];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if (![db open]) {
        NSLog(@"Could not open db.");
        NSLog(@"%d: %@", [db lastErrorCode], [db lastErrorMessage]);
        return nil;
    }
    
    return db;
}

+ (void)deleteDatabase
{
    // delete the old db.
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbPath = [doc stringByAppendingPathComponent:DB_NAME];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    [fileManager removeItemAtPath:dbPath error:nil];
}

+(void)createTable:(NSString *)sql
{
    FMDatabase *db = [self getDatabase];
    
    [db executeUpdate:sql];
    
    if ([db hadError]) {
        NSLog(@"%d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db close];
}

+ (BOOL)isTableExist:(NSString *)tableName
{
    FMDatabase *db = [self getDatabase];
    FMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
    
    if ([rs next]) {
        // just print out what we've got in a number of formats.
        NSInteger count = [rs intForColumn:@"count"];
        if (0 == count) {
            [db close];
            return NO;
        } else {
            [db close];
            return YES;
        }
    }
    
    return NO;
}

+ (BOOL)isExistRecord:(NSMutableDictionary *)dict sql:(NSString*)sql
{
    FMDatabase *db = [self getDatabase];
    FMResultSet *rs = [db executeQuery:sql withParameterDictionary:dict];
    
    if ([rs next]) {
        [db close];
        return YES;
    } else {
        [db close];
        return NO;
    }
}

+ (BOOL)deleteRecord:(NSMutableDictionary *)dict sql:(NSString*)sql
{
    FMDatabase *db = [self getDatabase];
    
    if (db == nil) {
        [db close];
        return NO;
    }
    
#ifdef DEBUG
    NSLog(@"%@", sql);
#endif
    [db executeUpdate:sql withParameterDictionary:dict];
    if ([db hadError]) {
        NSLog(@"%d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db close];
    
    return YES;
}

+ (void)insertRecord:(NSMutableDictionary *)dict sql:(NSString*)sql
{
    FMDatabase *db = [DatabaseWrapper getDatabase];
    
    if (dict == nil) {
        NSLog(@"dict is nil");
        [db close];
        return;
    }
    
    if (db == nil) {
        NSLog(@"db is nil");
        [db close];
        return;
    }
    
    [db executeUpdate:sql withParameterDictionary:dict];
    
    if ([db hadError]) {
        NSLog(@"%d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db close];
}

+ (NSDictionary *)getOneRecord:(NSMutableDictionary *)dict sql:(NSString*)sql
{
    NSDictionary *resultDict = [[NSDictionary alloc] init];
    FMDatabase *db = [DatabaseWrapper getDatabase];
    FMResultSet *rs = [db executeQuery:sql withParameterDictionary:dict];
    
    if ([db hadError]) {
        NSLog(@"%d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    if ([rs next]) {
        resultDict = [rs resultDictionary];
    }
    
    [db close];
    
    return resultDict;
}

+ (NSMutableArray *)getAllRecord:(NSString*)sql
{
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    FMDatabase *db = [DatabaseWrapper getDatabase];
    FMResultSet *rs = [db executeQuery:sql];
    
    if ([db hadError]) {
        NSLog(@"%d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    while ([rs next]) {
        [resultArray addObject:[[rs resultDictionary] mutableCopy]];
    }
    
    [db close];
    
    return resultArray;
}

+ (NSMutableArray *)getAllRecord:(NSString*)sql parameter:(NSString*)parameter
{
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    FMDatabase *db = [DatabaseWrapper getDatabase];
    FMResultSet *rs = [db executeQuery:sql, parameter];
    
    if ([db hadError]) {
        NSLog(@"%d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    while ([rs next]) {
        [resultArray addObject:[[rs resultDictionary] mutableCopy]];
    }
    
    [db close];

    return resultArray;
}

@end
