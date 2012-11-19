//
//  FlickrSpotsPhotoModel.h
//  FlickrSpots
//
//  Created by Krawczyk, Pete on 11/16/12.
//  Copyright (c) 2012 Krawczyk, Pete. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrSpotsPhotoModel : NSObject

@property (nonatomic, strong) id photo;
@property (readonly) NSData *thumbnailPhoto;
@property (readonly) NSData *largePhoto;
@property (readonly) NSData *originalPhoto;
@property (readonly) NSString *photoTitle;
@property (readonly) NSString *photoDescription;

+(FlickrSpotsPhotoModel *)initWithPhoto:(id)photo;

@end
