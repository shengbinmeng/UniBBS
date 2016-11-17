//
//  BDWMFavouritesManager.h
//  UniBBS
//
//  Created by Shengbin Meng on 06/11/2016.
//  Copyright © 2016 Peking University. All rights reserved.
//

#import "BBSFavouritesManager.h"

@interface BDWMFavouritesManager : BBSFavouritesManager

+ (void) saveFavouriteBoard:(NSMutableDictionary *)board;
+ (void) saveFavouriteTopic:(NSMutableDictionary *)topic;
+ (void) saveFavouritePost:(NSMutableDictionary *)post;

+ (NSMutableArray *) loadFavouriteBoards;
+ (NSMutableArray *) loadFavouriteTopics;
+ (NSMutableArray *) loadFavouritePosts;

+(BOOL) deleteFavouriteBoard:(NSMutableDictionary *)board;
+(BOOL) deleteFavouriteTopic:(NSMutableDictionary *)topic;
+(BOOL) deleteFavouritePost:(NSMutableDictionary *)post;

@end
