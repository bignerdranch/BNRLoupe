//
//  ZoomViewController.m
//  LoupeDemo
//
//  Created by Owen Mathews on 12/17/12.
//  Copyright (c) 2012 Owen Mathews. All rights reserved.
//

#import "ZoomViewController.h"
#import "BNRLoupe.h"

@interface ZoomViewController () <UIScrollViewDelegate> {
    BNRLoupe *_loupe;
    UIImage *_image;
    IBOutlet __weak UIScrollView *_scrollView;
    UIImageView *_imageView;
}

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
    _imageView = [[UIImageView alloc] initWithImage:_image];
    [_scrollView addSubview:_imageView];
    _scrollView.contentSize = _image.size;
    _scrollView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    _scrollView.maximumZoomScale = 1;
    _scrollView.minimumZoomScale = MAX(_scrollView.bounds.size.width / _image.size.width, _scrollView.bounds.size.height / _image.size.height);
    _scrollView.zoomScale = _scrollView.minimumZoomScale;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
