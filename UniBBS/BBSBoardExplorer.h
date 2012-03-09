//
//  BBSBoardExplorer.h
//  UniBBS
//
//  Created by Meng Shengbin on 3/8/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBSBoardExplorer : NSObject

- (id)initWithAddress:(NSString *)address;

- (int) numberOfSubBoards;

- (NSDictionary*) GetSubBoardsAtIndex:(int)index;

- (NSMutableArray*) GetAllSubBoards;

@end
