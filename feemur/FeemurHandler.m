//
//  FeemurHandler.m
//  feemur
//
//  Created by Zachary Nagengast on 8/24/13.
//  Copyright (c) 2013 Zauce Tech. All rights reserved.
//

#import "FeemurHandler.h"
#import "API.h"
#import "KeychainItemWrapper.h"
#import "LoginViewController.h"
#import "DTAlertView.h"

#define FEEMUR_LIST_KEY @"feemurLinks"
#define POCKET_LIST_KEY @"pocketLinks"
#define SAVED_LIST_KEY @"savedLinks"

@implementation FeemurHandler
@synthesize latestResponse, linklimit, loggedIn;

+(FeemurHandler*)sharedInstance
{
    static FeemurHandler *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

-(void)getLinks{
    NSLog(@"retrieving links from feemur");
    keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"FeemurLogin" accessGroup:nil];
    NSString *username = [keychainItem objectForKey:(__bridge id)(kSecValueData)];
    NSString *password = [keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             @"login",@"command",
                                             username,@"username",
                                             password,@"password",
                                             nil]
                               onCompletion:^(NSDictionary *json) {
                                   //completion
                                   NSLog(@"Feemur logged in: %@",json);
                                   if ([json objectForKey:@"error"]) {
                                       //show error message
                                       DTAlertView *message = [DTAlertView alertViewWithTitle:@"Feemur" message:@"Login Failed" delegate:nil cancelButtonTitle:@"Retry" positiveButtonTitle:nil];
                                       [message show];
                                       loggedIn = false;
                                   }else{
                                   //login worked, get feemur links
                                       loggedIn = true;
                                       LoginViewController *lv = [[LoginViewController alloc]init];
                                       [lv dismissView:nil];
                                       [self retrieveLinks];
                                       [self submitLinks];
                                   }
                               }];
}

-(void)submitLinks{
    NSLog(@"Submitting links to server...");
    pocket = [PocketHandler sharedInstance];
    NSMutableDictionary *submittedLinks = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           @"submitlinks",@"command",
                                           nil];
    //  check if the current had been saved previously (we only want to submit newly saved links)
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *pocketDict = [[defaults objectForKey:POCKET_LIST_KEY] mutableCopy];
    NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
    NSArray *keys = [[pocketDict  objectForKey:@"list" ]allKeys];
    NSMutableDictionary *savedDict = [[defaults objectForKey:SAVED_LIST_KEY] mutableCopy];
    for (int i=0; i< keys.count; i++) {
        id keyAtIndex = [keys objectAtIndex:i];
        id object = [[pocketDict objectForKey:@"list"] objectForKey:keyAtIndex];
//        NSString *pocketId = [object valueForKey:@"resolved_id"];
        if ([[savedDict valueForKey:keyAtIndex]  isEqualToString:@"1"]) {
            NSDictionary *addDict = [NSDictionary dictionaryWithObject:object forKey:keyAtIndex];
            [newDict addEntriesFromDictionary:addDict];
        }
    }
    if (newDict) {
        [submittedLinks addEntriesFromDictionary:[NSDictionary dictionaryWithObject:newDict forKey:@"list"]];
    }
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
}

-(void)login:(NSString *)username withPassword:(NSString *)password{
    keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"FeemurLogin" accessGroup:nil];
    [keychainItem setObject:username forKey:(__bridge id)(kSecValueData)];
    [keychainItem setObject:password forKey:(__bridge id)(kSecAttrAccount)];
}

-(void)logout{
    keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"FeemurLogin" accessGroup:nil];
    [keychainItem resetKeychainItem];
}

-(BOOL)hasLoginData{
    keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"FeemurLogin" accessGroup:nil];
    if ([keychainItem objectForKey:(__bridge id)(kSecAttrAccount)]){
        return TRUE;
    }else{
        return FALSE;
    }
}

-(void)retrieveLinks
{
    if (!data) {
        data = [[DataHandler alloc]init];
    }
    //linklimit set in view controller
    if (!linklimit) {
        linklimit = 30;
    }
    NSString *limitstring = [NSString stringWithFormat:@"%d",linklimit];
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             @"retrievelinks",@"command",
                                             limitstring, @"limit",
                                             nil]
                               onCompletion:^(NSDictionary *json) {
                                   //completion
                                   latestResponse = json;
                                   NSLog(@"Feemur response retrieved");
                                   //Save the links locally
                                   [data storeLinks:latestResponse forName:FEEMUR_LIST_KEY];
                               }];
}

-(void)increaseLinkLimit
{
    //check if there are even any new links coming in
    const int prevCount = [[latestResponse objectForKey:@"result"]count];
    if (prevCount >=linklimit) {
        //upgrade the limit
        linklimit = linklimit + 20;
        NSLog(@"New link limit %d", linklimit);
    }else{
        NSLog(@"No more links");
    }
}

@end
