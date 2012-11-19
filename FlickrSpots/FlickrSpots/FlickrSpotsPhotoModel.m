//
//  FlickrSpotsPhotoModel.m
//  FlickrSpots
//
//  Created by Krawczyk, Pete on 11/16/12.
//  Copyright (c) 2012 Krawczyk, Pete. All rights reserved.
//

#import "FlickrSpotsPhotoModel.h"
#import "FlickrFetcher.h"

// 10MiB of cache
#define MAX_CACHE_SIZE 10000000

@interface FlickrSpotsPhotoModel ()

-(NSArray *)photoDescriptionHelper;
-(NSURL *)originalURL;
-(NSURL *)largeURL;
-(NSURL *)thumbnailURL;
-(NSData *)photoDataAtURL:(NSURL *)url;

-(NSURL *)cacheFileName:(FlickrPhotoFormat)photoFormat;
-(BOOL)photoIsInCache:(FlickrPhotoFormat)photoFormat;
-(NSData *)getPhotoFromCache:(FlickrPhotoFormat)photoFormat;
-(NSString *)photoCacheLocation:(FlickrPhotoFormat)photoFormat;
-(void)storePhotoInCache:(NSData *)photoData forSize:(FlickrPhotoFormat)photoFormat;
-(NSURL *)cacheLocation;
-(NSDictionary *)cacheContents;
-(NSUInteger)cacheSize;

@end

@implementation FlickrSpotsPhotoModel

@synthesize photo = _photo;

+(FlickrSpotsPhotoModel *)initWithPhoto:(id)photo {
    FlickrSpotsPhotoModel *photoModel = [[FlickrSpotsPhotoModel alloc] init];
    photoModel.photo = photo;
    return photoModel;
}

#pragma mark Photo Descriptors

-(NSString *)photoTitle {
    return [[self photoDescriptionHelper] objectAtIndex:0];
}

-(NSString *)photoDescription {
    return [[self photoDescriptionHelper] objectAtIndex:1];
}

