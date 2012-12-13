//
//  BNRLoupe.h
//  LoupeDemo
//
//  Created by Owen Mathews on 12/12/12.
//  Copyright (c) 2012 Owen Mathews. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BNRLoupe : NSObject

@property (nonatomic, weak) UIImage *image;
@property (nonatomic) CGRect constraintsRect;
@property (nonatomic) CGFloat offset;
@property (nonatomic) CGFloat offsetAngle;
@property (nonatomic) CGAffineTransform screenToImageTransform;

- (id)initWithDiameter:(CGFloat)diameter offset:(CGFloat)offset offsetAngle:(CGFloat)angle constraintsRect:(CGRect)rect edgeClearance:(CGFloat)clearance;

- (void)displayInView:(UIView *)view;

- (void)removeFromView;

- (void)setScreenPoint:(CGPoint)point;

@end
