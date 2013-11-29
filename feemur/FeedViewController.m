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
#import "ProgressHUD.h"
#import "DTAlertView.h"
#import "REMenu.h"
#import "GAI.h"

#define POCKET_LIST_KEY @"pocketLinks"
#define FEEMUR_LIST_KEY @"feemurLinks"
#define SAVED_LIST_KEY @"savedLinks"
#define FEED_PREFS_KEY @"feedKey"

@interface FeedViewController () <MCSwipeTableViewCellDelegate>

@property (strong, readwrite, nonatomic) REMenu *menu;

@end

@implementation FeedViewController
@synthesize latestLinks, timeoutTimer, titleLabel, selectedCell;

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
    queue = dispatch_queue_create("com.zaucetech.feemur",nil);
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // Sending the same screen view hit using [GAIDictionaryBuilder createAppView]
    [tracker send:[[[GAIDictionaryBuilder createAppView] set:@"Feed Screen"
                                                      forKey:kGAIScreenName] build]];
    

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:72/255.0 green:71/255.0 blue:67/255.0 alpha:1];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(reload:)];
    
    
//    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"EmptyList.png"]];
//    [backgroundView setBackgroundColor:[UIColor colorWithRed:227.0 / 255.0 green:227.0 / 255.0 blue:227.0 / 255.0 alpha:1.0]];
//    [self.tableView setBackgroundView:backgroundView];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    
    [refresh addTarget:self action:@selector(refreshFeed:)
      forControlEvents:UIControlEventValueChanged];
     [refresh setTintColor:[UIColor whiteColor]];
    self.refreshControl = refresh;

    
//    //Login if no login data already
//    if ([pocket isLoggedIn] == NO) {
//        [pocket login];
//    }else{
//        //get pocket links
//        pocket.latestResponse = nil;
//    }
    pocket = [PocketHandler sharedInstance];
    feemur = [FeemurHandler sharedInstance];
    data = [DataHandler sharedInstance];
    feemur.loggedIn = FALSE; //always login on first load
    defaults = [NSUserDefaults standardUserDefaults];
    if (!feemur.hasLoginData){
        [self showLogin:nil];
    }else{
        feemur.linklimit = 30;
        // initialize list with old links
        if ([defaults objectForKey:FEEMUR_LIST_KEY]) {
            latestLinks = [defaults objectForKey:FEEMUR_LIST_KEY];
            [self refreshFeed:nil];
        }
    }
    
    timeout = 0;
    
    allItem = [[REMenuItem alloc] initWithTitle:@"All Time"
                                                    subtitle:@""
                                                       image:nil
                                            highlightedImage:[UIImage imageNamed:@"selected"]
                                                      action:^(REMenuItem *item) {
                                                          [self updateMenu:item];
                                                          [self refreshFeed:nil];
                                                      }];
    
    monthItem = [[REMenuItem alloc] initWithTitle:@"This Month"
                                                          image:nil
                                               highlightedImage:[UIImage imageNamed:@"selected"]
                                                         action:^(REMenuItem *item) {
                                                             [self updateMenu:item];
                                                             [self refreshFeed:nil];
                                                         }];
    
    weekItem = [[REMenuItem alloc] initWithTitle:@"This Week"
                                                           image:nil
                                                highlightedImage:[UIImage imageNamed:@"selected"]
                                                          action:^(REMenuItem *item) {
                                                              [self updateMenu:item];
                                                              [self refreshFeed:nil];
                                                          }];
    
    todayItem = [[REMenuItem alloc] initWithTitle:@"Today"
                                                          image:nil
                                               highlightedImage:[UIImage imageNamed:@"selected"]
                                                         action:^(REMenuItem *item) {
                                                             [self updateMenu:item];
                                                             [self refreshFeed:nil];
                                                         }];
    
    self.menu = [[REMenu alloc] initWithItems:@[allItem, monthItem, weekItem, todayItem]];
    self.menu.liveBlur = YES;
    self.menu.liveBlurBackgroundStyle = REMenuLiveBackgroundStyleDark;
    if (![defaults objectForKey:FEED_PREFS_KEY]) {
        [self updateMenu:allItem];
    }else{
        NSLog(@"%@", [defaults valueForKey:FEED_PREFS_KEY]);
        NSArray *itemArray = @[allItem, monthItem, weekItem, todayItem];
        REMenuItem *item;
        for (int i=0; i<itemArray.count; i++) {
            item= itemArray[i];
            NSLog(@"%@",item.title);
            if ([item.title isEqualToString:[defaults valueForKey:FEED_PREFS_KEY]]) {
                [self updateMenu:item];
            }
        }
    }
    
}

