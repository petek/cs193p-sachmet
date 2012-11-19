//
//  FlickrSpotsPhotoDisplayViewController.h
//  FlickrSpots
//
//  Created by Krawczyk, Pete on 11/1/12.
//  Copyright (c) 2012 Krawczyk, Pete. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrSpotsPhotoDisplayViewController : UIViewController

@property (weak, nonatomic) id photo;
@property (nonatomic, weak) id delegate;
@property (readonly) NSString *description;

@end
