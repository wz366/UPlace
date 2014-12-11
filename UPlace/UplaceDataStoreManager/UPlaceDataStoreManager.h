//
//  UPlaceDataStoreManager.h
//  UPlace
//
//  Copyright (c) 2014 Chenghang Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
// FatFractal BaaS library
#import <FFEF/FatFractal.h>
// Model
#import "UPlacePost.h"


@interface UPlaceDataStoreManager : NSObject

+(instancetype) sharedDataStoreManager;

-(UPlacePost *) creatPostWithMessage: (NSString *)message
                         Images: (NSArray *)imageArray
                       Location: (CLLocation *)location
                        Address: (NSString *)address
                      PlaceName: (NSString *)placeName;

-(BOOL) removePost: (UPlacePost *)post;

-(NSArray *) allPostsCreatedByUser: (FFUser *)user;
-(NSArray *) allPostsNearLocation: (CLLocation *)location;

@end
