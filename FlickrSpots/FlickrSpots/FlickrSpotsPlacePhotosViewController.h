//
//  FlickrSpotsPlacePhotosViewController.h
//  FlickrSpots
//
//  Created by Krawczyk, Pete on 10/31/12.
//  Copyright (c) 2012 Krawczyk, Pete. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlickrSpotsPlacePhotosViewController;

@protocol FlickrSpotsPlacePhotosViewControllerDelegate <NSObject>;
@optional
-(void)flickrSpotsPlacePhotosViewController:(FlickrSpotsPlacePhotosViewController *)sender
                                chosenPlace:(id)place
                            withDescription:(NSString *)description;
@end

@interface FlickrSpotsPlacePhotosViewController : UITableViewController

@property (nonatomic, strong) id place;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, weak) id delegate;

@end
