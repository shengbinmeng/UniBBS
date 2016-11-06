//
//  BBSBoardListExplorer.h
//  UniBBS
//
//  Created by Meng Shengbin on 3/8/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBSBoardListExplorer : NSObject

- (id)initWithURI:(NSString *)uri;
- (NSMutableArray*) getBoardList;
- (NSMutableArray*) getWholeBoardList;

@end
