//
//  UPlaceDataStoreManager.m
//  UPlace
//
//  Copyright (c) 2014 Chenghang Zheng. All rights reserved.
//

#import "UPlaceDataStoreManager.h"

@interface UPlaceDataStoreManager ()
@property (nonatomic, strong) NSArray *privatePostsCreatedByUser;
@property (nonatomic, strong) NSArray *privatePostsNearLocation;
@end

@implementation UPlaceDataStoreManager

#pragma mark - Singleton
+ (instancetype) sharedDataStoreManager
{
    static UPlaceDataStoreManager *sharedDataStoreManager = nil;
    // Thread safe
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDataStoreManager = [[self alloc] initPrivate];
    });
    
    return sharedDataStoreManager;
}

#pragma mark - Initializers

- (instancetype) initPrivate
{
    if (self = [super init]){
    }
    return self;
}

- (instancetype) init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[UPlaceDataStoreManager sharedDataStoreManager]" userInfo:nil];
    return nil;
}

#pragma mark - Create Posts

- (double)dateToDouble: (NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd.HHmm"];
    // For time zone converstion
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"US/Central"]];
    
    NSString *stringFromDate = [dateFormatter stringFromDate:date];
    double doubleDate = [stringFromDate doubleValue];
    
    //NSLog(@"%@, %f",stringFromDate,doubleDate); // Test double date value
    
    return doubleDate;
}

- (UPlacePost *)creatPostWithMessage:(NSString *)message Images:(NSArray *)imageArray Location:(CLLocation *)location Address:(NSString *)address PlaceName:(NSString *)placeName
{
    NSError *error = nil;
    UPlacePost *myPost = [[UPlacePost alloc] init];

    if ([[FatFractal main] loggedInUser]) {
        if (imageArray.count > 0) {
            UPlacePostMedia *media = [[UPlacePostMedia alloc] init];
            media.image1 = imageArray[0];
            
            if (imageArray.count > 1) {
                media.image2 = imageArray[1];
                if (imageArray.count > 2) {
                    media.image3 = imageArray[2];
                    if (imageArray.count > 3) {
                        media.image4 = imageArray[3];
                    }
                }
            }
            
            myPost.message = message;
            myPost.address = address;
            myPost.placeName = placeName;
            myPost.media = media;
            myPost.locationCreated = [[FFGeoLocation alloc] initWithCLLocation:location];
            myPost.user = (id)[[FatFractal main] loggedInUser];
            myPost.dateCreated = [self dateToDouble:[NSDate date]];
            
            [[FatFractal main] createObj:media atUri:@"/UPlacePostMedia" error:&error];
            myPost = [[FatFractal main] createObj:myPost atUri:@"/UPlacePost" error:&error];
        }
        else
        {
            myPost.message = message;
            myPost.address = address;
            myPost.placeName = placeName;
            myPost.media = nil;
            myPost.locationCreated = [[FFGeoLocation alloc] initWithCLLocation:location];
            myPost.user = (id)[[FatFractal main] loggedInUser];
            myPost.dateCreated = [self dateToDouble:[NSDate date]];
            myPost = [[FatFractal main] createObj:myPost atUri:@"/UPlacePost" error:&error];
        }
    }
    
    if (error) {
        myPost = nil;
        NSLog(@"sharedDataStoreManager failed to create a new post");
    }
    
    return myPost;
}

#pragma mark - Get Posts

- (NSArray *)allPostsNearLocation:(CLLocation *)location
{
    NSString * queryString = [NSString stringWithFormat:@"/UPlacePost/(distance(locationCreated, [%f, %f, %f]) lte 100)?sort=distance(locationCreated, [%f, %f, %f]) asc, dateCreated desc",
                              location.coordinate.latitude, location.coordinate.longitude, location.altitude, location.coordinate.latitude, location.coordinate.longitude, location.altitude];
    NSError *err = nil;
    self.privatePostsNearLocation = [[FatFractal main] getArrayFromUri:queryString error:&err];
    if (err) {
        NSLog(@"%@",[err description]);
    }
    return self.privatePostsNearLocation;
}

// Do not need this anymore thanks to good queries :)
- (NSArray *)sortPostsByDateCreated: (NSArray *)PostsArray
{
    NSString * DATECREATED = @"dateCreated";
    NSSortDescriptor *dateCreatedDescriptor = [[NSSortDescriptor alloc] initWithKey:DATECREATED ascending:NO];
    
    NSArray * descriptors = [NSArray arrayWithObjects:dateCreatedDescriptor, nil];
    NSArray * sortedPostsArray = [PostsArray sortedArrayUsingDescriptors:descriptors];
    
    return sortedPostsArray;
}

- (NSArray *)allPostsCreatedByUser:(FFUser *)user
{
    NSString * queryString = [NSString stringWithFormat:@"/FFUser/(guid eq '%@')/ReferencedBy/(type eq 'post')?sort=dateCreated desc", user.guid];
    NSError *err = nil;
    self.privatePostsCreatedByUser = [[FatFractal main] getArrayFromUri:queryString error:&err];
    if (err) {
        NSLog(@"%@",[err description]);
    }
    return self.privatePostsCreatedByUser;
}

#pragma mark - Others

- (BOOL)removePost:(UPlacePost *)post
{
    BOOL result = NO;
    NSError *err = nil;
    [[FatFractal main] deleteObj:post.media error:&err];
    [[FatFractal main] deleteObj:post error:&err];
    if (!err) {
        result = YES;
    }
    return result;
}

@end
