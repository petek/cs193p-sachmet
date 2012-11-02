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
#import "FlickrSpots/FlickrFetcher/FlickrFetcher.h"

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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPhoto"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSUInteger whichPhoto = [indexPath indexAtPosition:(indexPath.length - 1)];
        NSDictionary *photoObject = [self.viewed objectAtIndex:whichPhoto];
        [segue.destinationViewController setPhotoLocation:[FlickrFetcher urlForPhoto:photoObject format:2]];
        [segue.destinationViewController setDescription:[[sender textLabel] text]];
        [segue.destinationViewController setDelegate:self];
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
    NSDictionary *currentPhoto = [self.viewed objectAtIndex:indexPath.row];
    if ([currentPhoto valueForKey:@"title"]) {
        cell.textLabel.text = [currentPhoto valueForKey:@"title"];
        cell.detailTextLabel.text = [[currentPhoto valueForKey:@"description"] valueForKey:@"_content"];
    }
    else if ([[currentPhoto valueForKey:@"description"] valueForKey:@"_content"]) {
        cell.textLabel.text = [[currentPhoto valueForKey:@"description"] valueForKey:@"_content"];
    }
    else {
        cell.textLabel.text = @"Unknown";
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
