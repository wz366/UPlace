//
//  AppDelegate.h
//  UPlace
//
//  Copyright (c) 2014 Chenghang Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

// FatFractal BaaS library
#import <FFEF/FatFractal.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// FatFractal BaaS
@property (strong, nonatomic) FatFractal *ff;

@end

