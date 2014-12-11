//
//  HGPhotoWall.h
//  PhotoDemo
//
//  Created by Harry on 12-12-6.
//  Copyright (c) 2012年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HGPhotoWallDelegate <NSObject>

- (void)photoWallPhotoTaped:(NSUInteger)index;
- (void)photoWallMovePhotoFromIndex:(NSInteger)index toIndex:(NSInteger)newIndex;
- (void)photoWallAddAction;
- (void)photoWallAddFinish;
- (void)photoWallDeleteFinishAtIndex:(NSInteger)index;

@end

@interface HGPhotoWall : UIView

@property (weak, nonatomic) id<HGPhotoWallDelegate> delegate;

- (void)setPhotos:(NSArray *)photos;
- (NSArray *)getPhotos;
- (void)setEditModel:(BOOL)canEdit;
- (void)addPhoto:(NSData *)photoData;
- (void)deletePhotoByIndex:(NSUInteger)index;

@end