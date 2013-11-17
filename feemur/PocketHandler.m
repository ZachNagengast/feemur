//
//  PocketHandler.m
//  feemur
//
//  Created by Zachary Nagengast on 8/1/13.
//  Copyright (c) 2013 Zauce Tech. All rights reserved.
//

#import "PocketHandler.h"
#import "PocketAPI.h"
#import "MCSwipeTableViewCell.h"
#import "DTAlertView.h"

#define POCKET_LIST_KEY @"pocketLinks"
#define FEEMUR_LIST_KEY @"feemurLinks"
#define SAVED_LIST_KEY @"savedLinks"

@implementation PocketHandler
@synthesize latestResponse, urlList,titleList,dateList;

#pragma mark - Singleton methods
/**
 * Singleton methods
 */
+(PocketHandler*)sharedInstance
{
    static PocketHandler *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

-(void)login{
    [[PocketAPI sharedAPI] loginWithHandler: ^(PocketAPI *API, NSError *error){
        if (error != nil)
        {
            // There was an error when authorizing the user. The most common error is that the user denied access to your application.
            // The error object will contain a human readable error message that you should display to the user
            // Ex: Show an UIAlertView with the message from error.localizedDescription
        }
        else
        {
            // The user logged in successfully, your app can now make requests.
            // [API username] will return the logged-in user’s username and API.loggedIn will == YES
            NSLog(@"Logged in as: %@", [API username]);
            pkt_API = API;
            loggedIn = API.loggedIn;
            [self getLinks];
        }
    }];
}

-(void)getLinks{
    NSLog(@"retrieving links from pocket");
    if (!data) {
        data = [DataHandler sharedInstance];
    }
    pkt_API = [PocketAPI sharedAPI];
    NSString *apiMethod = @"get";
    PocketAPIHTTPMethod httpMethod = PocketAPIHTTPMethodPOST; // usually PocketAPIHTTPMethodPOST
    NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
                               [pkt_API consumerKey], @"consumer_key",
                               [pkt_API pkt_getToken], @"access_token",
                               @"complete", @"detailType", nil];
    
    [[PocketAPI sharedAPI] callAPIMethod:apiMethod
                          withHTTPMethod:httpMethod
                               arguments:arguments
                                 handler: ^(PocketAPI *api, NSString *apiMethod, NSDictionary *response, NSError *error){
                                     // handle the response here
                                     if (error) {
                                         NSLog(@"%@",error);
                                     }
                                     
                                     latestResponse = response;
                                     //Save the links locally
                                     [data storeLinks:latestResponse forName:POCKET_LIST_KEY];
                                     
                                     //keep track of the links people have saved already
                                     NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
                                     NSMutableDictionary *savedDict = [[defaults objectForKey:SAVED_LIST_KEY] mutableCopy];
                                         NSDictionary *pocketDict = [response valueForKey:@"list"];
                                     if ([pocketDict count]>0) {
                                         NSArray *keys = [pocketDict allKeys];
                                         //  check if the current is in the users pocket already
                                         for (int i=0; i< keys.count; i++) {
                                             id keyAtIndex = [keys objectAtIndex:i];
                                             id object = [pocketDict objectForKey:keyAtIndex];
                                             NSString *pocketId = [object valueForKey:@"resolved_id"];
                                             [data addToSaved:pocketId];
                                         }
                                         NSLog(@"Pocket response retrieved: %d", keys.count);
                                         totalPocketLinks = keys.count;
                                         //remove links that were previously removed outside of app
                                         keys = [[defaults objectForKey:SAVED_LIST_KEY] allKeys];
                                         for (int i=0; i < keys.count; i++) {
                                             id keyAtIndex = [keys objectAtIndex:i];
                                             if (![pocketDict objectForKey:keyAtIndex]) {
                                                 [data removeFromSaved:keyAtIndex];
                                             }
                                         }
                                     }
                                     
#warning update the ui here
                                 }];
    return;
}

-(void)saveLink:(NSString *)urlString forCell:(MCSwipeTableViewCell *)cell{
    NSURL *url = [NSURL URLWithString:urlString];
    [[PocketAPI sharedAPI] saveURL:url handler: ^(PocketAPI *API, NSURL *URL, NSError *error){
        if(error){
            // there was an issue connecting to Pocket
            // present some UI to notify if necessary
            NSLog(@"Failed to save link: %@", urlString);
        }else{
            NSLog(@"Saved link: %@", urlString);
            // the URL was saved successfully
            DTAlertView *message = [DTAlertView alertViewWithTitle:@"Feemur" message:[NSString stringWithFormat:@"Saved \"%@\" to Pocket", cell.mainLabel.text] delegate:nil cancelButtonTitle:@"Close" positiveButtonTitle:nil];
            [message show];
        }
    }];
    return;
}

-(void)deleteLink:(NSString *)itemId forCell:(MCSwipeTableViewCell *)cell{
    pkt_API = [PocketAPI sharedAPI];
    NSString *apiMethod = @"send";
    NSArray *dictArray = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:
                         @"delete", @"action",
                         itemId, @"item_id",
                         nil]];
    PocketAPIHTTPMethod httpMethod = PocketAPIHTTPMethodPOST; // usually PocketAPIHTTPMethodPOST
    NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
                               [pkt_API consumerKey], @"consumer_key",
                               [pkt_API pkt_getToken], @"access_token",
                               dictArray,@"actions",
                               nil];
    
    [[PocketAPI sharedAPI] callAPIMethod:apiMethod
                          withHTTPMethod:httpMethod
                               arguments:arguments
                                 handler: ^(PocketAPI *api, NSString *apiMethod, NSDictionary *response, NSError *error){
                                     // handle the response here
                                     if (error) {
                                         NSLog(@"%@",error);
                                     }else{
                                         DTAlertView *message = [DTAlertView alertViewWithTitle:@"Feemur" message:[NSString stringWithFormat:@"Deleted \"%@\" from Pocket", cell.mainLabel.text] delegate:nil cancelButtonTitle:@"Close" positiveButtonTitle:nil];
                                         [message show];
                                     }
                                     
                                     NSLog(@"Item deleted %@",response);
                                     
                                 }];
    return;

}

-(void)interpretLinks{
    NSDictionary *dict = [latestResponse objectForKey:@"list"];
//    NSLog(@"%@",dict);
    NSArray *keys = [dict allKeys];
    urlList = [NSMutableArray arrayWithCapacity:keys.count];
    titleList = [NSMutableArray arrayWithCapacity:keys.count];
    dateList = [NSMutableArray arrayWithCapacity:keys.count];
    for (int i=0; i< keys.count; i++) {
        id keyAtIndex = [keys objectAtIndex:i];
        id object = [dict objectForKey:keyAtIndex];
        [urlList addObject:[object valueForKey:@"resolved_title"]];
        [titleList addObject:[object valueForKey:@"resolved_url"]];
        [dateList addObject:[object valueForKey:@"time_added"]];
    }
//    NSLog(@"%@",urlList);
//    NSLog(@"%@",titleList);
//    NSLog(@"%@",dateList);

}

-(BOOL)isLoggedIn{
    return [[PocketAPI sharedAPI] isLoggedIn];
}

-(void)logout{
    [[PocketAPI sharedAPI] logout];
}

@end
