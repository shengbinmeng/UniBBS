//
//  BBSBoardListExplorer.h
//  UniBBS
//
//  Created by Meng Shengbin on 3/8/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBSBoardListExplorer : NSObject

@property (nonatomic, retain) NSString *dataAddress;

- (id)initWithAddress:(NSString *)address;

- (NSMutableArray*) getBoardList;
- (NSMutableArray*) getWholeBoardList;

@end