-(NSArray *)photoDescriptionHelper {
    if (self.photo) {   
        NSString *titleString = [self.photo valueForKey:FLICKR_PHOTO_TITLE];
        NSString *descriptionString = [self.photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        if (titleString && ![titleString isEqualToString:@""]) {
            return @[titleString, descriptionString];
        }
        else if (descriptionString && ![descriptionString isEqualToString:@""]) {
            return @[descriptionString, @""];
        }
    }
    return @[@"Unknown", @""];
}

#pragma mark Photo Fetchers

-(NSData *)originalPhoto {
    if (!self.photo) {
        return nil;
    }
    NSData *photoData;
    if ([self photoIsInCache:FlickrPhotoFormatOriginal]) {
        photoData = [self getPhotoFromCache:FlickrPhotoFormatOriginal];
    }
    if (photoData == nil) { // catch a cache failure
        photoData = [self photoDataAtURL:self.originalURL];
        if (photoData != nil) {
            [self storePhotoInCache:photoData forSize:FlickrPhotoFormatOriginal];
        }
    }
    return photoData;
}

-(NSURL *)originalURL {
    return [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatOriginal];
}

-(NSData *)largePhoto {
    if (!self.photo) {
        return nil;
    }
    NSData *photoData;
    // NSLog(@"Checking cache...");
    if ([self photoIsInCache:FlickrPhotoFormatLarge]) {
        // NSLog(@"Fetching from cache...");
        photoData = [self getPhotoFromCache:FlickrPhotoFormatLarge];
    }
    if (photoData == nil) { // catch a cache failure
        // NSLog(@"Going to Internet...");
        photoData = [self photoDataAtURL:self.largeURL];
        if (photoData != nil) {
            [self storePhotoInCache:photoData forSize:FlickrPhotoFormatLarge];
        }
    }
    return photoData;
}

-(NSURL *)largeURL {
    return [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge];
}

-(NSData *)thumbnailPhoto {
    if (!self.photo) {
        return nil;
    }
    NSData *photoData;
    if ([self photoIsInCache:FlickrPhotoFormatSquare]) {
        photoData = [self getPhotoFromCache:FlickrPhotoFormatSquare];
    }
    if (photoData == nil) { // catch a cache failure
        photoData = [self photoDataAtURL:self.thumbnailURL];
        if (photoData != nil) {
            [self storePhotoInCache:photoData forSize:FlickrPhotoFormatSquare];
        }
    }
    return photoData;
}

-(NSURL *)thumbnailURL {
    return [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatSquare];
}

-(NSData *)photoDataAtURL:(NSURL *)url {
    // NSLog(@"Getting photo from Internet...");
    return [NSData dataWithContentsOfURL:url];
}

#pragma mark Cache Methods

-(NSURL *)cacheFileName:(FlickrPhotoFormat)photoFormat {
    NSURL *cacheLocation = [self cacheLocation];
    if (cacheLocation == nil) {
        return nil;
    }

    NSString *photoId = [self.photo objectForKey:FLICKR_PHOTO_ID];
    NSString *filename;
    if (photoFormat == FlickrPhotoFormatLarge) {
        filename = [photoId stringByAppendingString:@"-l.jpg"];
    }
    else if (photoFormat == FlickrPhotoFormatSquare) {
        filename = [photoId stringByAppendingString:@"-s.jpg"];
    }
    else if (photoFormat == FlickrPhotoFormatOriginal) {
        filename = [photoId stringByAppendingString:@"-o.jpg"];
    }
    else {
        return nil;
    }
    return [NSURL URLWithString:filename relativeToURL:cacheLocation];
}

-(BOOL)photoIsInCache:(FlickrPhotoFormat)photoFormat {
    return [self photoCacheLocation:photoFormat] != nil;
}

-(NSData *)getPhotoFromCache:(FlickrPhotoFormat)photoFormat {
    NSString *photoLocation = [self photoCacheLocation:photoFormat];
    // NSLog(@"Checking for photo in cache at %@", photoLocation);
    if (photoLocation) {
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        // NSLog(@"Got photo from cache!");
        return [fileManager contentsAtPath:photoLocation];
    }
    return nil;
}

-(NSString *)photoCacheLocation:(FlickrPhotoFormat)photoFormat {
    NSURL *filename = [self cacheFileName:photoFormat];
    if (![filename isFileURL]) {
        // NSLog(@"Cache location is not a File URL");
        return nil;
    }
    NSDictionary *cacheContents = [self cacheContents];
    NSArray *cacheFiles = [cacheContents allKeys];
    for (NSString *cacheFile in cacheFiles) {
        NSURL *cacheURL = [[cacheContents objectForKey:cacheFile] objectForKey:@"URL"];
        // NSLog(@"Checking cache locations: %@ vs %@", [cacheURL absoluteString], [filename absoluteString]);
        if ([[cacheURL fileReferenceURL] isEqual:[filename fileReferenceURL]]) {
            // NSLog(@"Found it!");
            return [filename path];
        }
    }
    return nil;
}

-(void)storePhotoInCache:(NSData *)photoData forSize:(FlickrPhotoFormat)photoFormat {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *filename = [self cacheFileName:photoFormat];
    
    NSUInteger filesize = [photoData length];
    if (filesize > MAX_CACHE_SIZE) {
        // NSLog(@"Refusing to cache thing larger than our allowable cache!");
        return;
    }
    
    NSUInteger cacheSize = [self cacheSize];
    while (filesize + cacheSize > MAX_CACHE_SIZE) {
       
        // NSLog(@"Checking: %d vs %d (%d + %d)", MAX_CACHE_SIZE, (filesize + cacheSize), filesize, cacheSize);
        NSDictionary *oldestItem;
        NSDictionary *cacheContents = [self cacheContents];
        NSArray *cacheFiles = [cacheContents allKeys];
        for (NSString *cacheFile in cacheFiles) {
            if (oldestItem == nil) {
                oldestItem = [cacheContents objectForKey:cacheFile];
            }
            else {
                NSDictionary *newItem = [cacheContents objectForKey:cacheFile];
                NSDate *newDate = [newItem objectForKey:@"Date"];
                NSDate *oldDate = [oldestItem objectForKey:@"Date"];
                if ([newDate isEqualToDate:[newDate earlierDate:oldDate]]) {
                    oldestItem = newItem;
                }
            }
        }
        
        if (oldestItem == nil) {
            break; // this can happen if the new file is bigger than the allowable cache size
        }
        else {
            // NSLog(@"Evicting %@", [oldestItem objectForKey:@"URL"]);
            [fileManager removeItemAtURL:[oldestItem objectForKey:@"URL"] error:nil];
            cacheSize = [self cacheSize];
        }
    }
    // NSLog(@"Creating file in cache at %@", [filename path]);
    [fileManager createFileAtPath:[filename path] contents:photoData attributes:nil];
}

-(NSURL *)cacheLocation {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSMutableArray *cacheLocations = [[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] mutableCopy];
    if (cacheLocations.count == 0) {
        return nil;
    }
    while ([cacheLocations count] > 0) {
        NSURL *cacheLocation = [[cacheLocations lastObject] filePathURL];
        if ([cacheLocation isFileURL]) {
            return cacheLocation;
        }
        [cacheLocations removeLastObject];
    }
    return nil;
}

-(NSDictionary *)cacheContents {
    NSURL *cacheLocation = [self cacheLocation];
    if (cacheLocation == nil) {
        return nil;
    }
    
    NSMutableArray *fileProperties = [[NSMutableArray alloc] initWithCapacity:6];
    [fileProperties addObject:NSURLFileSizeKey];
    [fileProperties addObject:NSURLContentAccessDateKey];
    [fileProperties addObject:NSURLContentModificationDateKey];
    [fileProperties addObject:NSURLCreationDateKey];
    [fileProperties addObject:NSURLIsRegularFileKey];
    [fileProperties addObject:NSURLIsReadableKey];

    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSDirectoryEnumerator *dirContents = [fileManager enumeratorAtURL:cacheLocation includingPropertiesForKeys:[fileProperties copy                                                                                                               ] options:NO errorHandler:nil];

    NSMutableDictionary *cacheContents = [[NSMutableDictionary alloc] init];
    NSArray *dateCheckOrder = [NSArray arrayWithObjects:
        NSURLContentAccessDateKey,
        NSURLContentModificationDateKey,
        NSURLCreationDateKey,
        nil
    ];
    for (NSURL *file in dirContents) {
        NSNumber *isThingTrue;
        // make sure we have something to enumerate
        if (file == nil) {
            continue;
        }
        if (![file isFileURL]) {
            continue;
        }
        
        // make sure it's readable
        [file getResourceValue:&isThingTrue forKey:NSURLIsReadableKey error:nil];
        if (![isThingTrue boolValue]) {
            continue;
        }
        
        // make sure it's a regular file
        [file getResourceValue:&isThingTrue forKey:NSURLIsRegularFileKey error:nil];
        if (![isThingTrue boolValue]) {
            continue;
        }
        
        // make sure it's a jpg
        if ([[file absoluteString] rangeOfString:@".jpg"].location == NSNotFound) {
            continue;
        }
                
        // get the best possible date
        NSDate *objectDate;
        for (NSString *dateType in dateCheckOrder) {
            [file getResourceValue:&objectDate forKey:dateType error:nil];
            if (!(objectDate == nil)) {
                break;
            }
        }
        if (objectDate == nil) {
            continue;
        }
        
        // get the file size
        NSNumber *fileSize;
        [file getResourceValue:&fileSize forKey:NSURLFileSizeKey error:nil];
        if (fileSize == nil) {
            continue;
        }
        
        [cacheContents setObject:@{@"Size":fileSize, @"Date":objectDate, @"URL":file} forKey:[file relativePath]];
    }
    
    return [cacheContents copy];
}

-(NSUInteger)cacheSize {
    NSDictionary *contents = [self cacheContents];
    if (contents == nil) {
        return 0;
    }
    
    NSUInteger sizeOfCache = 0;
    NSArray *files = [contents allKeys];
    // NSLog(@"Checking size of cache...");
    for (NSString *filename in files) {
        // NSLog(@"Adding %@: %d", filename, [[[contents objectForKey:filename] objectForKey:@"Size"] unsignedIntegerValue]);
        sizeOfCache += [[[contents objectForKey:filename] objectForKey:@"Size"] unsignedIntegerValue];
    }
    // NSLog(@"Size of cache: %d", sizeOfCache);
   
    return sizeOfCache;
}

@end
