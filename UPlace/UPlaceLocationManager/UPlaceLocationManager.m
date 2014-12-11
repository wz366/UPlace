//
//  UPlaceLocationManager.m
//  UPlace
//
//  Copyright (c) 2014 Chenghang Zheng. All rights reserved.
//

#import "UPlaceLocationManager.h"

// Google places autocomplete wrapper
#import "GOPlace.h"
#import "GOPlacesAutocomplete.h"
#import "FTGooglePlacesAPI.h"

@interface UPlaceLocationManager () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation UPlaceLocationManager
@synthesize delegate;

#pragma mark - Singleton
+ (instancetype) sharedLocationManager
{
    static UPlaceLocationManager *sharedLocationManager = nil;
    // Thread safe
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLocationManager = [[self alloc] initPrivate];
    });
    
    return sharedLocationManager;
}

#pragma mark - Initializers

- (instancetype)initPrivate
{
    if (self = [super init]){
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        _locationManager.distanceFilter = 10.0;
    }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[UPlaceLocationManager sharedLocationManager]" userInfo:nil];
    return nil;
}

#pragma mark - Manage current user location

- (void)startUpdatingUserLocation
{
    [_locationManager startUpdatingLocation];
    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [_locationManager requestAlwaysAuthorization];
    }
    NSLog(@"Started updating user location!");
}

#pragma mark - CLLocaitionManager delegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    _currentLocation = newLocation;
    NSLog(@"Location updated!");
    if (self.delegateNotSafe) {
        return;
    }
    // Call delegate to do stuff (reload data, update map...)
    if([self.delegate respondsToSelector:@selector(locationManager: didUpdatetoLocation:)]) {
        [self.delegate locationManager:self didUpdatetoLocation:newLocation];
    }
    
}

#pragma mark - Google Places place autocomplete

- (void)autocompleteHandler:(NSArray *)places
{
    if (self.delegateNotSafe) {
        return;
    }
    // Call delegate to display search results
    if([self.delegate respondsToSelector:@selector(locationManager: didFindPlacesFromSearch:)]) {
        [self.delegate locationManager:self didFindPlacesFromSearch:places];
    }
}

- (void)searchForPlacesFromKeyword:(NSString *)keyword
{
    // Autocomplete a query
    GOPlacesAutocomplete *autocomplete = [[GOPlacesAutocomplete alloc] init];
    // Limit results to establishments
    [autocomplete setType:@"establishment"];
    __weak UPlaceLocationManager *weakSelf = self;
    [autocomplete requestCompletionForQuery:keyword completionHandler:^(NSArray *places, NSError *error) {
        if (places) {
            [weakSelf autocompleteHandler:places];
        } else {
            NSLog(@"Autocomplete Error => %@", error);
        }
    }];
}

#pragma mark - Google Places place details

- (void)requestDetailsHandler:(FTGooglePlacesAPIDetailResponse *)detailedPlace
{
    if (self.delegateNotSafe) {
        return;
    }
    // Call delegate to do something with a detailed location
    if([self.delegate respondsToSelector:@selector(locationManager: didFindDetailsFromLocation:)]) {
        [self.delegate locationManager:self didFindDetailsFromLocation:detailedPlace];
    }
}

- (void)getDetailsFromLocation:(NSString *)placeId
{
    //  Create detail request
    FTGooglePlacesAPIDetailRequest *request = [[FTGooglePlacesAPIDetailRequest alloc] initWithPlaceId:placeId];
    
    __weak UPlaceLocationManager *weakSelf = self;
    //  Execute Google Places API request using FTGooglePlacesAPIService
    [FTGooglePlacesAPIService executeDetailRequest:request
                             withCompletionHandler:^(FTGooglePlacesAPIDetailResponse *response, NSError *error)
     {
         //  If error is not nil, request failed and you should handle the error
         //  We just show alert
         if (error)
         {
             //  There may be a lot of causes for an error (for example networking error).
             //  If the network communication with Google Places API was successfull,
             //  but the API returned some status code, NSError will have
             //  FTGooglePlacesAPIErrorDomain domain and status code from
             //  FTGooglePlacesAPIResponseStatus enum
             //  You can inspect error's domain and status code for more detailed info
             
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription] message:[error localizedFailureReason] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];
             return;
         }
         //  Everything went fine, we have response object
         //  You can do whatever you need here, we just construct "table representation"
         //  of response to the dictionary and reload table
         [weakSelf requestDetailsHandler:response];
     }];
}

#pragma mark - Google Places place search

- (void)requestPlaceHandler:(NSArray *)locationResults
{
    if (self.delegateNotSafe) {
        return;
    }
    if([self.delegate respondsToSelector:@selector(locationManager: didFindPlaceFromLocation: )]) {
        [self.delegate locationManager:self didFindPlaceFromLocation:[locationResults firstObject]];
    }
    
}

- (void)requestPlaceFromLocation:(CLLocation *)location;
{
    FTGooglePlacesAPINearbySearchRequest *request = [[FTGooglePlacesAPINearbySearchRequest alloc] initWithLocationCoordinate:location.coordinate];
    request.types = @[@"establishment", @"neighborhood", @"route", @"political"];
    request.rankBy = FTGooglePlacesAPIRequestParamRankByDistance;
    
    __weak UPlaceLocationManager *weakSelf = self;
    //  Execute Google Places API request using FTGooglePlacesAPIService
    [FTGooglePlacesAPIService executeSearchRequest:request
                             withCompletionHandler:^(FTGooglePlacesAPISearchResponse *response, NSError *error)
     {
         //  If error is not nil, request failed and you should handle the error
         //  We just show alert
         if (error)
         {
             //  There may be a lot of causes for an error (for example networking error).
             //  If the network communication with Google Places API was successfull,
             //  but the API returned some status code, NSError will have
             //  FTGooglePlacesAPIErrorDomain domain and status code from
             //  FTGooglePlacesAPIResponseStatus enum
             //  You can inspect error's domain and status code for more detailed info
             
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription] message:[error localizedFailureReason] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];
             return;
         }
         
         //  Everything went fine, we have response object
         NSMutableArray *results = [NSMutableArray arrayWithArray:response.results];
         [weakSelf requestPlaceHandler:results];
     }];
    
}


@end
