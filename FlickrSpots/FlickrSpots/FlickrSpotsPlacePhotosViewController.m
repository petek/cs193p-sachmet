//
//  FlickrSpotsPlacePhotosViewController.m
//  FlickrSpots
//
//  Created by Krawczyk, Pete on 10/31/12.
//  Copyright (c) 2012 Krawczyk, Pete. All rights reserved.
//

#import "FlickrSpotsPlacePhotosViewController.h"
#import "FlickrFetcher/FlickrFetcher.h"

@interface FlickrSpotsPlacePhotosViewController()

@property (nonatomic, weak) NSArray *placePhotos;

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
    return [self.placePhotos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Picture Selector";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *currentPhoto = [self.placePhotos objectAtIndex:indexPath.row];
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
