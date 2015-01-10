//
//  BatabaseWrapper.h
//  UniBBS
//
//  Created by FanYingming on 15/1/10.
//  Copyright (c) 2015年 Peking University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DatabaseWrapper : NSObject

+ (FMDatabase *)getDatabase;

+ (void)createTable:(NSString *)sql;
+ (BOOL)isTableExist:(NSString *)tableName;

+ (void)deleteDatabase;
+ (BOOL)deleteRecord:(NSMutableDictionary *)dict sql:(NSString*)sql;

+ (BOOL)isExistRecord:(NSMutableDictionary *)dict sql:(NSString*)sql;
+ (void)insertRecord:(NSMutableDictionary *)dict sql:(NSString*)sql;

+ (NSDictionary *)getOneRecord:(NSMutableDictionary *)dict sql:(NSString*)sql;

+ (NSMutableArray *)getAllRecord:(NSString*)sql;
+ (NSMutableArray *)getAllRecord:(NSString*)sql parameter:(NSString*)parameter;

@end
