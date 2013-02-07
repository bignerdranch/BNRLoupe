//
//  CATImageMeasurementAdjustmentGestureRecognizer.m
//  CATMeasure
//
//  Created by Owen Mathews on 11/27/12.
//  Copyright (c) 2012 Big Nerd Ranch, LLC. All rights reserved.
//

/*
 Copyright (c) 2012, Big Nerd Ranch, LLC
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:
 
 Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright  
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
    IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT   
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/

#import <UIKit/UIGestureRecognizerSubclass.h>
#import "BNRLoupeTouchGestureRecognizer.h"

//#define CATLogReset _logString = [NSMutableString string]; [_debugLabel setText:@""]
//#define CATLog(...) [_logString appendFormat:@"%@\n", __VA_ARGS__]
//#define CATLogDisplay [_debugLabel setText:_logString]
#define CATLogReset
#define CATLog(...)
#define CATLogDisplay

//#define CATLog(...) NSLog(__VA_ARGS__)

@interface NSMutableString (LabelLogging)

- (void)reset:(UILabel *)label;
- (void)display:(UILabel *)label;
- (void)clear:(UILabel *)label;

@end

@implementation NSMutableString (LabelLogging)

- (void)reset:(UILabel *)label {
    [self clear:label];
}

- (void)display:(UILabel *)label {
    [label setText:self];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(clear:) userInfo:@{@"label": label} repeats:NO];
}

- (void)clear:(UILabel *)label {
    if (!label)
        return;
    if ([label isKindOfClass:[NSDictionary class]])
        label = (UILabel *)[(NSDictionary *)label objectForKey:@"label"];
    if (![label isKindOfClass:[UILabel class]])
        [label setText:@""];
}

@end

//#define CATLog(...) [_logString appendFormat:@"%@", __VA_ARGS__]
//#define CATLogReset _logString = [NSMutableString string]; [_logString reset:_debugLabel]
//#define CATLogDisplay [_logString display:_debugLabel]

@interface BNRLoupeTouchGestureRecognizer () {
    UITouch *_trackedTouch;
    NSTimeInterval _trackedTouchOriginationTime;
    CGPoint _trackedTouchOriginationPoint;
    NSTimer *_trackingTimer;
}
@end

static NSMutableString *_logString;

@implementation BNRLoupeTouchGestureRecognizer

- (id)initWithTarget:(id)target action:(SEL)action {
    self = [super initWithTarget:target action:action];
    if (self) {
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CATLogReset;
    if (_trackedTouch || touches.count > 1) {
        CATLog(@"touchesBegan: _trackedTouch already set or multiple touches began; ignoring this touch.");
        for (UITouch *touch in touches)
            [self ignoreTouch:touch forEvent:event];
        CATLogDisplay;
        return;
    }
    _trackedTouch = [touches anyObject];
    CATLog(@"touchesBegan: setting _trackedTouch");
    CATLog(@"** transitioning to state POSSIBLE");
    self.state = UIGestureRecognizerStatePossible;
    CATLog(@"\tmay track touch");
    _trackedTouchOriginationTime = _trackedTouch.timestamp;
    _trackedTouchOriginationPoint = [_trackedTouch locationInView:self.view];
    _trackingTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:0.1] interval:0 target:self selector:@selector(determineTracking:) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_trackingTimer forMode:NSRunLoopCommonModes];
//        [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(determineTracking:) userInfo:nil repeats:NO];
    CATLogDisplay;
}

- (void)determineTracking:(NSTimer *)timer {
    CATLogReset;
    [_trackingTimer invalidate];
    _trackingTimer = nil;
    if (!_trackedTouch) {
        CATLog(@"\ttouch was already ended or cancelled (_trackedTouch == nil).");
        CATLogDisplay;
        return;
    }
    CGPoint currentPoint = [_trackedTouch locationInView:self.view];
    CGFloat xDiff = currentPoint.x - _trackedTouchOriginationPoint.x;
    CGFloat yDiff = currentPoint.y - _trackedTouchOriginationPoint.y;
    CGFloat distance = sqrt(xDiff * xDiff + yDiff * yDiff);
    if (distance < 10) {
        CATLog(@"\twill track touch");
        CATLog(@"** transitioning to state BEGAN");
        self.state = UIGestureRecognizerStateBegan;
    } else {
        CATLog(@"\twill NOT track touch; killing _trackedTouch");
        CATLog(@"** transitioning to state FAILED");
        self.state = UIGestureRecognizerStateFailed;
        _trackedTouch = nil;
    }
    CATLogDisplay;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CATLogReset;
    CATLog(@"touches moved");
    if (_trackingTimer) {
        CATLog(@"Waiting for tracking timer; ignoring event");
        CATLogDisplay;
        return;
    }
    for (UITouch *touch in touches) {
        if (touch != _trackedTouch || self.state == UIGestureRecognizerStatePossible) {
            CATLog(@"Ignoring a touch; was not the tracked touch or my state was POSSIBLE");
            [self ignoreTouch:touch forEvent:event];
        } else {
            if (self.state != UIGestureRecognizerStateChanged) {
                CATLog(@"** transitioning to state CHANGED");
                self.state = UIGestureRecognizerStateChanged;
            }
        }
    }
    CATLogDisplay;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    CATLogReset;
    [_trackingTimer invalidate];
    _trackingTimer = nil;
    for (UITouch *touch in touches) {
        if (touch == _trackedTouch) {
            CATLog(@"touches ended; killing tracked touch.");
            _trackedTouch = nil;
            CATLog(@"** transitioning to state ENDED");
            self.state = UIGestureRecognizerStateEnded;
        }
    }
    CATLogDisplay;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    CATLogReset;
    [_trackingTimer invalidate];
    _trackingTimer = nil;
    for (UITouch *touch in touches) {
        if (touch == _trackedTouch) {
            NSLog(@"touches cancelled; killing tracked touch.");
            _trackedTouch = nil;
            NSLog(@"** transitioning to state CANCELLED");
            self.state = UIGestureRecognizerStateCancelled;
        }
    }
    CATLogDisplay;
}

@end
