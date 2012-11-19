//
//  FlickrSpotsRecentPhotosViewController.m
//  FlickrSpots
//
//  Created by Krawczyk, Pete on 11/1/12.
//  Copyright (c) 2012 Krawczyk, Pete. All rights reserved.
//

#import "FlickrSpotsRecentPhotosViewController.h"
#import "FlickrSpotsPhotoDisplayViewController.h"
#import "FlickrSpotsFavoriteStore.h"
#import "FlickrSpotsPhotoModel.h"
#import "FlickrFetcher/FlickrFetcher.h"

@interface FlickrSpotsRecentPhotosViewController ()
@property (strong, nonatomic) NSArray *viewed;
@end

@implementation FlickrSpotsRecentPhotosViewController

@synthesize delegate = _delegate;
@synthesize viewed = _viewed;

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setViewed:[FlickrSpotsFavoriteStore favoritePhotos]];
    [self.tableView reloadData];
}

-(void)configurePhotoDisplayViewController:(FlickrSpotsPhotoDisplayViewController *)pvc
                                 withPhoto:(id)photoObject
{
    [pvc setDelegate:self];
    [pvc setPhoto:photoObject];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPhoto"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSUInteger whichPhoto = [indexPath indexAtPosition:(indexPath.length - 1)];
        NSDictionary *photoObject = [self.viewed objectAtIndex:whichPhoto];
        [self configurePhotoDisplayViewController:segue.destinationViewController withPhoto:photoObject];
    }
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.viewed count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Recent Photo";
    // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    FlickrSpotsPhotoModel *photoModel = [FlickrSpotsPhotoModel initWithPhoto:[self.viewed objectAtIndex:indexPath.row]];
    cell.textLabel.text = photoModel.photoTitle;
    cell.detailTextLabel.text = photoModel.photoDescription;
    return cell;
}

#pragma mark - Table view delegate

-(FlickrSpotsPhotoDisplayViewController *)photoViewControllerFromSplitView {
    id pvc = [self.splitViewController.viewControllers lastObject];
    if (![pvc isKindOfClass:[FlickrSpotsPhotoDisplayViewController class]]) {
        pvc = nil;
    }
    return pvc;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id pvc = [self photoViewControllerFromSplitView];
    if (pvc) {
        id photoObject = [self.viewed objectAtIndex:indexPath.row];
        [self configurePhotoDisplayViewController:pvc withPhoto:photoObject];
    }
}

@end
