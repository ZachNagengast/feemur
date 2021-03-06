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
#import "MCSwipeTableViewCell.h"
#import "REMenu.h"

@interface FeedViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>{
    DataHandler *data;
    dispatch_queue_t queue;
    FeemurHandler *feemur;
    PocketHandler *pocket;
    NSDictionary *latestLinks;
    NSDictionary *latestPocketLinks;
    NSTimer *timeoutTimer;
    int timeout;
    UIActivityIndicatorView *activityIndicator;
    bool needsPocket;
    bool loadMoreToggle;
    bool isScrolling;
    CGFloat rowHeight;
    IBOutlet UIButton *titleLabel;
    int addCount;
    MCSwipeTableViewCell *selectedCell;
    REMenuItem *allItem;
    REMenuItem *monthItem;
    REMenuItem *weekItem;
    REMenuItem *todayItem;
    NSUserDefaults *defaults;
}

@property(nonatomic,retain) NSTimer *timeoutTimer;
@property(nonatomic,retain) NSDictionary *latestLinks;
@property(nonatomic,retain) NSString *currentUrl;
@property(nonatomic,retain) IBOutlet UIButton *titleLabel;

@property(nonatomic,retain) MCSwipeTableViewCell *selectedCell;

-(void)feemurTimeout;
-(NSString *)timeSinceNow:(float)timestamp;
-(IBAction)showLogin:(id)sender;
-(IBAction)showMenu:(id)sender;
-(IBAction)showTitleMenu:(id)sender;
-(void)saveToggle:(MCSwipeTableViewCell*)cell;


-(IBAction)refreshFeed:(id)sender;

@end
