//
//  NewPostViewController.h
//  UPlace
//
//  Copyright (c) 2014 Chenghang Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface NewPostViewController : UIViewController

// Designated initializer
- (id)initWithPostLocation:(CLLocation *)location placeName:(NSString *)name address:(NSString *)address;

@end
