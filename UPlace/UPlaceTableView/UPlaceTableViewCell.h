//
//  UPlaceTableViewCell.h
//  UPlace
//
//  Copyright (c) 2014 Chenghang Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
// Model
#import "UPlacePost.h"
// Tap to display image
#import "XHImageViewer.h"

@interface UPlaceTableViewCell : UITableViewCell <XHImageViewerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (weak, nonatomic) UPlacePost *postBeingViewed;
@property (strong, nonatomic) NSMutableArray *imageViews;


- (void)imageTapped:(UITapGestureRecognizer *)tap;


@end
