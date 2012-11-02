//
//  FlickrSpotsRecentPhotosViewController.h
//  FlickrSpots
//
//  Created by Krawczyk, Pete on 11/1/12.
//  Copyright (c) 2012 Krawczyk, Pete. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlickrSpotsRecentPhotosViewController;

@protocol FlickrSpotsRecentPhotosViewControllerDelegate <NSObject>;
@optional
@end

@interface FlickrSpotsRecentPhotosViewController : UITableViewController

@property (nonatomic, weak) id delegate;

@end