-(void)updateMenu:(REMenuItem*)item{
    allItem.image = nil;
    monthItem.image = nil;
    weekItem.image = nil;
    todayItem.image = nil;
    item.image =[UIImage imageNamed:@"selected"];
    [defaults setObject:item.title forKey:FEED_PREFS_KEY];
    [defaults synchronize];
    [titleLabel setTitle:[NSString stringWithFormat:@"%@",[defaults valueForKey:FEED_PREFS_KEY]] forState:UIControlStateNormal];
//    [self refreshFeed:nil];
}

-(void)didDidAppear:(BOOL)animated{
 
    //update ui
//    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshFeed:)];
//    self.navigationItem.rightBarButtonItem = barButton;
}

-(void)showTitleMenu:(id)sender{
    if (self.menu.isOpen) {
        [self.menu close];
    }else{
    [self.menu showFromNavigationController:self.navigationController];
    }
}

//-(void)viewDidAppear:(BOOL)animated{
//    //make sure user is logged in
//    pocket = [PocketHandler sharedInstance];
//    feemur = [FeemurHandler sharedInstance];
//    data = [DataHandler sharedInstance];
//    if (!feemur.hasLoginData) [self showLogin:nil];
//    
//    feemur.linklimit = 30;
//    // initialize list with old links
//    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
//    if ([defaults objectForKey:FEEMUR_LIST_KEY]) {
//        latestLinks = [defaults objectForKey:FEEMUR_LIST_KEY];
//        [self updateLinks];
//    }
//}

-(void)feemurTimeout
{
    timeout++;
    latestLinks = feemur.latestResponse;
    latestPocketLinks = pocket.latestResponse;
    int linkCount = [latestLinks count];
    if (!feemur.hasLoginData) {
        [timeoutTimer invalidate];
        timeoutTimer = nil;
        timeout=0;
//        [ProgressHUD dismiss];
        [self showLogin:nil];
    }
    if ((latestPocketLinks && needsPocket) || (!pocket.isLoggedIn && needsPocket)){
        //get feemur links
        needsPocket = NO;
        feemur.latestResponse = nil;
        [feemur getLinks];
    }
    
    if (latestLinks && linkCount>=1){
        //handle the new links
//        [ProgressHUD dismiss];
//        [ProgressHUD showSuccess:@"Success"];
        [self stopRefresh];
        [self updateLinks];
        
        [timeoutTimer invalidate];
        timeoutTimer = nil;
        timeout=0;
        
    }
    else if (timeout>= 300){
        NSLog(@"Feemur timed out or 0 links found");
        //show error message
        DTAlertView *message = [DTAlertView alertViewWithTitle:@"Feemur" message:@"Unable to refresh feed." delegate:nil cancelButtonTitle:@"Close" positiveButtonTitle:nil];
        NSLog(@"%@",pocket.isLoggedIn?@"pocket is loggedin":@"pocket not loggedin");
        [message show];
        [timeoutTimer invalidate];
        timeoutTimer = nil;
        timeout=0;
        //update ui
//        UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshFeed:)];
//        self.navigationItem.rightBarButtonItem = barButton;
//        [ProgressHUD dismiss];
        [self stopRefresh];
    }
    else {
//        NSLog(@"Waiting.."); 
    }
}

-(void)updateLinks{
    NSLog(@"Links found: %i", [[latestLinks objectForKey:@"result"] count]);
    //update ui
//    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshFeed:)];
//    self.navigationItem.rightBarButtonItem = barButton;

    [timeoutTimer invalidate];
    timeoutTimer = nil;
    timeout=0;
    [self.tableView reloadData];
}

-(void)showLogin:(id)sender{
    LoginViewController *loginView = [[self storyboard]instantiateViewControllerWithIdentifier:@"loginView"];
    [self.navigationController presentModalViewController:loginView animated:YES];
}

-(IBAction)showMenu:(id)sender{
    NSLog(@"menu clicked");
    [self.sideMenuViewController presentMenuViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [timeoutTimer invalidate];
    timeoutTimer = nil;
    timeout=0;
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
    //make sure it is never a null list
    if (!latestLinks) {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:FEEMUR_LIST_KEY]) {
            latestLinks = [defaults objectForKey:FEEMUR_LIST_KEY];
        }
    }
    
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
    
    // We need to set a background to the content view of the cell
    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    
    // Setting the type of the cell
    [cell setMode:MCSwipeTableViewCellModeSwitch];
    cell.shouldAnimatesIcons = NO;
    
    // Configure the cell...
    [cell setAccessoryType:UITableViewCellAccessoryNone];
