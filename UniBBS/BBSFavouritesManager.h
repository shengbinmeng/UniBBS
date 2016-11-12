//
//  BBSFavouritesManager.h
//  UniBBS
//
//  Created by Meng Shengbin on 3/31/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBSFavouritesManager : NSObject

+ (void) saveFavouriteBoard:(NSMutableDictionary *)board;
+ (void) saveFavouriteTopic:(NSMutableDictionary *)topic;
+ (void) saveFavouritePost:(NSMutableDictionary *)post;

+ (NSMutableArray *) loadFavouriteBoards;
+ (NSMutableArray *) loadFavouriteTopics;
+ (NSMutableArray *) loadFavouritePosts;

+ (BOOL) deleteFavouriteBoard:(NSMutableDictionary *)board;
+ (BOOL) deleteFavouriteTopic:(NSMutableDictionary *)topic;
+ (BOOL) deleteFavouritePost:(NSMutableDictionary *)post;

@end
