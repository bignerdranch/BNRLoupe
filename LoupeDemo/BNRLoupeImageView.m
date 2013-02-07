//
//  BNRLoupeImageView.m
//  LoupeDemo
//
//  Created by Owen Mathews on 12/17/12.
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

#import "BNRLoupeImageView.h"
#import "BNRLoupe.h"

@interface BNRLoupeImageView () {
    BNRLoupe *_loupe;
    
    CGFloat _imagePixelsPerScreenPixel;
    CGPoint _imageOffset;
}
@end

@implementation BNRLoupeImageView

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if (self) {
        _loupe = [[BNRLoupe alloc] initWithDiameter:100 offset:100 offsetAngle:3*M_PI_4 constraintsRect:self.bounds edgeClearance:10];
        if (image) {
            self.image = image;
        }
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _loupe = [[BNRLoupe alloc] initWithDiameter:100 offset:100 offsetAngle:3*M_PI_4 constraintsRect:self.bounds edgeClearance:10];
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (void)setMultipleTouchEnabled:(BOOL)multipleTouchEnabled {
    [super setMultipleTouchEnabled:NO];
}

- (void)setImage:(UIImage *)image {
    [super setImage:image];
    _loupe.image = image;
}

- (void)setContentMode:(UIViewContentMode)contentMode {
    [super setContentMode:UIViewContentModeScaleAspectFit];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_loupe setConstraintsRect:self.bounds];
    
    //--TODO make this work with various content modes
    CGFloat imageActualWidth = self.image.size.width;
    CGFloat imageActualHeight = self.image.size.height;
    CGFloat myWidth = self.bounds.size.width;
    CGFloat myHeight = self.bounds.size.height;
    CGFloat widthRatio = imageActualWidth / myWidth;
    CGFloat heightRatio = imageActualHeight / myHeight;
    CGFloat imagePixelsPerScreenPixel = MAX(widthRatio, heightRatio);
    CGPoint imageOffset = CGPointMake(0, 0);
    if (widthRatio != heightRatio) {
        if (widthRatio > heightRatio) {
            imageOffset.y = (myHeight - (imageActualHeight / imagePixelsPerScreenPixel)) / 2;
        } else {
            imageOffset.x = (myWidth - (imageActualWidth / imagePixelsPerScreenPixel)) / 2;
        }
    }
    
    _loupe.screenToImageTransform = CGAffineTransformTranslate(CGAffineTransformMakeScale(imagePixelsPerScreenPixel, imagePixelsPerScreenPixel), -imageOffset.x, -imageOffset.y);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_loupe displayInView:self];
    [_loupe setScreenPoint:[[touches anyObject] locationInView:self]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [_loupe setScreenPoint:[[touches anyObject] locationInView:self]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [_loupe removeFromView];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [_loupe removeFromView];
}

@end
