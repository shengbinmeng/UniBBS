//
//  BBSFavouritesManager.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/31/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "BBSFavouritesManager.h"

@implementation BBSFavouritesManager

+ (BOOL) deleteFavouriteBoard:(NSMutableDictionary *)board
{
    NSLog(@"Delete favourite board.");
    BOOL success = YES;
    return success;
}

+ (BOOL) deleteFavouriteTopic:(NSMutableDictionary *)topic
{
    NSLog(@"Delete favourite topic.");
    BOOL success = YES;
    return success;
}

+ (BOOL) deleteFavouritePost:(NSMutableDictionary *)post
{
    NSLog(@"Delete favourite post.");
    BOOL success = YES;
    return success;
}

+ (void) saveFavouriteBoard:(NSMutableDictionary *)board
{
    NSLog(@"Save favourite board.");
}

+ (void) saveFavouriteTopic:(NSMutableDictionary *)topic
{
    NSLog(@"Save favourite topic.");
}

+ (void) saveFavouritePost:(NSMutableDictionary *)post
{
    NSLog(@"Save favourite post.");
}

+ (NSMutableArray *) loadFavouriteBoards
{
    NSLog(@"Load favourite boards.");
    return [[NSMutableArray alloc] init];
}

+ (NSMutableArray *) loadFavouriteTopics
{
    NSLog(@"Load favourite topics.");
    return [[NSMutableArray alloc] init];
}

+ (NSMutableArray *) loadFavouritePosts
{
    NSLog(@"Load favourite posts.");
    return [[NSMutableArray alloc] init];
}

@end
