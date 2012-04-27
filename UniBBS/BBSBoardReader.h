//
//  BBSBoardReader.h
//  UniBBS
//
//  Created by Meng Shengbin on 3/11/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBSBoardReader : NSObject

@property (nonatomic, retain) NSString *dataAddress;
@property (nonatomic, retain) NSString *boardName;
@property (nonatomic, assign) BOOL showSticky;

- (id)initWithBoardName:(NSString *)name;

- (NSMutableArray*) readBoardTopics;
- (NSMutableArray*) readBoardPosts;
- (NSMutableArray*) readNextPage;
- (NSMutableArray*) readPreviousPage;
- (NSMutableArray*) readFirstPage;
- (NSMutableArray*) readLastPage;
- (NSMutableArray*) readLatestPage;

@end
