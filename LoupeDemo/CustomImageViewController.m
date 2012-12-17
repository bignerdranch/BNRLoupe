//
//  CustomImageViewController.m
//  LoupeDemo
//
//  Created by Owen Mathews on 12/17/12.
//  Copyright (c) 2012 Owen Mathews. All rights reserved.
//

#import "CustomImageViewController.h"
#import "BNRLoupeImageView.h"

@interface CustomImageViewController ()
@property (nonatomic, weak) IBOutlet BNRLoupeImageView *loupeImageView;
@end

@implementation CustomImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = @"Custom Image";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.loupeImageView.image = [UIImage imageNamed:@"Dec09_1.jpg"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
