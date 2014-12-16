//
//  BBSFavouritesManager.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/31/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "BBSFavouritesManager.h"

  NSMutableArray* _favouriteBoards=nil;
  NSMutableArray* _favouriteTopics=nil;
  NSMutableArray* _favouritePosts=nil;

@implementation BBSFavouritesManager 

+ (void) loadData
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    NSString *documentsDirectory = [paths objectAtIndex:0];  
    NSString *filePath = [documentsDirectory stringByAppendingFormat:@"/fav-board.plist"];
    _favouriteBoards = [NSMutableArray arrayWithContentsOfFile:filePath];
    if (_favouriteBoards == nil) {
        _favouriteBoards = [[NSMutableArray alloc] init];
    }
    
    filePath = [documentsDirectory stringByAppendingFormat:@"/fav-topic.plist"];
    _favouriteTopics = [NSMutableArray arrayWithContentsOfFile:filePath];
    if (_favouriteTopics == nil) {
        _favouriteTopics = [[NSMutableArray alloc] init];
    }
    
    filePath = [documentsDirectory stringByAppendingFormat:@"/fav-post.plist"];
    _favouritePosts = [[NSMutableArray arrayWithContentsOfFile:filePath] mutableCopy];
    if (_favouritePosts == nil) {
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
+ (void) saveFavorateBoards:(NSDictionary *)arr
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingFormat:@"/fav-board.plist"];
    [_favouriteBoards addObject:arr];
    [_favouriteBoards writeToFile:filePath atomically:YES];

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
