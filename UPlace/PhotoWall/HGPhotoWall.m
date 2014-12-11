//
//  PhotoWall.m
//  PhotoDemo
//
//  Created by Harry on 12-12-6.
//  Copyright (c) 2012年 Harry. All rights reserved.
//

#import "HGPhotoWall.h"
#import "HGPhoto.h"

@interface HGPhotoWall() <HGPhotoDelegate>

@property (strong, nonatomic) NSArray *positionArray;
@property (strong, nonatomic) NSMutableArray *photoArray;
@property (nonatomic) BOOL isEditModel;

@end

#define kFrameHeight 95.
#define kFrameHeight2x 95.//175.

#define kImagePositionx @"positionx"
#define kImagePositiony @"positiony"

@implementation HGPhotoWall

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 0.0)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.positionArray = [NSArray arrayWithObjects:
                               [NSDictionary dictionaryWithObjectsAndKeys:@"7", kImagePositionx, @"5", kImagePositiony, nil],
                               [NSDictionary dictionaryWithObjectsAndKeys:@"76", kImagePositionx, @"5", kImagePositiony, nil],
                               [NSDictionary dictionaryWithObjectsAndKeys:@"145", kImagePositionx, @"5", kImagePositiony, nil],
                               [NSDictionary dictionaryWithObjectsAndKeys:@"214", kImagePositionx, @"5", kImagePositiony, nil],
                              
                               //[NSDictionary dictionaryWithObjectsAndKeys:@"4", kImagePositionx, @"90", kImagePositiony, nil],
                               //[NSDictionary dictionaryWithObjectsAndKeys:@"83", kImagePositionx, @"90", kImagePositiony, nil],
                               //[NSDictionary dictionaryWithObjectsAndKeys:@"162", kImagePositionx, @"90", kImagePositiony, nil],
                               //[NSDictionary dictionaryWithObjectsAndKeys:@"241", kImagePositionx, @"90", kImagePositiony, nil],
                               [NSDictionary dictionaryWithObjectsAndKeys:@"330", kImagePositionx, @"90", kImagePositiony, nil], nil];
        self.photoArray = [NSMutableArray arrayWithCapacity:1];
        
        //self.labelDescription = [[UILabel alloc] initWithFrame:CGRectMake(10., 0., 300., 18.)];
        //self.labelDescription.backgroundColor = [UIColor clearColor];
        //self.labelDescription.textColor = [UIColor whiteColor];
        //self.labelDescription.font = [UIFont systemFontOfSize:12.];
        //self.labelDescription.textAlignment = NSTextAlignmentLeft;
        
        //[self addSubview:self.labelDescription];
        
    }
    return self;
}

- (void)setPhotos:(NSArray*)photos
{
    [self.photoArray removeAllObjects];
    NSUInteger count = [photos count];
    for (int i=0; i<count; i++) {
        NSDictionary *dictionaryTemp = [self.positionArray objectAtIndex:i];
        CGFloat originx = [[dictionaryTemp objectForKey:kImagePositionx] floatValue];
        CGFloat originy = [[dictionaryTemp objectForKey:kImagePositiony] floatValue];
        HGPhoto *photoTemp = [[HGPhoto alloc] initWithOrigin:CGPointMake(originx, originy)];
        photoTemp.delegate = self;
        [photoTemp setPhotoData:[photos objectAtIndex:i]];
        [self addSubview:photoTemp];
        [self.photoArray addObject:photoTemp];
    }
    
    NSDictionary *dictionaryTemp = [self.positionArray objectAtIndex:count];
    CGFloat originx = [[dictionaryTemp objectForKey:kImagePositionx] floatValue];
    CGFloat originy = [[dictionaryTemp objectForKey:kImagePositiony] floatValue];
    HGPhoto *photoTemp = [[HGPhoto alloc] initWithOrigin:CGPointMake(originx, originy)];
    photoTemp.delegate = self;
    photoTemp.hidden = YES;
    [photoTemp setPhotoType:PhotoTypeAdd];
    [self.photoArray addObject:photoTemp];
    [self addSubview:photoTemp];
    
    CGFloat frameHeight = -1;
    if (count > 4) {
        frameHeight = kFrameHeight2x;
    } else {
        frameHeight = kFrameHeight;
    }
    self.frame = CGRectMake(0., 0., 320., frameHeight);
}

- (void)setEditModel:(BOOL)canEdit
{
    self.isEditModel = canEdit;
    if (self.isEditModel) {
        HGPhoto *viewTemp = [self.photoArray lastObject];
        viewTemp.hidden = NO;
    } else {
        HGPhoto *viewTemp = [self.photoArray lastObject];
        viewTemp.hidden = YES;
    }
    
    NSUInteger count = [self.photoArray count]-1;
    for (int i=0; i<count; i++) {
        HGPhoto *viewTemp = [self.photoArray objectAtIndex:i];
        [viewTemp setEditModel:self.isEditModel];
    }
    [self reloadPhotos:NO];
}

