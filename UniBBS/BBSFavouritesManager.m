//
//  BBSFavouritesManager.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/31/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "BBSFavouritesManager.h"

static NSMutableArray* _favouriteBoards;
static NSMutableArray* _favouriteTopics;
static NSMutableArray* _favouritePosts;

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
    _favouritePosts = [NSMutableArray arrayWithContentsOfFile:filePath];
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

+ (void) saveData
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    NSString *documentsDirectory = [paths objectAtIndex:0];  
    NSString *filePath = [documentsDirectory stringByAppendingFormat:@"/fav-board.plist"];
    //NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:_favouriteBoards format:NSPropertyListXMLFormat_v1_0 errorDescription:nil];
    //NSString *plistString = [[NSString alloc] initWithData:plistData encoding:NSUTF8StringEncoding];
   //[plistData writeToFile:filePath atomically:YES];
    [_favouriteBoards writeToFile:filePath atomically:YES];
    
    filePath = [documentsDirectory stringByAppendingFormat:@"/fav-topic.plist"];
    [_favouriteTopics writeToFile:filePath atomically:YES];
    
    filePath = [documentsDirectory stringByAppendingFormat:@"/fav-post.plist"];
    [_favouritePosts writeToFile:filePath atomically:YES];
}

@end
