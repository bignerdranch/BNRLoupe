//
//  ViewController.m
//  LoupeDemo
//
//  Created by Owen Mathews on 12/12/12.
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

#import "StaticViewController.h"
#import "BNRLoupe.h"

@interface StaticViewController () {
    BNRLoupe *_loupe;
}

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

@implementation StaticViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = @"Static";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _loupe = [[BNRLoupe alloc] initWithDiameter:100 offset:100 offsetAngle:3*M_PI_4 constraintsRect:self.view.bounds edgeClearance:10];
    _loupe.image = self.imageView.image;
}

- (void)viewDidLayoutSubviews {
    [_loupe setConstraintsRect:self.view.bounds];
    
    CGFloat imageActualWidth = self.imageView.image.size.width;
    CGFloat imageActualHeight = self.imageView.image.size.height;
    CGFloat myWidth = self.view.bounds.size.width;
    CGFloat myHeight = self.view.bounds.size.height;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_loupe displayInView:self.view];
    [_loupe setScreenPoint:[[touches anyObject] locationInView:self.view]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [_loupe setScreenPoint:[[touches anyObject] locationInView:self.view]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [_loupe removeFromView];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [_loupe removeFromView];
}

@end
