//
//  AppDelegate.m
//  UPlace
//
//  Copyright (c) 2014 Chenghang Zheng. All rights reserved.
//

#import "AppDelegate.h"

#import "RESideMenu.h"
#import "LeftMenuViewController.h"
#import "FeedViewController.h"

//Google Places API
#import "FTGooglePlacesAPI.h"
#import "GOPlaceDetails.h"
#import "GOPlacesAutocomplete.h"

//You should change GoogleAPIKey and FatFractalBaseURL
#define GoogleAPIKey @"Your_Key"
#define FatFractalBaseURL @"http://localhost/my_app"

@interface AppDelegate ()
@end

@implementation AppDelegate

@synthesize ff = _ff;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Init Navigation Controller and set root view to be feed view
    FeedViewController *fvc = [[FeedViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:fvc];
    [nvc setNavigationBarHidden:YES animated:NO];
    
    // Side menu setup
    LeftMenuViewController *lmvc = [[LeftMenuViewController alloc] init];
    RESideMenu *sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:nvc
                                                                    leftMenuViewController:lmvc rightMenuViewController:nil];
    sideMenuViewController.backgroundImage = [UIImage imageNamed:@"MenuBackground.png"];
    sideMenuViewController.menuPreferredStatusBarStyle = 1; // UIStatusBarStyleLightContent
    sideMenuViewController.delegate = nil;
    sideMenuViewController.contentViewShadowColor = [UIColor blackColor];
    sideMenuViewController.contentViewShadowOffset = CGSizeMake(0, 0);
    sideMenuViewController.contentViewShadowOpacity = 0.6;
    sideMenuViewController.contentViewShadowRadius = 12;
    sideMenuViewController.contentViewShadowEnabled = YES;
    
    self.window.rootViewController = sideMenuViewController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // Google Map API Keys
    [FTGooglePlacesAPIService provideAPIKey:GoogleAPIKey];
    [GOPlaceDetails setDefaultGoogleAPIKey:GoogleAPIKey];
    [GOPlacesAutocomplete setDefaultGoogleAPIKey:GoogleAPIKey];
    
    // Optionally enable debug mode
    [FTGooglePlacesAPIService setDebugLoggingEnabled:NO];
    
    // Initialize the FatFractal instance that this application will use
    NSString *baseUrl = FatFractalBaseURL;
    _ff = [[FatFractal alloc] initWithBaseUrl:baseUrl];
    _ff.debug = NO;
    
    // The following is testing code
    NSError *error;
    [_ff loginWithUserName:@"testUser001" andPassword:@"testUser001" error:&error];
    if (!error) {
        NSLog(@"testUser001 Logged In!");
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