- (void)addPhoto:(NSData *)photoData
{
    NSUInteger index = [self.photoArray count] - 1;
    NSDictionary *dictionaryTemp = [self.positionArray objectAtIndex:index];
    CGFloat originx = [[dictionaryTemp objectForKey:kImagePositionx] floatValue];
    CGFloat originy = [[dictionaryTemp objectForKey:kImagePositiony] floatValue];
    
    HGPhoto *photoTemp = [[HGPhoto alloc] initWithOrigin:CGPointMake(originx, originy)];
    photoTemp.delegate = self;
    [photoTemp setEditModel:YES];
    [photoTemp setPhotoData:photoData];
    
    [self.photoArray insertObject:photoTemp atIndex:index];
    [self addSubview:photoTemp];
    [self reloadPhotos:YES];
}

- (NSArray *)getPhotos
{
    return self.photoArray;
}

- (void)deletePhotoByIndex:(NSUInteger)index
{
    HGPhoto *photoTemp = [self.photoArray objectAtIndex:index];
    [self.photoArray removeObject:photoTemp];
    [photoTemp removeFromSuperview];
    [self reloadPhotos:YES];
    if ([self.delegate respondsToSelector:@selector(photoWallDeleteFinishAtIndex:)]) {
        [self.delegate photoWallDeleteFinishAtIndex:index];
    }
}

#pragma mark - Photo

- (void)photoTaped:(HGPhoto*)photo
{
    NSUInteger type = [photo getPhotoType];
    if (type == PhotoTypeAdd) {
        if ([self.delegate respondsToSelector:@selector(photoWallAddAction)]) {
            [self.delegate photoWallAddAction];
        }
    } else if (type == PhotoTypePhoto) {
        NSUInteger index = [self.photoArray indexOfObject:photo];
        if ([self.delegate respondsToSelector:@selector(photoWallPhotoTaped:)]) {
            [self.delegate photoWallPhotoTaped:index];
        }
    }
}

- (void)photoMoveFinished:(HGPhoto*)photo
{
    CGPoint pointPhoto = CGPointMake(photo.frame.origin.x, photo.frame.origin.y);
    CGFloat space = -1;
    NSUInteger oldIndex = [self.photoArray indexOfObject:photo];
    NSUInteger newIndex = -1;
    
    NSUInteger count = [self.photoArray count] - 1;
    for (int i=0; i<count; i++) {
        NSDictionary *dictionaryTemp = [self.positionArray objectAtIndex:i];
        CGFloat originx = [[dictionaryTemp objectForKey:kImagePositionx] floatValue];
        CGFloat originy = [[dictionaryTemp objectForKey:kImagePositiony] floatValue];
        CGPoint pointTemp = CGPointMake(originx, originy);
        CGFloat spaceTemp = [self spaceToPoint:pointPhoto FromPoint:pointTemp];
        if (space < 0) {
            space = spaceTemp;
            newIndex = i;
        } else {
            if (spaceTemp < space) {
                space = spaceTemp;
                newIndex = i;
            }
        }
    }
    
    [self.photoArray removeObject:photo];
    [self.photoArray insertObject:photo atIndex:newIndex];
    
    [self reloadPhotos:NO];
    
    if ([self.delegate respondsToSelector:@selector(photoWallMovePhotoFromIndex:toIndex:)]) {
        [self.delegate photoWallMovePhotoFromIndex:oldIndex toIndex:newIndex];
    }
}

- (void)reloadPhotos:(BOOL)add
{
    NSUInteger count = -1;
    if (add) {
        count = [self.photoArray count];
    } else {
        count = [self.photoArray count] - 1;
    }
    for (int i=0; i<count; i++) {
        NSDictionary *dictionaryTemp = [self.positionArray objectAtIndex:i];
        CGFloat originx = [[dictionaryTemp objectForKey:kImagePositionx] floatValue];
        CGFloat originy = [[dictionaryTemp objectForKey:kImagePositiony] floatValue];
        
        HGPhoto *photoTemp = [self.photoArray objectAtIndex:i];
        [photoTemp moveToPosition:CGPointMake(originx, originy)];
    }
    
    CGFloat frameHeight = -1;
    NSUInteger countPhoto = [self.photoArray count];
    if (self.isEditModel) {
        if (countPhoto > 4) {
            frameHeight = kFrameHeight2x;// + 20.;
        } else {
            frameHeight = kFrameHeight;// + 20.;
        }
        //self.labelDescription.frame = CGRectMake(self.labelDescription.frame.origin.x, frameHeight - 20., self.labelDescription.frame.size.width, self.labelDescription.frame.size.height);
    } else {
        if (countPhoto > 5) {
            frameHeight = kFrameHeight2x;
        } else {
            frameHeight = kFrameHeight;
        }
    }
    self.frame = CGRectMake(0., 0., 320., frameHeight);
}

- (CGFloat)spaceToPoint:(CGPoint)point FromPoint:(CGPoint)otherPoint
{
    float x = point.x - otherPoint.x;
    float y = point.y - otherPoint.y;
    return sqrt(x * x + y * y);
}

@end
