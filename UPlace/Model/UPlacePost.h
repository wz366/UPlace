//
//  UPlacePost.h
//  UPlace
//
//  Copyright (c) 2014 Chenghang Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
// FatFractal BaaS library
#import <FFEF/FatFractal.h>
// Media object
#import "UPlacePostMedia.h"

@interface UPlacePost : NSObject

@property (nonatomic, strong) NSString *postKey;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *placeName;

@property (nonatomic, strong) UPlacePostMedia *media;
@property (nonatomic, strong) FFGeoLocation *locationCreated;
@property (strong, nonatomic) FFUser *user;

@property (nonatomic) double dateCreated;

@end
