//
//  FirstViewController.m
//  feemur
//
//  Created by Zachary Nagengast on 7/31/13.
//  Copyright (c) 2013 Zauce Tech. All rights reserved.
//

#import "FirstViewController.h"
#import "API.h"

@interface FirstViewController ()

@end

@implementation FirstViewController
@synthesize timeoutTimer, latestLinks;

- (void)viewDidLoad
{
    [super viewDidLoad];
    timeout = 0;
    
    pocket = [[PocketHandler alloc]init];
    if ([pocket isLoggedIn] == NO) {
        [pocket login];
    }else{
        //login to server
        [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 @"login",@"command",
                                                 @"zach",@"username",
                                                 @"password",@"password",
                                                 nil]
                                   onCompletion:^(NSDictionary *json) {
                                       //completion
                                       NSLog(@"Feemur logged in: %@",json);
         //get pocket links
                                       [pocket getLinks];
                                       timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:.1
                                                                                       target:self
                                                                                     selector:@selector(pocketTimeout)
                                                                                     userInfo:nil
                                                                                      repeats:YES];
                                   }];
        
    }
//    [pocket saveLink:@"http://google.com"];
    
}

-(void)pocketTimeout{
    timeout++;
    latestLinks = pocket.latestResponse;
    int linkCount = [[[latestLinks objectForKey:@"list"] allKeys] count];
    if (latestLinks && linkCount>=1){
        //handle the links
        [self updateLinks];
        [timeoutTimer invalidate];
        timeoutTimer = nil;
        timeout=0;
    }else if (timeout>= 60){
        NSLog(@"Pocket timed out or 0 links found");
        [timeoutTimer invalidate];
        timeoutTimer = nil;
        timeout=0;
    }else {
        NSLog(@"Waiting..");
    }
}

-(void)updateLinks{
    NSLog(@"Links found: %i", [[[latestLinks objectForKey:@"list"] allKeys] count]);
    //Talk to the server through the api with JSON stuff
    [self submitLinks];
//    NSLog(@"Retrieving links from server...");
//    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                             @"submitlinks",@"command",
//                                             @"http://www.google.com",@"urls",
//                                             nil]
//                               onCompletion:^(NSDictionary *json) {
//                                   
//                                   //completion
//                                   if (![json objectForKey:@"error"]) {
//                                       NSLog(@"Links submitted");
//                                       //success
//                                       [[[UIAlertView alloc]initWithTitle:@"Success!"
//                                                                message:@"Your urls have been posted!"
//                                                                delegate:nil
//                                                                cancelButtonTitle:@"Yay!"
//                                                                otherButtonTitles: nil] show];
//                                       
//                                   } else {
//                                       //error, check for expired session and if so - authorize the user
//                                       NSString* errorMsg = [json objectForKey:@"error"];
//                                       NSLog(@"Error: %@", errorMsg);
//                                   }
//                                   
//                               }];
    
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

@end
