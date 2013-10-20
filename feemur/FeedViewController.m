//
//  FeedViewController.m
//  feemur
//
//  Created by Zachary Nagengast on 8/24/13.
//  Copyright (c) 2013 Zauce Tech. All rights reserved.
//

#import "FeedViewController.h"
#import "LoginViewController.h"
#import "PocketHandler.h"
#import "MCSwipeTableViewCell.h"
#import "LinkViewController.h"

#define POCKET_LIST_KEY @"pocketLinks"
#define FEEMUR_LIST_KEY @"feemurLinks"

@interface FeedViewController () <MCSwipeTableViewCellDelegate>

@end

@implementation FeedViewController
@synthesize latestLinks, timeoutTimer;

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
    
    NSLog(@"Feed view loaded");
    
    self.title = @"Feed";
    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(reload:)];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [backgroundView setBackgroundColor:[UIColor colorWithRed:227.0 / 255.0 green:227.0 / 255.0 blue:227.0 / 255.0 alpha:1.0]];
    [self.tableView setBackgroundView:backgroundView];
    
    pocket = [[PocketHandler alloc]init];
    feemur = [[FeemurHandler alloc]init];
    feemur.linklimit = 30;
    //Login if no login data already
    if (!feemur.hasLoginData) {
        [self showLogin:nil];
    }else{
        [feemur getLinks];
    }
    
    timeout = 0;
    
    [self refreshFeed:nil];

    self.clearsSelectionOnViewWillAppear = YES;
 
}

-(void)viewDidAppear:(BOOL)animated{
    // initialize list with old links
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:FEEMUR_LIST_KEY]) {
        latestLinks = [defaults objectForKey:FEEMUR_LIST_KEY];
        [self updateLinks];
    }
}

-(void)feemurTimeout
{
    timeout++;
    latestLinks = feemur.latestResponse;
    int linkCount = [latestLinks count];
    if (latestLinks && linkCount>=1){
        //handle the new links
        [self updateLinks];
        
    }else if (timeout>= 60){
        NSLog(@"Feemur timed out or 0 links found");
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
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshFeed:)];
        self.navigationItem.rightBarButtonItem = barButton;
    }
    else {
        NSLog(@"Waiting..");
    }
}

-(void)updateLinks{
    NSLog(@"Links found: %i", [[latestLinks objectForKey:@"result"] count]);
    [self.tableView reloadData];
    
    [timeoutTimer invalidate];
    timeoutTimer = nil;
    timeout=0;
    //update ui
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshFeed:)];
    self.navigationItem.rightBarButtonItem = barButton;
}

