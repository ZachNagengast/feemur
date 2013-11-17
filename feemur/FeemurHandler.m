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
#import <CommonCrypto/CommonDigest.h>

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
    //check if has a session already (dont log in every request)
    if (loggedIn == false){
    NSLog(@"getLinks() initiated from feemur");
    keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"FeemurLogin" accessGroup:nil];
    NSString *username = [keychainItem objectForKey:(__bridge id)(kSecValueData)];
    NSString *password = [keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             @"login",@"command",
                                             username,@"username",
                                             [self sha1:password],@"password",
                                             nil]
                               onCompletion:^(NSDictionary *json) {
                                   //completion
                                   NSLog(@"Feemur logged in: %@",json);
                                   if ([json objectForKey:@"error"]) {
                                       //show error message
//                                       DTAlertView *message = [DTAlertView alertViewWithTitle:@"Feemur" message:@"Login Failed" delegate:nil cancelButtonTitle:@"Retry" positiveButtonTitle:nil];
//                                       [message show];
                                       loggedIn = false;
                                   }else{
                                   //login worked, get feemur links
                                       loggedIn = true;
                                       [self submitLinks];
                                   }
                               }];
    }else{
        //already logged in, get feemur links
        loggedIn = true;
        [self submitLinks];
    }
}

-(void)submitLinks{
    pocket = [PocketHandler sharedInstance];
    NSMutableDictionary *submittedLinks = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           @"submitlinks",@"command",
                                           nil];
    //  check if the current had been saved previously (we only want to submit newly saved links)
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *pocketDict = [[defaults objectForKey:POCKET_LIST_KEY] mutableCopy];
    NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
    if ([[pocketDict  objectForKey:@"list" ] count]>0) {
    NSArray *keys = [[pocketDict  objectForKey:@"list" ]allKeys];
    NSMutableDictionary *savedDict = [[defaults objectForKey:SAVED_LIST_KEY] mutableCopy];
    for (int i=0; i< keys.count; i++) {
        id keyAtIndex = [keys objectAtIndex:i];
        id object = [[[pocketDict objectForKey:@"list"] objectForKey:keyAtIndex] mutableCopy];
        //dont send the images (takes too much bandwidth)
        [object removeObjectForKey:@"images"];
//        NSString *pocketId = [object valueForKey:@"resolved_id"];
        if ([[savedDict valueForKey:keyAtIndex] isEqualToString:@"1"] && ([[object objectForKey:@"sort_id"]intValue]<=30)) {
            NSDictionary *addDict = [NSDictionary dictionaryWithObject:object forKey:keyAtIndex];
            [newDict addEntriesFromDictionary:addDict];
        }
    }
     
    if (newDict) {
        [submittedLinks addEntriesFromDictionary:[NSDictionary dictionaryWithObject:newDict forKey:@"list"]];
    }
    
    NSLog(@"Submitting links to feemur server: %d", [[[submittedLinks objectForKey:@"list"] allKeys] count]);
        if ([[[submittedLinks objectForKey:@"list"] allKeys] count]>0) {
            [[API sharedInstance] commandWithParams:submittedLinks
                               onCompletion:^(NSDictionary *json) {
                                   //completion
                                   if (![json objectForKey:@"error"]) {
                                       NSLog(@"Links submitted");
                                       NSLog(@"Json: %@", json);
                                       //success, now get the updated list from the server
                                       [self retrieveLinks];
                                       
                                   } else {
                                       //error, check for expired session and if so - authorize the user
                                       NSString* errorMsg = [json objectForKey:@"error"];
                                       NSLog(@"Error: %@", errorMsg);
                                   }
                                   
                               }];
        }else{
            //feemur user has 0 links to submit
            [self retrieveLinks];
        }

    }else{
        //new pocket user (has 0 links to submit)
        [self retrieveLinks];
    }
    

}

-(void)login:(NSString *)username withPassword:(NSString *)password{
    keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"FeemurLogin" accessGroup:nil];
    [keychainItem setObject:username forKey:(__bridge id)(kSecValueData)];
    [keychainItem setObject:password forKey:(__bridge id)(kSecAttrAccount)];
}

-(void)registerUser:(NSString *)username withPassword:(NSString *)password{
    
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             @"register",@"command",
                                             username,@"username",
                                             [self sha1:password],@"password",
                                             nil]
                               onCompletion:^(NSDictionary *json) {
                                   //completion
                                   NSLog(@"Feemur registered: %@",json);
                                   if ([json objectForKey:@"error"]) {
                                       //show error message
                                       //                                       DTAlertView *message = [DTAlertView alertViewWithTitle:@"Feemur" message:@"Login Failed" delegate:nil cancelButtonTitle:@"Retry" positiveButtonTitle:nil];
                                       //                                       [message show];
                                       loggedIn = false;
                                   }else{
                                       //register worked, login
                                       loggedIn = true;
                                       LoginViewController *lv = [[LoginViewController alloc]init];
                                       [lv dismissView:nil];
                                       
                                       [self login:username withPassword:password];
                                   }
                               }];
}

-(void)logout{
    keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"FeemurLogin" accessGroup:nil];
    [keychainItem resetKeychainItem];
    pocket = [PocketHandler sharedInstance];
    [pocket logout];
    data = [DataHandler sharedInstance];
//    [data resetDefaults];
}

-(BOOL)hasLoginData{
    keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"FeemurLogin" accessGroup:nil];
//    NSLog(@"Login Data: %@",[keychainItem objectForKey:(__bridge id)(kSecAttrAccount)]);
    if (![[keychainItem objectForKey:(__bridge id)(kSecAttrAccount)] isEqualToString:@""]){
        return TRUE;
    }else{
        return FALSE;
    }
}

-(void)retrieveLinks
{
    //only happens after links are submitted
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

-(NSString*) sha1:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *datasha = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(datasha.bytes, datasha.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
    
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
