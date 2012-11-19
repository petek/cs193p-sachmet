//
//  FlickrSpotsPhotoDisplayViewController.m
//  FlickrSpots
//
//  Created by Krawczyk, Pete on 11/1/12.
//  Copyright (c) 2012 Krawczyk, Pete. All rights reserved.
//

#import "FlickrSpotsPhotoDisplayViewController.h"
#import "FlickrSpotsPhotoModel.h"

@interface FlickrSpotsPhotoDisplayViewController () <UIScrollViewDelegate,UISplitViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleBarTitle;
@property (weak, nonatomic) IBOutlet UIToolbar *titleBar;
@property (strong, nonatomic) NSData *photoData;
@property (strong, nonatomic) FlickrSpotsPhotoModel *photoModel;
@end

@implementation FlickrSpotsPhotoDisplayViewController

@synthesize delegate = _delegate;
@synthesize imageView = _imageView;
@synthesize photo = _photo;
@synthesize photoData = _photoData;
@synthesize scrollView = _scrollView;

-(void)doPhotoDataDispatch {
    if (self.photoModel == nil) {
        return;
    }
    if (self.photoData) {
        return [self loadImage];
    }

    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        self.photoData = [self.photoModel largePhoto];
        if (self.imageView) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadImage];
            });
        }
    });
    dispatch_release(downloadQueue);
}

-(void)setPhoto:(id)photo {
    _photo = photo;
    self.photoModel = [FlickrSpotsPhotoModel initWithPhoto:photo];
    self.photoData = nil;
    if (self.imageView) {
        // This resets the frame and drops the image so that the spinner doesn't move around the screen
        CGRect frameRect = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        [self.scrollView zoomToRect:frameRect animated:NO];
        self.imageView.frame = frameRect;
        self.imageView.image = nil;

        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        spinner.center = self.imageView.center;
        [self.imageView addSubview:spinner];
    }
    [self doPhotoDataDispatch];
}

-(void)setImageView:(UIImageView *)imageView {
    _imageView = imageView;
    if (self.photoData) {
        [self loadImage];
    }
}

-(NSString *)description {
    if (self.photoModel) {
        return [self.photoModel photoTitle];
    }
    return @"Unknown";
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

-(void)setScrollView:(UIScrollView *)scrollView {
    _scrollView = scrollView;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetView:)];
    [tapGesture setNumberOfTapsRequired:2];
    [tapGesture setNumberOfTouchesRequired:1];
    [self.scrollView addGestureRecognizer:tapGesture];
}

-(void)resetView:(UITapGestureRecognizer *)gesture {
    [self redoViewMath];
}

-(void)redoViewMath{
    self.scrollView.zoomScale = 1;
    self.scrollView.maximumZoomScale = 4;
    self.scrollView.contentSize = self.imageView.image.size;
    self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
    
    // This is exceedingly ugly, but otherwise a long title will overlap our "Select Photo" button.
    if (self.titleBar) {
        // Check the first item, see if it's our "Select Photo" button
        UIBarButtonItem *firstItem = [self.titleBar.items objectAtIndex:0];
        if ([firstItem.title isEqualToString:@"Select Photo"]) {
            UIView *firstItemView = [firstItem valueForKey:@"view"];
            CGFloat firstItemWidth = firstItemView ? firstItemView.frame.size.width : (CGFloat)0.0;
            NSUInteger maxWidth = self.scrollView.frame.size.width - (int)firstItemWidth;
            // The last item is a flexible space thing; the second to last is the title
            NSUInteger titlePlace = [self.titleBar.items count] - 2;
            UIBarButtonItem *titleItem = [self.titleBar.items objectAtIndex:titlePlace];
            titleItem.width = maxWidth;
        }
    }
    
    CGFloat heightZoom = self.scrollView.frame.size.height / self.imageView.image.size.height;
    CGFloat widthZoom = self.scrollView.frame.size.width / self.imageView.image.size.width;
    CGRect zoomRect;
    if (widthZoom < heightZoom) {
        // show the full height and attempt to center the width
        self.scrollView.minimumZoomScale = (widthZoom < 1 ? widthZoom : 1);
        zoomRect.size.width = self.scrollView.frame.size.width / heightZoom;
        zoomRect.origin.x = (int)(self.imageView.image.size.width - zoomRect.size.width)/2;
        zoomRect.size.height = self.imageView.image.size.height;
        zoomRect.origin.y = 0;
    }
    else {
        // show the full width and attempt to center the height
        self.scrollView.minimumZoomScale = (heightZoom < 1 ? heightZoom : 1);
        zoomRect.size.width = self.imageView.image.size.width;
        zoomRect.origin.x = 0;
        zoomRect.size.height = self.scrollView.frame.size.height / widthZoom;
        zoomRect.origin.y = (int)(self.imageView.image.size.height - zoomRect.size.height)/2;
    }
    [self.scrollView zoomToRect:zoomRect animated:YES];
}

-(void)loadImage {
    UIImage *photoToShow = [UIImage imageWithData:self.photoData];
    NSArray *subviews = [[self.imageView subviews] copy];
    for (UIView *subview in subviews) {
        [subview removeFromSuperview];
    }
    [self.imageView setImage:photoToShow];
    [self redoViewMath];
    if (self.titleBarTitle) {
        [self.titleBarTitle setTitle:self.photoModel.photoTitle];
    }
    [self.imageView setNeedsDisplay];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = self.description;

    if (self.photoData) {
        [self loadImage];
    }
    else if (self.photoModel) {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        spinner.center = self.imageView.center;
        [self.imageView addSubview:spinner];
    }
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
    [self setTitleBarTitle:nil];
    [self setTitleBar:nil];
    [self setPhotoData:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)awakeFromNib {
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

-(BOOL)splitViewController:(UISplitViewController *)svc
  shouldHideViewController:(UIViewController *)vc
             inOrientation:(UIInterfaceOrientation)orientation {
    return YES;
}

-(void)splitViewController:(UISplitViewController *)svc
    willHideViewController:(UIViewController *)aViewController
         withBarButtonItem:(UIBarButtonItem *)barButtonItem
      forPopoverController:(UIPopoverController *)pc {
    barButtonItem.title = @"Select Photo";
    NSMutableArray *toolbarItems = [self.titleBar.items mutableCopy];
    [toolbarItems insertObject:barButtonItem atIndex:0];
    self.titleBar.items = [toolbarItems copy];
}

-(void)splitViewController:(UISplitViewController *)svc
    willShowViewController:(UIViewController *)aViewController
 invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    NSMutableArray *toolbarItems = [self.titleBar.items mutableCopy];
    [toolbarItems removeObject:barButtonItem];
    self.titleBar.items = [toolbarItems copy];
}

@end
