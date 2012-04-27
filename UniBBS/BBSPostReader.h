//
//  BBSPostReader.h
//  UniBBS
//
//  Created by Meng Shengbin on 3/10/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBSPostReader : NSObject

@property (nonatomic, retain) NSString *dataAddress;

- (id)initWithAddress:(NSString *)address;

- (NSDictionary*) getPostAttributes;

@end
