//
//  ZoomViewController.m
//  LoupeDemo
//
//  Created by Owen Mathews on 12/17/12.
//  Copyright (c) 2012 Owen Mathews. All rights reserved.
//

#import "ZoomViewController.h"
#import "BNRLoupe.h"
#import "BNRLoupeTouchGestureRecognizer.h"

@interface ZoomViewController () <UIScrollViewDelegate> {
    BNRLoupe *_loupe;
    UIImage *_image;
    IBOutlet __weak UIScrollView *_scrollView;
    UIImageView *_imageView;
}

- (void)loupeRecognizerEvent:(UIGestureRecognizer *)recognizer;

- (void)updateLoupeTransform;

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
        if ([recognizer isKindOfClass:[UIPinchGestureRecognizer class]])
            loupeRecognizer.pinchGestureRecognizer = (UIPinchGestureRecognizer *)recognizer;
        if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]])
            loupeRecognizer.panGestureRecognizer = (UIPanGestureRecognizer *)recognizer;
    }
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
//    [self updateLoupeTransform];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self updateLoupeTransform];
}

- (void)updateLoupeTransform {
    CGFloat imagePixelsPerScreenPixel = 1 / _scrollView.zoomScale;
    _loupe.screenToImageTransform = CGAffineTransformMakeScale(imagePixelsPerScreenPixel, imagePixelsPerScreenPixel);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
