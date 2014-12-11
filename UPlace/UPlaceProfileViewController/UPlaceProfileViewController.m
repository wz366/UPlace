//
//  UPlaceProfileViewController.m
//  UPlace
//
//  Copyright (c) 2014 Chenghang Zheng. All rights reserved.
//

#import "UPlaceProfileViewController.h"
#import "RESideMenu.h"
#import "DZNSegmentedControl.h"
#import "UPlaceTableViewCell.h"
#import "UPlaceDataStoreManager.h"
// UIImage from NSData category
#import "UIImage+Utility.h"
#import "SVProgressHUD.h"

#define _bakgroundColor     [UIColor whiteColor]
#define _tintColor          [UIColor colorWithRed:255/255.0 green:184/255.0 blue:41/255.0 alpha:1.0]
#define _hairlineColor      [UIColor lightGrayColor]

@interface UPlaceProfileViewController () <UITableViewDataSource, UITableViewDelegate, DZNSegmentedControlDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet DZNSegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *postsTableView;
// Posts by user
@property (nonatomic, strong) NSMutableArray *arrayOfPostsByUser;
@property (nonatomic, weak) FFUser *user;

@end

@implementation UPlaceProfileViewController

+ (void)load
{
    [[DZNSegmentedControl appearance] setBackgroundColor:_bakgroundColor];
    [[DZNSegmentedControl appearance] setTintColor:_tintColor];
    [[DZNSegmentedControl appearance] setHairlineColor:_hairlineColor];
    
    [[DZNSegmentedControl appearance] setFont:[UIFont systemFontOfSize:17.0]];
    [[DZNSegmentedControl appearance] setSelectionIndicatorHeight:2.5];
    [[DZNSegmentedControl appearance] setAnimationDuration:0.20];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2;
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.layer.borderWidth = 2;
    self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    NSArray *menuItems = @[[@"Posts" uppercaseString], [@"Info" uppercaseString]];
    self.segmentedControl.items = menuItems;
    self.segmentedControl.delegate = self;
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.showsCount = NO;
    self.segmentedControl.height = 45;
    
    // Configure table view
    _postsTableView.dataSource = self;
    _postsTableView.delegate = self;
    [_postsTableView registerNib:[UINib nibWithNibName:@"UPlaceTableViewCell" bundle:nil] forCellReuseIdentifier:@"CellIdentifier"];
    _postsTableView.rowHeight = UITableViewAutomaticDimension;
    _postsTableView.estimatedRowHeight = 125.0;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    // Load posts
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:0.980f green:0.980f blue:0.980f alpha:1.00f]];
    [SVProgressHUD setForegroundColor:_tintColor];
    [SVProgressHUD showWithStatus:@"Getting Posts"];
    [self reloadTableViewDataWithUser:(id)[[FatFractal main] loggedInUser]];
    [SVProgressHUD dismiss];
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

#pragma mark - Button actions

- (IBAction)menu:(id)sender {
    [self.sideMenuViewController presentLeftMenuViewController];
}

#pragma mark - UIBarPositioningDelegate Methods

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)view
{
    return UIBarPositionBottom;
}

#pragma mark - TableView delegate and datasource

- (void)deletePostFromArray:(UPlacePost *)post
{
    [self.arrayOfPostsByUser removeObject:post];
    [self.postsTableView reloadData];
}

- (void)reloadTableViewDataWithUser:(FFUser *)user
{
    // Check if location is nil
    if (user == nil) {
        NSLog(@"No user information to obtain Posts");
        return;
    }
    // Array of Posts lazy init
    if (!_arrayOfPostsByUser) {
        _arrayOfPostsByUser = [[NSMutableArray alloc] init];
        _arrayOfPostsByUser = [[UPlaceDataStoreManager sharedDataStoreManager] allPostsCreatedByUser:user];
    
        if (_arrayOfPostsByUser.count > 0) {
            NSLog(@"Got user posts");
        }else{
            NSLog(@"Did not get user posts");
        }
    }
    [_postsTableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrayOfPostsByUser.count;
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
    UPlacePost *postByUser = _arrayOfPostsByUser[indexPath.row];
    
    cell.messageLabel.text = postByUser.message;
    cell.placeNameLabel.text = postByUser.placeName;
    cell.userNameLabel.text = @"Walter White";
    //cell.userNameLabel.text = _user.userName;
    cell.postBeingViewed = postByUser;
    
    // Add image views to the cell
    __weak UPlaceTableViewCell *weakTarget = cell;
    CGRect labelRect = [postByUser.message
                        boundingRectWithSize:CGSizeMake(286, 0)
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{
                                     NSFontAttributeName : [UIFont systemFontOfSize:15]
                                     }
                        context:nil];
    
    if (postByUser.media.image1) {
        UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(70, 55+labelRect.size.height, 65, 65)];
        imageView1.image = [UIImage fastImageWithData: postByUser.media.image1];
        imageView1.userInteractionEnabled = YES;
        imageView1.contentMode = UIViewContentModeScaleToFill;
        imageView1.tag = 1;
        [imageView1 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:weakTarget action:@selector(imageTapped:)]];
        [cell.contentView addSubview:imageView1];
        cell.imageViews = [[NSMutableArray alloc] initWithObjects:imageView1, nil];
        
        if (postByUser.media.image2) {
            UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(140, 55+labelRect.size.height, 65, 65)];
            imageView2.image = [UIImage fastImageWithData: postByUser.media.image2];
            imageView2.userInteractionEnabled = YES;
            imageView2.contentMode = UIViewContentModeScaleToFill;
            imageView2.tag = 2;
            [imageView2 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:weakTarget action:@selector(imageTapped:)]];
            [cell.contentView addSubview:imageView2];
            [cell.imageViews addObject:imageView2];
            
            if (postByUser.media.image3) {
                UIImageView *imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(210, 55+labelRect.size.height, 65, 65)];
                imageView3.image = [UIImage fastImageWithData: postByUser.media.image3];
                imageView3.userInteractionEnabled = YES;
                imageView3.contentMode = UIViewContentModeScaleToFill;
                imageView3.tag = 3;
                [imageView3 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:weakTarget action:@selector(imageTapped:)]];
                [cell.contentView addSubview:imageView3];
                [cell.imageViews addObject:imageView3];
                
                if (postByUser.media.image4) {
                    UIImageView *imageView4 = [[UIImageView alloc] initWithFrame:CGRectMake(280, 55+labelRect.size.height, 65, 65)];
                    imageView4.image = [UIImage fastImageWithData: postByUser.media.image4];
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
    
    // Show delete button
    [cell.deleteButton setHidden:NO];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UPlacePost *postByUser = _arrayOfPostsByUser[indexPath.row];
    
    CGRect labelRect = [postByUser.message
                        boundingRectWithSize:CGSizeMake(286, 0)
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{
                                     NSFontAttributeName : [UIFont systemFontOfSize:15]
                                     }
                        context:nil];
    if (postByUser.media.image1) {
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

@end