#warning sort by date once using multiple platforms!
    
    //show the main title
    [cell.mainLabel setLineBreakMode:NSLineBreakByWordWrapping];
    if ([NSString stringWithFormat:@"%@", [[[dict objectForKey:@"result"] objectAtIndex:indexPath.row] valueForKey:@"resolved_title"]].length >1) {
        [cell.mainLabel setText:[NSString stringWithFormat:@"%@", [[[dict objectForKey:@"result"] objectAtIndex:indexPath.row] valueForKey:@"resolved_title"]]];
    }else{
        [cell.mainLabel setText:[NSString stringWithFormat:@"%@", [[[dict objectForKey:@"result"] objectAtIndex:indexPath.row] valueForKey:@"given_title"]]];
    }

    //show the details
    cell.urlString = [[[dict objectForKey:@"result"] objectAtIndex:indexPath.row] valueForKey:@"resolved_url"];
    if (cell.urlString.length<=1) {
        cell.urlString = [[[dict objectForKey:@"result"] objectAtIndex:indexPath.row] valueForKey:@"given_url"];
    }
    [cell.descriptionLabel setText:[NSString stringWithFormat:@"%@", [[[dict objectForKey:@"result"] objectAtIndex:indexPath.row] valueForKey:@"excerpt"]]];
    [cell.urlLabel setText:[NSString stringWithFormat:@"%@ • by %@",[self shortenUrl:[[[dict objectForKey:@"result"] objectAtIndex:indexPath.row] valueForKey:@"resolved_url"]], [[[dict objectForKey:@"result"] objectAtIndex:indexPath.row] valueForKey:@"user_name"]]];
    //format the count and time labels
   
    // We need to provide the icon names and the desired colors
    if ([[[defaults objectForKey:SAVED_LIST_KEY] objectForKey:cell.itemId] intValue]>= 1) {
        [self setCellSaved:cell];
        cell.isSaved = true;
    }else{
        [self setCellUnsaved:cell];
        cell.isSaved = false;
    }
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
    rowHeight = newFrame.size.height+46+60;
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
    if (original.length>2) {
        NSRange startRange = [original rangeOfString:@"//"];
        NSRange deleteRange = NSMakeRange(0, startRange.location+startRange.length);
        original = [original stringByReplacingCharactersInRange:deleteRange withString:@""];
        NSRange endRange = [original rangeOfString:@"/"];
        //Make sure it doesnt blow up
        if (endRange.location<=30){
            deleteRange = NSMakeRange(endRange.location, original.length-endRange.location);
            original = [original stringByReplacingCharactersInRange:deleteRange withString:@""];
        }
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
    rowHeight = newFrame.size.height+46+60;
    return rowHeight;
}

-(IBAction)refreshFeed:(id)sender{
    //update loading ui
//    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithCustomView:activityIndicator];
//    self.navigationItem.rightBarButtonItem = barButton;
//    [activityIndicator startAnimating];
    
//    [ProgressHUD show:@"Please Wait..."];
    
    if ([pocket isLoggedIn] == NO) {
        feemur.loggedIn = NO;
    }else{
        //get pocket links and submit feemur links
        pocket.latestResponse = nil;
        feemur.latestResponse = nil;
        [pocket getLinks];
    }
    needsPocket = YES;
    timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:.1
                                                    target:self
                                                  selector:@selector(feemurTimeout)
                                                  userInfo:nil
                                                   repeats:YES];

    
//    //get feemur links
//    feemur.latestResponse = nil;
//    dispatch_async(queue, ^{
//        //get feemur links
//        [feemur getLinks];
//        if ([pocket isLoggedIn] == NO) {
//            [pocket login];
//        }else{
//            //get pocket links
//            pocket.latestResponse = nil;
//            [pocket getLinks];
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self updateLinks];
//            NSLog(@"dispatch done");
//        });
//    });
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    
    // This event will also be sent with &cd=Home%20Screen.
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                          action:@"touch"
                                                           label:@"Resfreshed"
                                                           value:nil] build]];
    
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
        [time setString:@""];
        [time appendString:[NSString stringWithFormat:@"%dd", (int)floor(diff/(60*60*24))]];
    }
    //hours
    if (diff<60*60*24) {
        [time setString:@""];
        [time appendString:[NSString stringWithFormat:@"%dh", (int)floor(diff/(60*60))]];
    }
    //minutes
    if (diff<60*60) {
        [time setString:@""];
        [time appendString:[NSString stringWithFormat:@"%dm", (int)floor(diff/(60))]];
    }
    //seconds
    if (diff<60) {
        [time setString:@""];
        [time appendString:[NSString stringWithFormat:@"%ds", (int)floor(diff)]];
    }
    //years
    if (diff>=60*60*24*365) {
        [time setString:@""];
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
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
#warning check if user is logged in before trying to saved
    if (state == MCSwipeTableViewCellState1) {
        [self saveToggle:cell];
    }
    if (state == MCSwipeTableViewCellState4) {
        selectedCell = cell;
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:@"Pocket"
                                      otherButtonTitles: @"Copy Link", @"Share", nil];
        [actionSheet showInView:self.view];
    }
}

