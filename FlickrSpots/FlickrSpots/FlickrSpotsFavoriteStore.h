//
//  FlickrSpotsFavoriteStore.h
//  FlickrSpots
//
//  Created by Krawczyk, Pete on 11/1/12.
//  Copyright (c) 2012 Krawczyk, Pete. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrSpotsFavoriteStore : NSObject
+(NSArray *)favoritePhotos;
+(void)addFavoritePhoto:(NSDictionary *)photoObject;
+(void)removeFavoritePhoto:(NSDictionary *)photoObject;
+(void)clearFavoritePhotos;
@end
