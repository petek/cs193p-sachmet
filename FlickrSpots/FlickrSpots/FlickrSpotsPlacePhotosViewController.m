//
//  FlickrSpotsPlacePhotosViewController.m
//  FlickrSpots
//
//  Created by Krawczyk, Pete on 10/31/12.
//  Copyright (c) 2012 Krawczyk, Pete. All rights reserved.
//

#import "FlickrSpotsPlacePhotosViewController.h"
#import "FlickrSpotsPhotoDisplayViewController.h"
#import "FlickrSpotsFavoriteStore.h"
#import "FlickrFetcher/FlickrFetcher.h"

@interface FlickrSpotsPlacePhotosViewController()
@property (nonatomic, strong) NSArray *placePhotos;
@end

@implementation FlickrSpotsPlacePhotosViewController

@synthesize delegate = _delegate;
@synthesize description = _description;
@synthesize place = _place;
@synthesize placePhotos = _placePhotos;

-(void)setPlace:(NSDictionary *)place
{
    _place = place;
    if (!self.description) {
        self.title = [place objectForKey:@"_content"];
    }
}

-(void)setDescription:(NSString *)description {
    _description = description;
    self.title = description;
}

-(NSArray *)placePhotos {
    if (!_placePhotos) {
        self.placePhotos = [FlickrFetcher photosInPlace:self.place maxResults:20];
    }
    return _placePhotos;
}

-(void)setPlacePhotos:(NSArray *)placePhotos {
    _placePhotos = placePhotos;
    [self.tableView reloadData];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPhoto"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSUInteger whichPhoto = [indexPath indexAtPosition:(indexPath.length - 1)];
        NSDictionary *photoObject = [self.placePhotos objectAtIndex:whichPhoto];
        [segue.destinationViewController setPhotoLocation:[FlickrFetcher urlForPhoto:photoObject format:FlickrPhotoFormatLarge]];
        [segue.destinationViewController setDescription:[[sender textLabel] text]];
        [segue.destinationViewController setDelegate:self];
        
        // and now add it to User defaults
        [FlickrSpotsFavoriteStore addFavoritePhoto:photoObject];
    }
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.placePhotos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Picture Selector";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSDictionary *currentPhoto = [self.placePhotos objectAtIndex:indexPath.row];
    NSString *titleString = [currentPhoto valueForKey:FLICKR_PHOTO_TITLE];
    NSString *descriptionString = [currentPhoto valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    if (titleString && ![titleString isEqualToString:@""]) {
        cell.textLabel.text = titleString;
        cell.detailTextLabel.text = descriptionString;
    }
    else if (descriptionString && ![descriptionString isEqualToString:@""]) {
        cell.textLabel.text = descriptionString;
        cell.detailTextLabel.text = @"";
    }
    else {
        cell.textLabel.text = @"Unknown";
        cell.detailTextLabel.text = @"";
    }

    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


@end
