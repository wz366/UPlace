//
//  FeedViewController.m
//  UPlace
//
//  Copyright (c) 2014 Chenghang Zheng. All rights reserved.
//

#import "FeedViewController.h"
#import "NewPostViewController.h"
#import "SearchViewController.h"
#import "RESideMenu.h"

// Managers
#import "UPlaceLocationManager.h"
#import "UPlaceDataStoreManager.h"
// Table view cell, header
#import "UPlaceTableViewCell.h"
#import "UPlaceTableViewHeaderView.h"
// UIImage from NSData category
#import "UIImage+Utility.h"

// Google plcaes result items
#import "GOPlace.h"
#import "FTGooglePlacesAPISearchResultItem.h"
#import "FTGooglePlacesAPIDetailResponse.h"

#import "SVProgressHUD.h"
#define _tintColor          [UIColor colorWithRed:255/255.0 green:184/255.0 blue:41/255.0 alpha:1.0]

@interface FeedViewController () <UITableViewDataSource, UITableViewDelegate, UPlaceLocationManagerDelegate>


@property (weak, nonatomic) IBOutlet UITableView *feedTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

// Posts at locatoin
@property (nonatomic, strong) NSMutableArray *arrayOfPostsAtLocation;

// Current user location information
@property (nonatomic, strong) CLLocation *currentUserLocation;
@property (nonatomic, strong) NSString *currentUserLocatinPlaceName;
@property (nonatomic, strong) NSString *currentUserLocatinAddress;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // Configure table view
    _feedTableView.dataSource = self;
    _feedTableView.delegate = self;
    [_feedTableView registerNib:[UINib nibWithNibName:@"UPlaceTableViewCell" bundle:nil] forCellReuseIdentifier:@"CellIdentifier"];
    _feedTableView.rowHeight = UITableViewAutomaticDimension;
    _feedTableView.estimatedRowHeight = 125.0;
    
    // Location Manager Delegate
    [[UPlaceLocationManager sharedLocationManager] startUpdatingUserLocation];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UPlaceLocationManager sharedLocationManager] setDelegateNotSafe:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Location Manager Configuration
    [[UPlaceLocationManager sharedLocationManager] setDelegate:self];
    [[UPlaceLocationManager sharedLocationManager] setDelegateNotSafe:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)unselectSegmentedControl
{
    // Neither nearby nor following should be selected
    [_segmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
}

#pragma mark - UITableView

- (void)addPostToArray:(UPlacePost *)post
{
    [self.arrayOfPostsAtLocation insertObject:post atIndex:0];
    [self.feedTableView reloadData];
}

- (void)reloadTableViewDataWithLocatin:(CLLocation *)location
{
    // Check if location is nil
    if (location == nil) {
        NSLog(@"No location to obtain Posts");
        return;
    }
    // Array of Posts lazy init
    if (!_arrayOfPostsAtLocation) {
        _arrayOfPostsAtLocation = [[NSMutableArray alloc] init];
    }
    
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:0.980f green:0.980f blue:0.980f alpha:1.00f]];
    [SVProgressHUD setForegroundColor:_tintColor];
    [SVProgressHUD showWithStatus:@"Getting Posts"];
    _arrayOfPostsAtLocation = [[UPlaceDataStoreManager sharedDataStoreManager] allPostsNearLocation:location];
    [SVProgressHUD dismiss];
    
    if (self.arrayOfPostsAtLocation.count > 0) {
        NSLog(@"Got posts");
    }else{
        NSLog(@"Did not get posts");
    }
    
    [_feedTableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrayOfPostsAtLocation.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UPlaceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
    // Clear old properties in reused cells
    cell.imageViews = nil;
    cell.postBeingViewed = nil;
    cell.messageLabel.text = nil;
    cell.placeNameLabel.text = nil;
    cell.userNameLabel.text = nil;
    [[cell.contentView viewWithTag:1] removeFromSuperview];
    [[cell.contentView viewWithTag:2] removeFromSuperview];
    [[cell.contentView viewWithTag:3] removeFromSuperview];
    [[cell.contentView viewWithTag:4] removeFromSuperview];
    
    // Get Post information to cell
    UPlacePost *postAtLocation = _arrayOfPostsAtLocation[indexPath.row];
    //FFUser *postOwner = postAtLocation.user;

    cell.messageLabel.text = postAtLocation.message;
    cell.placeNameLabel.text = postAtLocation.placeName;
    cell.userNameLabel.text = @"Walter White";
    //cell.userNameLabel.text = postOwner.userName;
    cell.postBeingViewed = postAtLocation;
  
    // Add image views to the cell
    __weak UPlaceTableViewCell *weakTarget = cell;
    CGRect labelRect = [postAtLocation.message
                        boundingRectWithSize:CGSizeMake(286, 0)
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{
                                     NSFontAttributeName : [UIFont systemFontOfSize:15]
                                     }
                        context:nil];
    
    if (postAtLocation.media.image1) {
        UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(70, 55+labelRect.size.height, 65, 65)];
        imageView1.image = [UIImage fastImageWithData: postAtLocation.media.image1];
        imageView1.userInteractionEnabled = YES;
        imageView1.contentMode = UIViewContentModeScaleToFill;
        imageView1.tag = 1;
        [imageView1 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:weakTarget action:@selector(imageTapped:)]];
        [cell.contentView addSubview:imageView1];
        cell.imageViews = [[NSMutableArray alloc] initWithObjects:imageView1, nil];
        
        if (postAtLocation.media.image2) {
            UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(140, 55+labelRect.size.height, 65, 65)];
            imageView2.image = [UIImage fastImageWithData: postAtLocation.media.image2];
            imageView2.userInteractionEnabled = YES;
            imageView2.contentMode = UIViewContentModeScaleToFill;
            imageView2.tag = 2;
            [imageView2 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:weakTarget action:@selector(imageTapped:)]];
            [cell.contentView addSubview:imageView2];
            [cell.imageViews addObject:imageView2];
            
            if (postAtLocation.media.image3) {
                UIImageView *imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(210, 55+labelRect.size.height, 65, 65)];
                imageView3.image = [UIImage fastImageWithData: postAtLocation.media.image3];
                imageView3.userInteractionEnabled = YES;
                imageView3.contentMode = UIViewContentModeScaleToFill;
                imageView3.tag = 3;
                [imageView3 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:weakTarget action:@selector(imageTapped:)]];
                [cell.contentView addSubview:imageView3];
                [cell.imageViews addObject:imageView3];
                
                if (postAtLocation.media.image4) {
                    UIImageView *imageView4 = [[UIImageView alloc] initWithFrame:CGRectMake(280, 55+labelRect.size.height, 65, 65)];
                    imageView4.image = [UIImage fastImageWithData: postAtLocation.media.image4];
                    imageView4.userInteractionEnabled = YES;
                    imageView4.contentMode = UIViewContentModeScaleToFill;
                    imageView4.tag = 4;
                    [imageView4 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:weakTarget action:@selector(imageTapped:)]];
                    [cell.contentView addSubview:imageView4];
                    [cell.imageViews addObject:imageView4];
                }
            }
        }
    }

    
    // Try to improve performance
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    // Set background color when selected
    UIView *myBackView = [[UIView alloc] initWithFrame:cell.frame];
    myBackView.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = myBackView;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UPlacePost *postAtLocation = _arrayOfPostsAtLocation[indexPath.row];
    
    CGRect labelRect = [postAtLocation.message
                        boundingRectWithSize:CGSizeMake(286, 0)
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{
                                     NSFontAttributeName : [UIFont systemFontOfSize:15]
                                     }
                        context:nil];
    if (postAtLocation.media.image1) {
        return 80.0 + 70 + labelRect.size.height;
    }else{
        return 80.0 + labelRect.size.height;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Display post detail view
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    return;
}

