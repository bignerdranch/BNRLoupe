//
//  BNRLoupe.m
//  LoupeDemo
//
//  Created by Owen Mathews on 12/12/12.
//  Copyright (c) 2012 Owen Mathews. All rights reserved.
//

#import "BNRLoupe.h"
#import <QuartzCore/QuartzCore.h>

typedef enum {
    Horizontal = 0,
    Vertical
} LoupeConstraintDirection;

typedef enum {
    Greater = 0,
    Less
} LoupeConstraintSense;

typedef LoupeConstraintSense LoupeBias;

typedef struct  {
    CGFloat value;
    LoupeConstraintDirection direction;
    LoupeConstraintSense sense;
} LoupeConstraint;

@interface BNRLoupe () {
    CGPoint _position;
    CGFloat _diameter;
    CGFloat _edgeClearance;
    
    // This is the display angle; the actual offset X and Y
    // values may be different based on device orientation.
    CGFloat _offsetAngle;
    CGFloat _offsetDiagonal;
    CGPoint _offset;
    
    LoupeConstraint constraints[2];
    
    CALayer *_overlayLayer;
    
    BOOL _shouldAnimateAppearance;
    BOOL _appearanceAnimationInProgress;
    CGPoint _savedOriginPoint;
    
    CGPoint _previousScreenPoint;
}

@property (nonatomic, strong) CALayer *contentLayer;

- (void)setContentsCenter:(CGPoint)point screenDistanceTraveled:(CGFloat)distance;

- (BOOL)constrainOffsetFromOriginPoint:(CGPoint)originPoint;

- (void)updateDisplayOffsetAngleForCurrentOrientation;

- (void)updateConstraints;

@end

@implementation BNRLoupe

@synthesize offset=_offsetDiagonal;

- (id)initWithDiameter:(CGFloat)diameter offset:(CGFloat)offset offsetAngle:(CGFloat)angle constraintsRect:(CGRect)rect edgeClearance:(CGFloat)clearance {
    self = [super init];
    if (self) {
        _diameter = diameter;
        _offsetDiagonal = offset;
        _constraintsRect = rect;
        [self setOffsetAngle:angle];
        _edgeClearance = clearance;
        
        _contentLayer = [[CALayer alloc] init];
        _contentLayer.bounds = CGRectMake(0, 0, _diameter, _diameter);
        _contentLayer.cornerRadius = _diameter / 2;
        _contentLayer.shadowOpacity = 0.4;
        _contentLayer.masksToBounds = YES;
        
        _overlayLayer = [[CALayer alloc] init];
        _overlayLayer.bounds = CGRectMake(0, 0, _diameter, _diameter);
        _overlayLayer.contents = (__bridge id) [[UIImage imageNamed:@"loupe"] CGImage];
    }
    return self;
}

- (void)deviceRotated:(NSNotification *)notification {
    [self updateDisplayOffsetAngleForCurrentOrientation];
}

- (void)updateDisplayOffsetAngleForCurrentOrientation {
    [self calculateOrthogonalOffsetsFromDisplayOffsetAngle:_offsetAngle];
    
    // Update constraints
    [self updateConstraints];
}

- (void)setConstraintsRect:(CGRect)constraintsRect {
    _constraintsRect = constraintsRect;
    [self updateConstraints];
}

- (void)updateConstraints {
    constraints[Horizontal].direction = Horizontal;
    constraints[Vertical].direction = Vertical;
    if (_offset.x < 0) {
        constraints[Horizontal].value = _constraintsRect.origin.x;
        constraints[Horizontal].sense = Greater;
    } else {
        constraints[Horizontal].value = _constraintsRect.origin.x + _constraintsRect.size.width;
        constraints[Horizontal].sense = Less;
    }
    if (_offset.y < 0) {
        constraints[Vertical].value = _constraintsRect.origin.y;
        constraints[Vertical].sense = Greater;
    } else {
        constraints[Vertical].value = _constraintsRect.origin.y + _constraintsRect.size.height;
        constraints[Vertical].sense = Less;
    }
}

// Setting the offset angle as it should appear onscreen relative to the touch point.
- (void)setOffsetAngle:(CGFloat)offsetAngle {
    _offsetAngle = offsetAngle;
    [self updateDisplayOffsetAngleForCurrentOrientation];
}