-(void)saveToggle:(MCSwipeTableViewCell*)cell{
    if (cell.isSaved) {
        [self setCellUnsaved:cell];
        cell.isSaved = false;
        [pocket deleteLink:cell.itemId forCell:cell];
        NSLog(@"Unsaved cell: %@", [self.tableView indexPathForCell:cell]);
        //            cell.countTotal = [NSString stringWithFormat:@"%d",[cell.countTotal intValue]-1];
        NSString *countString = cell.countTotal;
        if ([cell.countTotal intValue] >= 10000 ) {
            countString = [NSString stringWithFormat:@"%4.1fk",[countString floatValue]/1000];
        }
        [cell.countLabel setText:countString];
        //set it to unsaved in the list & database
        //            [data removeFromSaved:cell.itemId];
    }else{
        [self setCellSaved:cell];
        cell.isSaved = true;
        [pocket saveLink:cell.urlString forCell:cell];
        //update count only if it hasnt been saved before
        if (![data wasSaved:cell.itemId]) {
            cell.countTotal = [NSString stringWithFormat:@"%d",[cell.countTotal intValue]+1];
        }
        NSString *countString = cell.countTotal;
#warning eventually take care of larger counts
        if ([cell.countTotal intValue] >= 10000 ) {
            countString = [NSString stringWithFormat:@"%4.1fk",[countString floatValue]/1000];
        }
        [cell.countLabel setText:countString];
        NSLog(@"Saved cell: %@", [self.tableView indexPathForCell:cell]);
        //            [data addToSaved:cell.itemId];
        //            [feemur submitLinks];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    //Get the name of the current pressed button
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if  ([buttonTitle isEqualToString:@"Pocket"]) {
        [self saveToggle:selectedCell];
    }
    if ([buttonTitle isEqualToString:@"Copy Link"]) {
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        [pb setString:selectedCell.urlString];
        NSLog(@"Pasteboard: %@",pb.string);
        [ProgressHUD showSuccess:@"Copied Link"];
    }
    if ([buttonTitle isEqualToString:@"Share"]) {
        NSString *shareText = @"Via Feemur App";
        NSURL *shareURL = [NSURL URLWithString:selectedCell.urlString];
        
        UIActivity *activity = [[UIActivity alloc] init];
        
        NSArray *activityItems = @[shareURL, shareText];
        NSArray *applicationActivities = @[activity];
        NSArray *excludeActivities = @[];
        
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
        activityController.excludedActivityTypes = excludeActivities;
        
        [self presentViewController:activityController animated:YES completion:^{
            NSLog(@"Activity complete");
        }];
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
    self.selectedCell = cell;
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
        detailViewController.selectedCell = self.selectedCell;
        detailViewController.feed = self;
        if (addCount<=3) {
            addCount= addCount +1;
            detailViewController.addCount = addCount;
        }else{
            addCount = 0;
        }
    }
}


//Detect when the user has reached the bottom
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    isScrolling = TRUE;
    CGFloat height = scrollView.frame.size.height;
    
    CGFloat contentYoffset = scrollView.contentOffset.y;
    
    CGFloat distanceFromBottom = scrollView.contentSize.height - contentYoffset;
    
#warning load more than 30 links here
//    if(distanceFromBottom < height)
//    {
//        if (loadMoreToggle==TRUE) {
//            NSLog(@"end of the table");
//            [self loadMoreData];
//            loadMoreToggle = FALSE;
//        }
//    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSLog(@"stopped scrolling");
    loadMoreToggle = TRUE;
}

- (void)stopRefresh
{
    [self.refreshControl endRefreshing];
}

//UI methods
- (void)setCellSaved:(MCSwipeTableViewCell *)cell{
    [cell setFirstStateIconName:@"pocket-icon_saved.png"
                     firstColor:[UIColor whiteColor]
            secondStateIconName:@"pocket-icon.png"
                    secondColor:[UIColor whiteColor]
                  thirdIconName:@"more-icon.png"
                     thirdColor:[UIColor whiteColor]
                 fourthIconName:@"more-icon.png"
                    fourthColor:[UIColor whiteColor]];
    //change label color
    [cell.countLabel setTextColor:[UIColor redColor]];
}

- (void)setCellUnsaved:(MCSwipeTableViewCell *)cell{
    [cell setFirstStateIconName:@"pocket-icon.png"
                     firstColor:[UIColor whiteColor]
            secondStateIconName:@"pocket-icon_saved.png"
                    secondColor:[UIColor whiteColor]
                  thirdIconName:@"more-icon.png"
                     thirdColor:[UIColor whiteColor]
                 fourthIconName:@"more-icon.png"
                    fourthColor:[UIColor whiteColor]];
    
    [cell.countLabel setTextColor:[UIColor darkTextColor]];
}

@end
