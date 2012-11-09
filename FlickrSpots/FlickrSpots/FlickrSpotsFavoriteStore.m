//
//  FlickrSpotsFavoriteStore.m
//  FlickrSpots
//
//  Created by Krawczyk, Pete on 11/1/12.
//  Copyright (c) 2012 Krawczyk, Pete. All rights reserved.
//

#import "FlickrSpotsFavoriteStore.h"
#import "FlickrFetcher/FlickrFetcher.h"

#define FAVORITES_KEY @"FlickrSpotsFavoriteStore.Favorites"
#define MAX_FAVORITES 20

@interface FlickrSpotsFavoriteStore()
+(void)storeFavorites:(NSArray *)favorites;
@end

@implementation FlickrSpotsFavoriteStore

+(void)storeFavorites:(NSArray *)favorites {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:favorites forKey:FAVORITES_KEY];
    [defaults synchronize];
}

+(NSArray *)favoritePhotos {
    NSArray *favorites = [[NSUserDefaults standardUserDefaults] objectForKey:FAVORITES_KEY];
    if (!favorites) {
        favorites = [NSMutableArray arrayWithArray:@[]];
    }
    return favorites;
}

+(void)addFavoritePhoto:(NSDictionary *)photoObject {
    [self removeFavoritePhoto:photoObject];
    NSMutableArray *favorites = [self.favoritePhotos mutableCopy];
    if ([favorites count] == 0) {
        favorites = [NSMutableArray arrayWithObject:photoObject];
    }
    else {
        [favorites insertObject:photoObject atIndex:0];
    }
    if ([favorites count] > MAX_FAVORITES) {
        int numToRemove = [favorites count] - MAX_FAVORITES;
        NSRange removalRange = {MAX_FAVORITES, numToRemove};
        [favorites removeObjectsInRange:removalRange];
    }
    [FlickrSpotsFavoriteStore storeFavorites:favorites];
}

+(void)removeFavoritePhoto:(NSDictionary *)photoObject {
    NSMutableArray *favorites = [self.favoritePhotos mutableCopy];
    for (int i = 0; i < [favorites count]; i++) {
        if ([[[favorites objectAtIndex:i] objectForKey:FLICKR_PHOTO_ID] isEqualToString:[photoObject objectForKey:FLICKR_PHOTO_ID]]) {
            [favorites removeObjectAtIndex:i];
            break;
        }
    }
    [FlickrSpotsFavoriteStore storeFavorites:favorites];
}

+(void)clearFavoritePhotos {
    [FlickrSpotsFavoriteStore storeFavorites:nil];
}

@end
