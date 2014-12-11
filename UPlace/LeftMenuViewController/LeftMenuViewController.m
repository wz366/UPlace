//
//  LeftMenuViewController.m
//  UPlace
//
//  Copyright (c) 2014 Chenghang Zheng. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "RESideMenu.h"

#import "UPlaceProfileViewController.h"
#import "FeedViewController.h"
#import "NotificationViewController.h"
#import "SettingsViewController.h"

#import "UPlaceLocationManager.h"

@interface LeftMenuViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@end

@implementation LeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor clearColor];
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2;
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.layer.borderWidth = 2;
    self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    

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

- (IBAction)profile:(id)sender {
    UPlaceProfileViewController *pvc = [[UPlaceProfileViewController alloc] init];
    [self.sideMenuViewController setContentViewController:pvc animated:YES];
    [self.sideMenuViewController hideMenuViewController];
}

- (IBAction)feed:(id)sender {
    FeedViewController *fvc = [[FeedViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:fvc];
    [nvc setNavigationBarHidden:YES animated:NO];
    [self.sideMenuViewController setContentViewController:nvc animated:YES];
    [self.sideMenuViewController hideMenuViewController];
    [fvc reloadTableViewDataWithLocatin:[[UPlaceLocationManager sharedLocationManager] currentLocation]];
}

- (IBAction)notifications:(id)sender {
    NotificationViewController *nvc = [[NotificationViewController alloc] init];
    [self.sideMenuViewController setContentViewController:nvc animated:YES];
    [self.sideMenuViewController hideMenuViewController];
}

- (IBAction)settings:(id)sender {
    SettingsViewController *svc = [[SettingsViewController alloc] init];
    [self.sideMenuViewController setContentViewController:svc animated:YES];
    [self.sideMenuViewController hideMenuViewController];
}

@end
