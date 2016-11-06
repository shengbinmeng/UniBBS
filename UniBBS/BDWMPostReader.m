//
//  BDWMPostReader.m
//  UniBBS
//
//  Created by Shengbin Meng on 06/11/2016.
//  Copyright © 2016 Peking University. All rights reserved.
//

#import "BDWMPostReader.h"

@implementation BDWMPostReader

- (id)initWithURI:(NSString *)uri
{
    // TODO: Override to implement with new API.
    return [super initWithURI:uri];
}

- (NSDictionary*) getPostAttributes
{
    // TODO: Override to implement with new API.
    return [super getPostAttributes];
}

- (NSDictionary*) getNextPost
{
    // TODO: Override to implement with new API.
    return [super getNextPost];
}

- (NSDictionary*) getPreviousPost
{
    // TODO: Override to implement with new API.
    return [super getPreviousPost];
}

- (NSString*) getSameTopicUri
{
    // TODO: Override to implement with new API.
    return [super getSameTopicUri];
}

@end
