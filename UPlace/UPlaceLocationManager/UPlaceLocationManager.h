//
//  UPlaceLocationManager.h
//  UPlace
//
//  Copyright (c) 2014 Chenghang Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class GOPlace;
@class UPlaceLocationManager;
@class FTGooglePlacesAPISearchResultItem;
@class FTGooglePlacesAPIDetailResponse;

@protocol UPlaceLocationManagerDelegate <NSObject>
@optional
- (void)locationManager:(UPlaceLocationManager *)sharedLocationManager didUpdatetoLocation:(CLLocation *)location;

- (void)locationManager:(UPlaceLocationManager *)sharedLocationManager didFindPlacesFromSearch:(NSArray *)locations;

- (void)locationManager:(UPlaceLocationManager *)sharedLocationManager didFindDetailsFromLocation:(FTGooglePlacesAPIDetailResponse *)detailedLocation;

- (void)locationManager:(UPlaceLocationManager *)sharedLocationManager didFindPlaceFromLocation:(FTGooglePlacesAPISearchResultItem *)place;
@end



@interface UPlaceLocationManager : NSObject

@property (assign, nonatomic) id<UPlaceLocationManagerDelegate> delegate;
@property (strong, nonatomic) CLLocation *currentLocation;

@property (nonatomic) BOOL delegateNotSafe;

+(instancetype) sharedLocationManager;

// IMPORTANT TO CALL
-(void) startUpdatingUserLocation;

-(void) requestPlaceFromLocation:(CLLocation *)location;
-(void) searchForPlacesFromKeyword:(NSString *)keyword;
-(void) getDetailsFromLocation:(NSString *)placeId;

@end