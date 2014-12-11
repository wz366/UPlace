//
//  Photo.h
//  PhotoDemo
//
//  Created by Harry on 12-12-6.
//  Copyright (c) 2012年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HGPhoto;

@protocol HGPhotoDelegate <NSObject>

@optional
- (void)photoTaped:(HGPhoto*)photo;
- (void)photoMoveFinished:(HGPhoto*)photo;

@end

typedef NS_ENUM(NSInteger, PhotoType) {
    PhotoTypePhoto  = 0, //Default
    PhotoTypeAdd = 1,
};

@interface HGPhoto : UIView

@property (assign) id<HGPhotoDelegate> delegate;

- (id)initWithOrigin:(CGPoint)origin;

- (void)setPhotoType:(PhotoType)type;
- (PhotoType)getPhotoType;
- (void)setPhotoData:(NSData *)photoData;
- (void)moveToPosition:(CGPoint)point;
- (void)setEditModel:(BOOL)edit;

@end
