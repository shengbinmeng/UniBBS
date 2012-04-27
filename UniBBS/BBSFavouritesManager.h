//
//  BBSFavouritesManager.h
//  UniBBS
//
//  Created by Meng Shengbin on 3/31/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBSFavouritesManager : NSObject
+ (void) loadData;
+ (NSMutableArray*) favouriteBoards;
+ (NSMutableArray*) favouriteTopics;
+ (NSMutableArray*) favouritePosts;

+ (void) saveData;
@end