// This is not a public method; the offset angle here is rotated relative to device orientation.
- (void)calculateOrthogonalOffsetsFromDisplayOffsetAngle:(CGFloat)offsetAngle {
    _offset.x = cos(offsetAngle) * _offsetDiagonal;
    _offset.y = -sin(offsetAngle) * _offsetDiagonal;
}

- (void)displayInView:(UIView *)view {
    [view.layer addSublayer:_contentLayer];
    [view.layer addSublayer:_overlayLayer];
    _shouldAnimateAppearance = YES;
}

- (void)animateAppearanceFromOriginPoint:(CGPoint)originPoint {
    _shouldAnimateAppearance = NO;
    _appearanceAnimationInProgress = YES;
    _contentLayer.position = _position;
    _overlayLayer.position = _position;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.16];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    // Position animation
    CABasicAnimation *contentPosition = [CABasicAnimation animationWithKeyPath:@"position"];
    contentPosition.fromValue = [NSValue valueWithCGPoint:originPoint];
    contentPosition.toValue = [NSValue valueWithCGPoint:_position];
    CABasicAnimation *overlayPosition = [CABasicAnimation animationWithKeyPath:@"position"];
    overlayPosition.fromValue = [NSValue valueWithCGPoint:originPoint];
    overlayPosition.toValue = [NSValue valueWithCGPoint:_position];
    
    // Scale animation
    CABasicAnimation *contentScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    contentScale.fromValue = @(0);
    contentScale.toValue = @(1);
    CABasicAnimation *overlayScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    overlayScale.fromValue = @(0);
    overlayScale.toValue = @(1);
    
    // Watch one (any will do) so we can react to the animations completing
    [contentPosition setDelegate:self];
    
    // Apply them
    [_contentLayer addAnimation:contentPosition forKey:@"appearance animation"];
    [_contentLayer addAnimation:contentScale forKey:nil];
    [_overlayLayer addAnimation:overlayPosition forKey:nil];
    [_overlayLayer addAnimation:overlayScale forKey:nil];
    
    [CATransaction commit];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    _appearanceAnimationInProgress = NO;
}

//--! There is one bug here; in the unlikely case that the loupe is active while the Done or Cancel button is hit,
// this object will be retained past its useful life. This means, in turn, that the contents layer will retain
// a ref to the image, and a large quantity of memory will be leaked.
- (void)removeFromView {
    [_contentLayer removeFromSuperlayer];
    [_overlayLayer removeFromSuperlayer];
}

- (void)setImage:(UIImage *)image {
    _image = image;
//    _contentLayer.transform = CATransform3DMakeRotation(M_PI_2, 0, 0, 1);
    _contentLayer.contents = (__bridge id) [_image CGImage];
}

- (void)setContentsCenter:(CGPoint)point screenDistanceTraveled:(CGFloat)distance {
    CGFloat loupePositionXScaled = 0;
    CGFloat loupePositionYScaled = 0;
    CGFloat loupeDiameterWidthScaled = 0;
    CGFloat loupeDiameterHeightScaled = 0;
    CGPoint transformedPoint;
    
    loupeDiameterWidthScaled = _diameter / _image.size.width;
    loupeDiameterHeightScaled = _diameter / _image.size.height;
    transformedPoint.x = point.x / _image.size.width;
    transformedPoint.y = point.y / _image.size.height;    
    loupePositionXScaled = transformedPoint.x - loupeDiameterWidthScaled / 2;
    loupePositionYScaled = transformedPoint.y - loupeDiameterHeightScaled / 2;
    
    CGRect loupeRect = CGRectMake(loupePositionXScaled, loupePositionYScaled, loupeDiameterWidthScaled, loupeDiameterHeightScaled);
    [CATransaction begin];
    if (distance < 2) {
        [CATransaction setAnimationDuration:0.3];
    } else {
        [CATransaction setDisableActions:YES];
    }
    _contentLayer.contentsRect = loupeRect;
    [CATransaction commit];
}

