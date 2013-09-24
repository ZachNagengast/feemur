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

#define POCKET_LIST_KEY @"pocketLinks"

@implementation PocketHandler
@synthesize latestResponse, urlList,titleList,dateList;

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
        data = [[DataHandler alloc]init];
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
                                     NSLog(@"Pocket response retrieved");
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
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Feemur"
                                                              message:[NSString stringWithFormat:@"Saved %@ to Pocket", urlString]
                                                             delegate:nil
                                                    cancelButtonTitle:@"Ok"
                                                    otherButtonTitles:nil];
            message.show;
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
                                         UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Feemur"
                                                                                           message:[NSString stringWithFormat:@"Deleted %@ from Pocket", cell.urlLabel.text]
                                                                                          delegate:nil
                                                                                 cancelButtonTitle:@"Ok"
                                                                                 otherButtonTitles:nil];
                                         message.show;
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

@end
