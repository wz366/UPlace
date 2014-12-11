//
//  FeedViewController.h
//  UPlace
//
//  Copyright (c) 2014 Chenghang Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class UPlacePost;

@interface FeedViewController : UIViewController

@property (nonatomic, strong) CLLocation *postLocation;
@property (nonatomic, strong) NSString *postLocationPlaceName;
@property (nonatomic, strong) NSString *postLocationAddress;

- (void)reloadTableViewDataWithLocatin:(CLLocation *)location;
- (void)addPostToArray:(UPlacePost *)post;

- (void)unselectSegmentedControl;

@end