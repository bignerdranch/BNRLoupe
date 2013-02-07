//
//  ZoomViewController.m
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

#import "ZoomViewController.h"
#import "BNRLoupe.h"
#import "BNRLoupeTouchGestureRecognizer.h"

@interface ZoomViewController () <UIScrollViewDelegate> {
    BNRLoupe *_loupe;
    UIImage *_image;
    IBOutlet __weak UIScrollView *_scrollView;
    UIImageView *_imageView;
}

@property (nonatomic, weak) IBOutlet UILabel *debugLabel;

- (void)loupeRecognizerEvent:(UIGestureRecognizer *)recognizer;

@end

@implementation ZoomViewController

- (id)initWithImage:(UIImage *)image {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _image = image;
        self.tabBarItem.title = @"Zoom";
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    @throw @"Cannot call initWithNibName:bundle: -- please use initWithImage:";
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Loupe setup
    _loupe = [[BNRLoupe alloc] initWithDiameter:100 offset:100 offsetAngle:3*M_PI_4 constraintsRect:self.view.bounds edgeClearance:10];
    _loupe.image = _image;

    // Image/scrolling setup
    _imageView = [[UIImageView alloc] initWithImage:_image];
    [_scrollView addSubview:_imageView];
    _scrollView.contentSize = _image.size;
    _scrollView.delegate = self;
    
    // Gesture recognizer setup
    BNRLoupeTouchGestureRecognizer *loupeRecognizer = [[BNRLoupeTouchGestureRecognizer alloc] initWithTarget:self action:@selector(loupeRecognizerEvent:)];
    [_scrollView addGestureRecognizer:loupeRecognizer];
    for (UIGestureRecognizer *recognizer in _scrollView.gestureRecognizers) {
        [recognizer requireGestureRecognizerToFail:loupeRecognizer];
    }
    
//    loupeRecognizer.debugLabel = _debugLabel;
//    _debugLabel.text = @"Debug";
//    _debugLabel.textColor = [UIColor redColor];
//    _debugLabel.numberOfLines = 4;
//    _debugLabel.frame = CGRectMake(0, 380, 320, 100);
}

- (void)loupeRecognizerEvent:(UIGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [_loupe displayInView:_scrollView];
        [_loupe setScreenPoint:[recognizer locationInView:_scrollView]];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [_loupe setScreenPoint:[recognizer locationInView:_scrollView]];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        [_loupe removeFromView];
    } else if (recognizer.state == UIGestureRecognizerStateCancelled) {
        [_loupe removeFromView];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    // Scrolling zoom stuff
    _scrollView.maximumZoomScale = 1;
    _scrollView.minimumZoomScale = MAX(_scrollView.bounds.size.width / _image.size.width, _scrollView.bounds.size.height / _image.size.height);
    _scrollView.zoomScale = _scrollView.minimumZoomScale;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint o = _scrollView.contentOffset;
    CGSize s = _scrollView.bounds.size;
    [_loupe setConstraintsRect:CGRectMake(o.x, o.y, s.width, s.height)];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat imagePixelsPerScreenPixel = 1 / _scrollView.zoomScale;
    _loupe.screenToImageTransform = CGAffineTransformMakeScale(imagePixelsPerScreenPixel, imagePixelsPerScreenPixel);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