- (void)setScreenPoint:(CGPoint)point {
    CGFloat distanceTraveled = hypot(point.x - _previousScreenPoint.x, point.y - _previousScreenPoint.y);
    distanceTraveled = 100; // Killing smooth contents center animations for now
    [self setContentsCenter:CGPointApplyAffineTransform(point, self.screenToImageTransform) screenDistanceTraveled:distanceTraveled];
    _previousScreenPoint = point;
    
    if (_appearanceAnimationInProgress)
        return;
    
    _position.x = point.x + _offset.x;
    _position.y = point.y + _offset.y;
    CGPoint unconstrainedPosition = _position;
    BOOL constraintsBroken = [self constrainOffsetFromOriginPoint:point];
    CGFloat distance = hypot(unconstrainedPosition.x - _position.x, unconstrainedPosition.y - _position.y);
    
    if (_shouldAnimateAppearance) {
        [self animateAppearanceFromOriginPoint:point];
    } else {
        [CATransaction begin];
        if (constraintsBroken || distanceTraveled < 2)
            [CATransaction setDisableActions:NO];
        else
            [CATransaction setDisableActions:YES];
        if (distance > 0)
            [CATransaction setAnimationDuration:distance / 1000];
        else if (distanceTraveled < 2)
            [CATransaction setAnimationDuration:0.3];
        _contentLayer.position = _position;
        _overlayLayer.position = _position;
        [CATransaction commit];
    }
}

- (BOOL)constrainOffsetFromOriginPoint:(CGPoint)originPoint {
    BOOL constraintsBroken = NO;
    if ([self breaksConstrant:constraints[Vertical]]) {
        constraintsBroken = YES;
        _position = [self pointByObservingConstraint:constraints[Vertical] withOriginPoint:originPoint bias:Less]; // Shift to left
        if ([self breaksConstrant:constraints[Horizontal]])
            _position = [self pointByObservingConstraint:constraints[Horizontal] withOriginPoint:originPoint bias:Greater]; // Shift down
    } else if ([self breaksConstrant:constraints[Horizontal]]) {
        constraintsBroken = YES;
        _position = [self pointByObservingConstraint:constraints[Horizontal] withOriginPoint:originPoint bias:Less]; // Shift up
        if ([self breaksConstrant:constraints[Vertical]])
            _position = [self pointByObservingConstraint:constraints[Vertical] withOriginPoint:originPoint bias:Greater]; // Shift right
    }
    return constraintsBroken;
}

- (BOOL)breaksConstrant:(LoupeConstraint)constraint {
    if (constraint.direction == Horizontal) {
        if (constraint.sense == Greater) {
            if (constraint.value + _diameter / 2 + _edgeClearance > _position.x)
                return YES;
        } else {
            if (constraint.value - _diameter / 2 - _edgeClearance < _position.x)
                return YES;
        }
    } else {
        if (constraint.sense == Greater) {
            if (constraint.value + _diameter / 2 + _edgeClearance > _position.y)
                return YES;
        } else {
            if (constraint.value - _diameter / 2 - _edgeClearance < _position.y)
                return YES;
        }
    }
    return NO;
}

- (CGPoint)pointByObservingConstraint:(LoupeConstraint)c withOriginPoint:(CGPoint)originPoint bias:(LoupeConstraintSense)bias {
    CGPoint newPoint;
    
    CGFloat origPrim = (c.direction == Horizontal)? originPoint.x : originPoint.y;
    CGFloat origSec = (c.direction == Horizontal)? originPoint.y : originPoint.x;
    CGFloat *newPrim = (c.direction == Horizontal)? &(newPoint.x) : &(newPoint.y);
    CGFloat *newSec = (c.direction == Horizontal)? &(newPoint.y) : &(newPoint.x);
    
    CGPoint deltaFromOrigin;
    CGFloat *deltaPrim = (c.direction == Horizontal)? &(deltaFromOrigin.x) : &(deltaFromOrigin.y);
    CGFloat *deltaSec = (c.direction == Horizontal)? &(deltaFromOrigin.y) : &(deltaFromOrigin.x);
    
    *newPrim = (c.sense == Greater)? (c.value + _edgeClearance + _diameter / 2) : (c.value - (_edgeClearance + _diameter / 2));
    *deltaPrim = (c.sense == Greater)? *newPrim - origPrim : origPrim - *newPrim;
    
    *deltaSec = sqrt((_offsetDiagonal * _offsetDiagonal) - ((*deltaPrim) * (*deltaPrim)));
    if (bias == Less)
        *deltaSec = -(*deltaSec);
    
    *newSec = origSec + *deltaSec;
    
    return newPoint;
}

@end
