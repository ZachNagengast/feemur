//
//  HomeViewController.m
//  feemur
//
//  Created by Zachary Nagengast on 8/24/13.
//  Copyright (c) 2013 Zauce Tech. All rights reserved.
//

#import "HomeViewController.h"
#import "API.h"

#define POCKET_LIST_KEY @"pocketLinks"

@interface HomeViewController ()

@end

@implementation HomeViewController
@synthesize timeoutTimer, latestLinks;

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
    timeout = 0;
    // initialize list with old links
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:POCKET_LIST_KEY]) {
        latestLinks = [defaults objectForKey:POCKET_LIST_KEY];
        [self updateLinks];
    }
    
    pocket = [[PocketHandler alloc]init];
    if ([pocket isLoggedIn] == NO) {
        [pocket login];
    }else{
        //login to server
         //fill home list with data
        [self refreshHome:nil];
    }
    
    
    //    [pocket saveLink:@"http://google.com"];
    
}

-(IBAction)refreshHome:(id)sender
{
    //update loading ui
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithCustomView:activityIndicator];
    self.navigationItem.rightBarButtonItem = barButton;
    [activityIndicator startAnimating];
    
    //get pocket links
    pocket.latestResponse = nil;
    [pocket getLinks];
    timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:.1
                                                    target:self
                                                  selector:@selector(pocketTimeout)
                                                  userInfo:nil
                                                   repeats:YES];
}

-(void)pocketTimeout
{
    timeout++;
    latestLinks = pocket.latestResponse;
    int linkCount = [[[latestLinks objectForKey:@"list"] allKeys] count];
    if (latestLinks && linkCount>=1){
        //handle the new links
        [self updateLinks];
        [self submitLinks];
        [timeoutTimer invalidate];
        timeoutTimer = nil;
        timeout=0;
        //update ui
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshHome:)];
        self.navigationItem.rightBarButtonItem = barButton;
    }else if (timeout>= 60){
        NSLog(@"Pocket timed out or 0 links found");
        //show error message
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Feemur"
                                                          message:@"Couldn't get the stuff"
                                                         delegate:nil
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
        [message show];
        [timeoutTimer invalidate];
        timeoutTimer = nil;
        timeout=0;
        //update ui
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshHome:)];
        self.navigationItem.rightBarButtonItem = barButton;
    }else {
        NSLog(@"Waiting..");
    }
}

-(void)updateLinks{
    NSLog(@"Links found: %i", [[[latestLinks objectForKey:@"list"] allKeys] count]);
    [self.tableView reloadData];
}

-(void)submitLinks{
    NSLog(@"Submitting links to server...");
    NSMutableDictionary *submittedLinks = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           @"submitlinks",@"command",
                                           nil];
    [submittedLinks addEntriesFromDictionary:[latestLinks mutableCopy]];
    [[API sharedInstance] commandWithParams:submittedLinks
                               onCompletion:^(NSDictionary *json) {
                                   //completion
                                   if (![json objectForKey:@"error"]) {
                                       NSLog(@"Links submitted");
                                       NSLog(@"Json: %@", json);
                                       //success
                                       
                                   } else {
                                       //error, check for expired session and if so - authorize the user
                                       NSString* errorMsg = [json objectForKey:@"error"];
                                       NSLog(@"Error: %@", errorMsg);
                                   }
                                   
                               }];
    
    //    NSLog(@"%@",submittedLinks);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[latestLinks objectForKey:@"list"] allKeys] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *dict = [latestLinks objectForKey:@"list"];
    NSArray *keys = [dict allKeys];
#warning sort by date once using multiple platforms!
    //  sort them by sort_id
    for (int i=0; i< keys.count; i++) {
     id keyAtIndex = [keys objectAtIndex:i];
     id object = [dict objectForKey:keyAtIndex];
     if (indexPath.row == [[object valueForKey:@"sort_id"] intValue]) {
        [cell.textLabel setText:[NSString stringWithFormat:@"%@", [object valueForKey:@"resolved_title"]]];
        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@", [object valueForKey:@"resolved_url"]]];
        }
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
