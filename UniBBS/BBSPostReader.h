//
//  BBSPostReader.h
//  UniBBS
//
//  Created by Meng Shengbin on 3/10/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBSPostReader : NSObject

- (id)initWithURI:(NSString *)uri;

- (NSDictionary*) getPostAttributes;

- (NSDictionary*) getNextPost;

- (NSDictionary*) getPreviousPost;

- (NSString*) getSameTopicUri;

@end
