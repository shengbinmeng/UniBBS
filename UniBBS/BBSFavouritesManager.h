//
//  BBSFavouritesManager.h
//  UniBBS
//
//  Created by Meng Shengbin on 3/31/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBSFavouritesManager : NSObject

+ (void) initFavouriteDataBase;
+ (void) loadFavourites;

+(BOOL) deleteFavouriteBoard:(NSMutableDictionary *)dict;
+(BOOL) deleteFavouriteTopic:(NSMutableDictionary *)dict;
+(BOOL) deleteFavouritePost:(NSMutableDictionary *)dict;
+(void) deleteFavouriteTable;

+ (void) saveFavouriteBoards:(NSMutableDictionary *)dict;
+ (void) saveFavouriteTopics:(NSMutableDictionary *)dict;
+ (void) saveFavouritePosts:(NSMutableDictionary *)dict;

+ (NSMutableArray*) favouriteBoards;
+ (NSMutableArray*) favouriteTopics;
+ (NSMutableArray*) favouritePosts;

@end
