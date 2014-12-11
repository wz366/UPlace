//
//  UPlacePost.m
//  UPlace
//
//  Copyright (c) 2014 Chenghang Zheng. All rights reserved.
//

#import "UPlacePost.h"

@implementation UPlacePost

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSUUID *uuid = [[NSUUID alloc] init];
        _postKey = [uuid UUIDString];
        _type = @"post";
    }
    return self;
}

@end