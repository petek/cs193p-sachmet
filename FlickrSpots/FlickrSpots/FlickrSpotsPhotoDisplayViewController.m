//
//  FlickrSpotsPhotoDisplayViewController.m
//  FlickrSpots
//
//  Created by Krawczyk, Pete on 11/1/12.
//  Copyright (c) 2012 Krawczyk, Pete. All rights reserved.
//

#import "FlickrSpotsPhotoDisplayViewController.h"

@interface FlickrSpotsPhotoDisplayViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) id delegate;
@property (strong, nonatomic) NSData *photoData;
@end

@implementation FlickrSpotsPhotoDisplayViewController

@synthesize delegate = _delegate;
@synthesize description = _description;
@synthesize imageView;
@synthesize photoData = _photoData;
@synthesize photoLocation = _photoLocation;
@synthesize scrollView;

-(void)setPhotoLocation:(NSURL *)photoLocation {
    _photoLocation = photoLocation;
    self.photoData = [NSData dataWithContentsOfURL:photoLocation];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

-(void)redoViewMath{
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.maximumZoomScale = 1;
    self.scrollView.zoomScale = 1;
    self.scrollView.contentSize = self.imageView.image.size;
    self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
    
    CGFloat heightZoom = self.scrollView.frame.size.height / self.imageView.image.size.height;
    CGFloat widthZoom = self.scrollView.frame.size.width / self.imageView.image.size.width;
    CGRect zoomRect;
    if (widthZoom < heightZoom) {
        // show the full height and attempt to center the width
        self.scrollView.minimumZoomScale = (widthZoom < 1 ? widthZoom : 1);
        self.scrollView.maximumZoomScale = (heightZoom * 4 > 1 ? heightZoom * 4 : 1);
        zoomRect.origin.x = (int)(self.imageView.image.size.width - (self.imageView.image.size.width * heightZoom))/2;
        zoomRect.size.width = self.imageView.image.size.width * heightZoom;
        zoomRect.origin.y = 0;
        zoomRect.size.height = self.imageView.image.size.height;
    }
    else {
        // show the full width and attempt to center the height
        self.scrollView.minimumZoomScale = (heightZoom < 1 ? heightZoom : 1);
        self.scrollView.maximumZoomScale = (widthZoom * 4 > 1 ? widthZoom * 4 : 1);
        zoomRect.origin.x = 0;
        zoomRect.size.width = self.imageView.image.size.width;
        zoomRect.origin.y = (int)(self.imageView.image.size.height - (self.imageView.image.size.height * widthZoom))/2;
        zoomRect.size.height = self.imageView.image.size.height * widthZoom;
    }
    [self.scrollView zoomToRect:zoomRect animated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = self.description;

    UIImage *photoToShow = [UIImage imageWithData:self.photoData];
    [self.imageView setImage:photoToShow];
    
    [self redoViewMath];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self redoViewMath];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self;
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

@end
