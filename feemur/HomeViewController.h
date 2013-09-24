//
//  HomeViewController.h
//  feemur
//
//  Created by Zachary Nagengast on 8/24/13.
//  Copyright (c) 2013 Zauce Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataHandler.h"
#import "PocketHandler.h"

@interface HomeViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>{
    DataHandler *data;
    PocketHandler *pocket;
    NSDictionary *latestLinks;
    NSTimer *timeoutTimer;
    int timeout;
    UIActivityIndicatorView *activityIndicator;
}

@property(nonatomic,retain) NSTimer *timeoutTimer;
@property(nonatomic,retain) NSDictionary *latestLinks;

-(void)pocketTimeout;

-(IBAction)refreshHome:(id)sender;

@end