#pragma mark - UPlaceLocationManager Delegate

- (void)locationManager:(UPlaceLocationManager *)sharedLocationManager didUpdatetoLocation:(CLLocation *)location;
{
    // Reload data if and only if Nearby is selected
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self reloadTableViewDataWithLocatin:location];
    }
    
    // Update current user location and place name
    _currentUserLocation = location;
    [[UPlaceLocationManager sharedLocationManager] requestPlaceFromLocation:location];
}

- (void)locationManager:(UPlaceLocationManager *)sharedLocationManager didFindPlaceFromLocation:(FTGooglePlacesAPISearchResultItem *)place;
{
    _currentUserLocatinPlaceName = place.name;
    _currentUserLocatinAddress = place.addressString;
}

#pragma mark - Button Actions

- (IBAction)segmentedControlValueChanged:(id)sender {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self reloadTableViewDataWithLocatin:_currentUserLocation];
    }
    
}

- (IBAction)newPost:(id)sender {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        
        NewPostViewController *npvc = [[NewPostViewController alloc] initWithPostLocation:_currentUserLocation placeName:_currentUserLocatinPlaceName address:_currentUserLocatinAddress];
        [self presentViewController:npvc animated:YES completion:nil];
        
    }else{
        
        NewPostViewController *npvc = [[NewPostViewController alloc] initWithPostLocation:_postLocation placeName:_postLocationPlaceName address:_postLocationAddress];
        [self presentViewController:npvc animated:YES completion:nil];

        
    }
}

- (IBAction)searchPlaces:(id)sender {
    SearchViewController *svc = [[SearchViewController alloc] init];
    [self presentViewController:svc animated:YES completion:nil];
}

- (IBAction)showLeftMenu:(id)sender {
    [self.sideMenuViewController presentLeftMenuViewController];
}

@end