-(void)showLogin:(id)sender{
    LoginViewController *loginView = [[self storyboard]instantiateViewControllerWithIdentifier:@"loginView"];
    [self.navigationController presentModalViewController:loginView animated:YES];
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
    return [[latestLinks objectForKey:@"result"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    NSDictionary *dict = latestLinks;
    
    MCSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[MCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // For the delegate callback
    [cell setDelegate:self];
    
    //find if saved and update the ui
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    cell.itemId = [[[dict objectForKey:@"result"] objectAtIndex:indexPath.row] valueForKey:@"resolved_id"];
    if (pocket.isLoggedIn && [defaults objectForKey:POCKET_LIST_KEY]) {
        int currentId = [cell.itemId intValue];
        
        NSDictionary *pocketDict = [[defaults objectForKey:POCKET_LIST_KEY] objectForKey:@"list"];
        NSArray *keys = [pocketDict allKeys];
        //  check if the current is in the users pocket already
        for (int i=0; i< keys.count; i++) {
            id keyAtIndex = [keys objectAtIndex:i];
            id object = [pocketDict objectForKey:keyAtIndex];
            int pocketId = [[object valueForKey:@"resolved_id"] intValue];
            if (currentId == pocketId) {
                cell.isSaved = true;
            }
        }
    }else{
        cell.isSaved = false;
    }
    
    // We need to provide the icon names and the desired colors
    if (cell.isSaved) {
        [self setCellSaved:cell];
    }else{
        [self setCellUnsaved:cell];
    }
    
    // We need to set a background to the content view of the cell
    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    
    // Setting the type of the cell
    [cell setMode:MCSwipeTableViewCellModeNone];
    cell.shouldAnimatesIcons = NO;
    
    // Configure the cell...
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
#warning sort by date once using multiple platforms!
    
    //show the main title
    [cell.mainLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [cell.mainLabel setText:[NSString stringWithFormat:@"%@", [[[dict objectForKey:@"result"] objectAtIndex:indexPath.row] valueForKey:@"resolved_title"]]];

    //show the details
    [cell.descriptionLabel setText:[NSString stringWithFormat:@"%@", [[[dict objectForKey:@"result"] objectAtIndex:indexPath.row] valueForKey:@"excerpt"]]];
    [cell.urlLabel setText:[NSString stringWithFormat:@"%@ • by %@",[self shortenUrl:[[[dict objectForKey:@"result"] objectAtIndex:indexPath.row] valueForKey:@"resolved_url"]], [[[dict objectForKey:@"result"] objectAtIndex:indexPath.row] valueForKey:@"user_name"]]];
    cell.urlString = [[[dict objectForKey:@"result"] objectAtIndex:indexPath.row] valueForKey:@"resolved_url"];
    //format the count and time labels
    NSString *countString = [[[dict objectForKey:@"result"] objectAtIndex:indexPath.row] valueForKey:@"count"];
    cell.countTotal = countString;
    if ([countString intValue] >= 10000 ) {
        countString = [NSString stringWithFormat:@"%4.1fk",[countString floatValue]/1000];
    }
    [cell.countLabel setText:countString];
    [cell.timeLabel setText:[self timeSinceNow:[[[[dict objectForKey:@"result"] objectAtIndex:indexPath.row] valueForKey:@"time_added"] floatValue]]];
    
    //format the description label
    CGFloat oldHeight = cell.mainLabel.frame.size.height;
    CGSize maximumLabelSize = CGSizeMake(cell.mainLabel.frame.size.width, FLT_MAX);
    CGSize expectedLabelSize = [cell.mainLabel.text sizeWithFont:cell.mainLabel.font constrainedToSize:maximumLabelSize lineBreakMode:cell.mainLabel.lineBreakMode];
    CGRect newFrame = cell.mainLabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    rowHeight = newFrame.size.height+46;
    [cell.descriptionLabel setCenter:CGPointMake(cell.descriptionLabel.frame.origin.x+cell.descriptionLabel.frame.size.width/2, rowHeight-15)];
    
    //Create very last cell for loading more data
//    if (indexPath.row == [[latestLinks objectForKey:@"result"] count]-1) {
//        [cell.textLabel setText:@"Load more"];
//        [cell.detailTextLabel setText:@""];
//        cell.userInteractionEnabled = false;
//    }
    return cell;
    
}

-(NSString *)shortenUrl:(NSString*)original{
    NSRange startRange = [original rangeOfString:@"//"];
    NSRange deleteRange = NSMakeRange(0, startRange.location+startRange.length);
    original = [original stringByReplacingCharactersInRange:deleteRange withString:@""];
    NSRange endRange = [original rangeOfString:@"/"];
    //Make sure it doesnt blow up
    if (endRange.location<=30){
        deleteRange = NSMakeRange(endRange.location, original.length-endRange.location);
        original = [original stringByReplacingCharactersInRange:deleteRange withString:@""];
    }
    return original;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCSwipeTableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    CGFloat oldHeight = cell.mainLabel.frame.size.height;
    CGSize maximumLabelSize = CGSizeMake(cell.mainLabel.frame.size.width, FLT_MAX);
    CGSize expectedLabelSize = [cell.mainLabel.text sizeWithFont:cell.mainLabel.font constrainedToSize:maximumLabelSize lineBreakMode:cell.mainLabel.lineBreakMode];
    CGRect newFrame = cell.mainLabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    cell.mainLabel.frame = newFrame;
    rowHeight = newFrame.size.height+46;
    return rowHeight;
}

-(IBAction)refreshFeed:(id)sender{
    //update loading ui
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithCustomView:activityIndicator];
    self.navigationItem.rightBarButtonItem = barButton;
    [activityIndicator startAnimating];
    
    //get feemur links
    feemur.latestResponse = nil;
    [feemur getLinks];
    timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:.1
                                                    target:self
                                                  selector:@selector(feemurTimeout)
                                                  userInfo:nil
                                                   repeats:YES];
}

-(void)loadMoreData{
    [feemur increaseLinkLimit];
    [self refreshFeed:nil];
}

-(NSString *)timeSinceNow:(float)timestamp{
    NSMutableString *time = [[NSMutableString alloc]init];
    NSTimeInterval ti = [[NSDate date] timeIntervalSince1970];
    float diff = ti - timestamp;
    //days
    if (diff<60*60*24*365) {
        [time appendString:[NSString stringWithFormat:@"%dd", (int)floor(diff/(60*60*24))]];
    }
    //hours
    if (diff<60*60*24) {
        [time appendString:[NSString stringWithFormat:@"%dh", (int)floor(diff/(60*60))]];
    }
    //minutes
    if (diff<60*60) {
        [time appendString:[NSString stringWithFormat:@"%dm", (int)floor(diff/(60))]];
    }
    //seconds
    if (diff<60) {
        [time appendString:[NSString stringWithFormat:@"%ds", (int)floor(diff)]];
    }
    //years
    if (diff>=60*60*24*365) {
        [time appendString:[NSString stringWithFormat:@"%dy", (int)floor(diff/(60*60*24*365))]];
    }
    //check if its not singular (plural) - add 's' if so
//    if (![[time substringToIndex:2] isEqualToString:@"1 "]) {
//        [time appendString:@"s"];
//    }
    return time;
}

#pragma mark - MCSwipeTableViewCellDelegate

- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode
{
    NSLog(@"IndexPath : %@ - MCSwipeTableViewCellState : %d - MCSwipeTableViewCellMode : %d", [self.tableView indexPathForCell:cell], state, mode);
}

// When the user starts swiping the cell this method is called
- (void)swipeTableViewCellDidStartSwiping:(MCSwipeTableViewCell *)cell {
    NSLog(@"Did start swiping the cell!");
}


/*
 // When the user is dragging, this method is called and return the dragged percentage from the border
 - (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didSwipWithPercentage:(CGFloat)percentage {
 NSLog(@"Did swipe with percentage : %f", percentage);
 }
 */

- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didEndSwipingSwipingWithState:(MCSwipeTableViewCellState)state mode:(MCSwipeTableViewCellMode)mode {
    
    //User saved to pocket
#warning check if user is logged in before trying to saved
    if (state == MCSwipeTableViewCellState1) {
        if (cell.isSaved) {
            [self setCellUnsaved:cell];
            cell.isSaved = false;
            [pocket deleteLink:cell.itemId forCell:cell];
            NSLog(@"Unsaved cell: %@", [self.tableView indexPathForCell:cell]);
            cell.countTotal = [NSString stringWithFormat:@"%d",[cell.countTotal intValue]-1];
            NSString *countString = cell.countTotal;
            if ([cell.countTotal intValue] >= 10000 ) {
                countString = [NSString stringWithFormat:@"%4.1fk",[countString floatValue]/1000];
            }
            [cell.countLabel setText:countString];
        }else{
            [self setCellSaved:cell];
            cell.isSaved = true;
            [pocket saveLink:cell.urlString forCell:cell];
            //update count
            cell.countTotal = [NSString stringWithFormat:@"%d",[cell.countTotal intValue]+1];
            NSString *countString = cell.countTotal;
            if ([cell.countTotal intValue] >= 10000 ) {
                countString = [NSString stringWithFormat:@"%4.1fk",[countString floatValue]/1000];
            }
            [cell.countLabel setText:countString];
            NSLog(@"Saved cell: %@", [self.tableView indexPathForCell:cell]);
        }
    }
    if (state == MCSwipeTableViewCellState4) {
        self.currentUrl = cell.urlString;
        [self performSegueWithIdentifier:@"detail" sender:self];
    }
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

//    MCTableViewController *tableViewController = [[MCTableViewController alloc] init];
//    [self.navigationController pushViewController:tableViewController animated:YES];
    
    MCSwipeTableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    self.currentUrl = cell.urlString;
    [self performSegueWithIdentifier:@"detail" sender:self];
    
//    pocket = [[PocketHandler alloc]init];
//    NSDictionary *dict = latestLinks;
//    NSString *url = [[[dict objectForKey:@"result"] objectAtIndex:indexPath.row] valueForKey:@"resolved_url"];
//    [pocket saveLink:url];
//    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Feemur"
//                                                      message:[NSString stringWithFormat:@"Saved %@ to Pocket", url]
//                                                     delegate:nil
//                                            cancelButtonTitle:@"Awesome"
//                                            otherButtonTitles:nil];
//    [message show];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([[segue identifier] isEqualToString:@"detail"]) {
        LinkViewController *detailViewController = [segue destinationViewController];
        detailViewController.currentUrl = self.currentUrl;
    }
}


//Detect when the user has reached the bottom
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    isScrolling = TRUE;
    CGFloat height = scrollView.frame.size.height;
    
    CGFloat contentYoffset = scrollView.contentOffset.y;
    
    CGFloat distanceFromBottom = scrollView.contentSize.height - contentYoffset;
    
    if(distanceFromBottom < height)
    {
        if (loadMoreToggle==TRUE) {
            NSLog(@"end of the table");
            [self loadMoreData];
            loadMoreToggle = FALSE;
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSLog(@"stopped scrolling");
    loadMoreToggle = TRUE;
}

//UI methods
- (void)setCellSaved:(MCSwipeTableViewCell *)cell{
    [cell setFirstStateIconName:@"pocket-icon_saved@2x.png"
                     firstColor:[UIColor colorWithRed:227.0 / 255.0 green:227.0 / 255.0 blue:227.0 / 255.0 alpha:1.0]
            secondStateIconName:@"pocket-icon@2x.png"
                    secondColor:[UIColor colorWithRed:227.0 / 255.0 green:227.0 / 255.0 blue:227.0 / 255.0 alpha:1.0]
                  thirdIconName:nil
                     thirdColor:nil
                 fourthIconName:nil
                    fourthColor:nil];
    //change label color
    [cell.countLabel setTextColor:[UIColor redColor]];
}

- (void)setCellUnsaved:(MCSwipeTableViewCell *)cell{
    [cell setFirstStateIconName:@"pocket-icon@2x.png"
                     firstColor:[UIColor colorWithRed:227.0 / 255.0 green:227.0 / 255.0 blue:227.0 / 255.0 alpha:1.0]
            secondStateIconName:@"pocket-icon_saved@2x.png"
                    secondColor:[UIColor colorWithRed:227.0 / 255.0 green:227.0 / 255.0 blue:227.0 / 255.0 alpha:1.0]
                  thirdIconName:nil
                     thirdColor:nil
                 fourthIconName:nil
                    fourthColor:nil];
    
    [cell.countLabel setTextColor:[UIColor darkTextColor]];
}

@end