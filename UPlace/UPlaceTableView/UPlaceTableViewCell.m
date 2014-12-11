//
//  UPlaceTableViewCell.m
//  UPlace
//
//  Copyright (c) 2014 Chenghang Zheng. All rights reserved.
//

#import "UPlaceTableViewCell.h"
#import "UPlaceDataStoreManager.h"
#import "UPlaceProfileViewController.h"
#import "RESideMenu.h"
#import "SVProgressHUD.h"

@implementation UPlaceTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)deletePost:(id)sender {
    if (!self.postBeingViewed) {
        NSLog(@"No post being viewed in this cell");
        return;
    }
    
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:0.980f green:0.980f blue:0.980f alpha:1.00f]];
    [SVProgressHUD setForegroundColor:[UIColor colorWithRed:255/255.0 green:184/255.0 blue:41/255.0 alpha:1.0]];
    [SVProgressHUD showWithStatus:@"Deleting Post"];
    BOOL result = [[UPlaceDataStoreManager sharedDataStoreManager] removePost:_postBeingViewed];
    
    if (result) {
        [SVProgressHUD showSuccessWithStatus:@"Post Deleted"];
        // Access tableview to reload data
        UPlaceProfileViewController *pvc = (UPlaceProfileViewController *)[(RESideMenu *)self.window.rootViewController contentViewController] ;
        [pvc deletePostFromArray:_postBeingViewed];
    } else {
        [SVProgressHUD showErrorWithStatus:@"Error Occurred"];
    }
}

#pragma mark - Tap pic in cell
- (void)imageTapped:(UITapGestureRecognizer *)tap;
{
    XHImageViewer *imageViewer = [[XHImageViewer alloc] init];
    imageViewer.delegate = self;
    [imageViewer showWithImageViews:_imageViews selectedView:(UIImageView *)tap.view];
}

#pragma mark - XHImageViewerDelegate

- (void)imageViewer:(XHImageViewer *)imageViewer willDismissWithSelectedView:(UIImageView *)selectedView {
    //NSInteger index = [_imageViews indexOfObject:selectedView];
    //NSLog(@"index : %ld", index);
}

@end
