//
//  FlickrSpotsRecentPlacesViewController.m
//  FlickrSpots
//
//  Created by Krawczyk, Pete on 10/31/12.
//  Copyright (c) 2012 Krawczyk, Pete. All rights reserved.
//

#import "FlickrSpotsTopPlacesViewController.h"
#import "FlickrFetcher/FlickrFetcher.h"
#import "FlickrSpotsPlacePhotosViewController.h"

@interface FlickrSpotsTopPlacesViewController () <FlickrSpotsPlacePhotosViewControllerDelegate>

@end

@implementation FlickrSpotsTopPlacesViewController

@synthesize topPlaceStore = _topPlaceStore;

NSComparisonResult placeSort(NSDictionary *place1, NSDictionary *place2, void *context) {
    NSString *name1 = [[place1 valueForKey:@"_content"] lowercaseString];
    NSString *name2 = [[place2 valueForKey:@"_content"] lowercaseString];
    return [name1 compare:name2];
}

-(NSArray *)topPlaceStore {
    if (!_topPlaceStore) {
        NSArray *newTopPlaces;
        newTopPlaces = [[FlickrFetcher topPlaces] sortedArrayUsingFunction:placeSort context:NULL];
        self.topPlaceStore = newTopPlaces;
    }
    return _topPlaceStore;
}

-(void)setTopPlaceStore:(NSArray *)topPlaceStore {
    if (topPlaceStore != _topPlaceStore) {
        _topPlaceStore = topPlaceStore;
    }
    [self.tableView reloadData];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Choose Place"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSUInteger whichPlace = [indexPath indexAtPosition:(indexPath.length - 1)];
        NSDictionary *placeObject = [self.topPlaceStore objectAtIndex:whichPlace];
        [segue.destinationViewController setPlace:placeObject];
        [segue.destinationViewController setDescription:[[sender textLabel] text]];
        [segue.destinationViewController setDelegate:self];
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self topPlaceStore] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Recent Place";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *currentPlace = [self.topPlaceStore objectAtIndex:indexPath.row];
    NSString *placeName = [currentPlace valueForKey:@"_content"];
    NSRange firstComma = [placeName rangeOfString:@", "];
    if (firstComma.location == NSNotFound) {
        cell.textLabel.text = placeName;
        cell.detailTextLabel.text = @"";
    }
    else {
        cell.textLabel.text = [placeName substringToIndex:firstComma.location];
        NSUInteger detailStart = firstComma.location + firstComma.length;
        cell.detailTextLabel.text = [placeName substringFromIndex:detailStart];
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
