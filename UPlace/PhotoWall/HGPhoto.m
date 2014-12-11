//
//  Photo.m
//  PhotoDemo
//
//  Created by Harry on 12-12-6.
//  Copyright (c) 2012年 Harry. All rights reserved.
//

#import "HGPhoto.h"

#import <QuartzCore/QuartzCore.h>

@interface HGPhoto() <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIView *viewMask;
@property (strong, nonatomic) UIImageView *viewPhoto;

@property (strong, nonatomic) NSString *stringImageUrl;
@property (nonatomic) CGPoint pointOrigin;
@property (nonatomic) BOOL editModel;

@property (nonatomic) PhotoType type;

@end

#define kPhotoSize 65.

@implementation HGPhoto

- (id)initWithOrigin:(CGPoint)origin
{
    self = [super initWithFrame:CGRectMake(origin.x, origin.y, kPhotoSize, kPhotoSize)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.viewPhoto = [[UIImageView alloc] initWithFrame:self.bounds];
        self.viewPhoto.layer.cornerRadius = 3;
        self.viewPhoto.layer.masksToBounds = YES;
        
        self.viewMask = [[UIView alloc] initWithFrame:self.bounds];
        self.viewMask.alpha = 0.5;
        self.viewMask.backgroundColor = [UIColor blackColor];
        self.viewMask.layer.cornerRadius = 3;
        self.viewMask.layer.masksToBounds = YES;
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPress:)];
        
        [self addSubview:self.viewPhoto];
        [self addSubview:self.viewMask];
        [self addGestureRecognizer:tapRecognizer];
        
        self.editModel = NO;
        self.viewMask.hidden = YES;
    }
    return self;
}

- (void)setPhotoType:(PhotoType)type
{
    self.type = type;
    if (type == PhotoTypeAdd) {
        self.viewPhoto.image = [UIImage imageNamed:@"addPhoto"];
    }
}

- (PhotoType)getPhotoType
{
    return self.type;
}

- (void)setPhotoData:(NSData *)photoData
{
    self.viewPhoto.image = [UIImage imageWithData:photoData];
}

- (void)moveToPosition:(CGPoint)point
{
    if (self.type == PhotoTypePhoto) {
        [UIView animateWithDuration:0.5 animations:^{
            self.frame = CGRectMake(point.x, point.y, self.frame.size.width, self.frame.size.height);
        } completion:nil];
    } else {
        self.frame = CGRectMake(point.x, point.y, self.frame.size.width, self.frame.size.height);
    }
}

- (void)setEditModel:(BOOL)edit
{
    if (self.type == PhotoTypePhoto) {
        if (edit) {
            UILongPressGestureRecognizer *longPressreRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
            longPressreRecognizer.delegate = self;
            [self addGestureRecognizer:longPressreRecognizer];
        } else {
            for (UIGestureRecognizer *recognizer in [self gestureRecognizers]) {
                if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
                    [self removeGestureRecognizer:recognizer];
                    break;
                }
            }
        }
    }
}

#pragma mark - UIGestureRecognizer

- (void)tapPress:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(photoTaped:)]) {
        [self.delegate photoTaped:self];
    }
}

- (void)handleLongPress:(id)sender
{
    UILongPressGestureRecognizer *recognizer = sender;
    CGPoint point = [recognizer locationInView:self];
    
    CGFloat diffx = 0.;
    CGFloat diffy = 0.;
    
    if (UIGestureRecognizerStateBegan == recognizer.state) {
        self.viewMask.hidden = NO;
        self.pointOrigin = point;
        [self.superview bringSubviewToFront:self];
    } else if (UIGestureRecognizerStateEnded == recognizer.state) {
        self.viewMask.hidden = YES;
        if ([self.delegate respondsToSelector:@selector(photoMoveFinished:)]) {
            [self.delegate photoMoveFinished:self];
        }
    } else {
        diffx = point.x - self.pointOrigin.x;
        diffy = point.y - self.pointOrigin.y;
    }
    
    CGFloat originx = self.frame.origin.x +diffx;
    CGFloat originy = self.frame.origin.y +diffy;
    
    self.frame = CGRectMake(originx, originy, self.frame.size.width, self.frame.size.height);
}

@end
