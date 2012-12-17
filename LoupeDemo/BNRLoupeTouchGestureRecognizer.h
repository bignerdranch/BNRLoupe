//
//  CATImageMeasurementAdjustmentGestureRecognizer.h
//  CATMeasure
//
//  Created by Owen Mathews on 11/27/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BNRLoupeTouchGestureRecognizer : UIGestureRecognizer <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIPinchGestureRecognizer *pinchGestureRecognizer;
@property (nonatomic, weak) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic, weak) UILabel *debugLabel;

@end
