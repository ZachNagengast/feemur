//
//  FeedViewController.h
//  feemur
//
//  Created by Zachary Nagengast on 8/24/13.
//  Copyright (c) 2013 Zauce Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataHandler.h"
#import "PocketHandler.h"
#import "FeemurHandler.h"
#import "RESideMenu.h"

@interface FeedViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>{
    DataHandler *data;
    dispatch_queue_t queue;
    FeemurHandler *feemur;
    PocketHandler *pocket;
    NSDictionary *latestLinks;
    NSTimer *timeoutTimer;
    int timeout;
    UIActivityIndicatorView *activityIndicator;
    bool loadMoreToggle;
    bool isScrolling;
    CGFloat rowHeight;
}

@property(nonatomic,retain) NSTimer *timeoutTimer;
@property(nonatomic,retain) NSDictionary *latestLinks;
@property(nonatomic,retain) NSString *currentUrl;

-(void)feemurTimeout;
-(NSString *)timeSinceNow:(float)timestamp;
-(IBAction)showLogin:(id)sender;
-(IBAction)showMenu:(id)sender;
-(IBAction)showTitleMenu:(id)sender;

-(IBAction)refreshFeed:(id)sender;

@end
