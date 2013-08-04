//
//  FirstViewController.m
//  feemur
//
//  Created by Zachary Nagengast on 7/31/13.
//  Copyright (c) 2013 Zauce Tech. All rights reserved.
//

#import "FirstViewController.h"

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
        [pocket getLinks];
        timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:.1
                                               target:self
                                             selector:@selector(pocketTimeout)
                                             userInfo:nil
                                              repeats:YES];
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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
