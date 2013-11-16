//
//  LoginViewController.m
//  feemur
//
//  Created by Zachary Nagengast on 9/12/13.
//  Copyright (c) 2013 Zauce Tech. All rights reserved.
//

#import "LoginViewController.h"
#import "FeemurHandler.h"
#import "PocketHandler.h"
#import "API.h"
#import <CommonCrypto/CommonDigest.h>
#import "DTAlertView.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize username, password;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(IBAction)loginUser:(id)sender
{
    PocketHandler *pocket = [PocketHandler sharedInstance];
    FeemurHandler *feemur = [FeemurHandler sharedInstance];
    [feemur login:[username text] withPassword:[password text]];
    [self preformLogin];
}

-(IBAction)registerUser:(id)sender
{
    FeemurHandler *feemur = [FeemurHandler sharedInstance];
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             @"register",@"command",
                                             [username text],@"username",
                                             [self sha1:[password text]],@"password",
                                             nil]
                               onCompletion:^(NSDictionary *json) {
                                   //completion
                                   NSLog(@"Feemur registered: %@",json);
                                   if ([json objectForKey:@"error"]) {
                                       //show error message
                                       DTAlertView *message = [DTAlertView alertViewWithTitle:@"Feemur" message:[json objectForKey:@"error"] delegate:nil cancelButtonTitle:@"Ok" positiveButtonTitle:nil];
                                       [message show];
                                       feemur.loggedIn = false;
                                   }else{
                                       //register worked
                                       [feemur login:[username text] withPassword:[password text]];
                                       [self preformLogin];
                                   }
                               }];
}

-(void)preformLogin{
    NSString *sUsername =[username text];
    NSString *sPassword =[self sha1:[password text]];
    NSLog(@"%@ %@",sUsername, sPassword);
    FeemurHandler *feemur = [FeemurHandler sharedInstance];
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             @"login",@"command",
                                             sUsername,@"username",
                                             sPassword,@"password",
                                             nil]
                               onCompletion:^(NSDictionary *json) {
                                   //completion
                                   NSLog(@"Feemur logged in: %@",json);
                                   if ([json objectForKey:@"error"]) {
                                       //show error message
                                       DTAlertView *message = [DTAlertView alertViewWithTitle:@"Feemur" message:[json objectForKey:@"error"] delegate:nil cancelButtonTitle:@"Ok" positiveButtonTitle:nil];
                                       [message show];
                                       feemur.loggedIn = false;
                                   }else{
                                       //register worked
                                       [feemur login:[username text] withPassword:[password text]];
                                       feemur.loggedIn = true;
                                       [self dismissView:nil];
                                   }
                               }];
}

-(IBAction)dismissView:(id)sender
{
    NSLog(@"login dismissed and pocket logging in");
    PocketHandler *pocket = [PocketHandler sharedInstance];
    if ([pocket isLoggedIn] == NO) {
        [pocket login];
    }
    [self dismissModalViewControllerAnimated:YES];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
