//
//  ViewController.m
//  LoupeDemo
//
//  Created by Owen Mathews on 12/12/12.
//  Copyright (c) 2012 Owen Mathews. All rights reserved.
//

#import "ViewController.h"
#import "BNRLoupe.h"

@interface ViewController () {
    BNRLoupe *_loupe;
    
    CGFloat _imagePixelsPerScreenPixel;
    CGPoint _imageOffset;
}

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _loupe = [[BNRLoupe alloc] initWithDiameter:80 offset:60 offsetAngle:3*M_PI_4 constraintsRect:self.view.bounds edgeClearance:10];
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
    _imagePixelsPerScreenPixel = MAX(widthRatio, heightRatio);
    _imageOffset = CGPointMake(0, 0);
    if (widthRatio != heightRatio) {
        if (widthRatio > heightRatio) {
            _imageOffset.y = (myHeight - (imageActualHeight / _imagePixelsPerScreenPixel)) / 2;
        } else {
            _imageOffset.x = (myWidth - (imageActualWidth / _imagePixelsPerScreenPixel)) / 2;
        }
    }
    
    _loupe.screenToImageTransform = CGAffineTransformTranslate(CGAffineTransformMakeScale(_imagePixelsPerScreenPixel, _imagePixelsPerScreenPixel), -_imageOffset.x, -_imageOffset.y);
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
