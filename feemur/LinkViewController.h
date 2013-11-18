//
//  LinkViewController.h
//  feemur
//
//  Created by Zachary Nagengast on 10/19/13.
//  Copyright (c) 2013 Zauce Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedViewController.h"
#import "GADInterstitial.h"
#import "MCSwipeTableViewCell.h"

@interface LinkViewController : UIViewController <GADInterstitialDelegate, UIWebViewDelegate, NSURLConnectionDelegate, UIActionSheetDelegate>{
    // Declare one as an instance variable
    GADInterstitial *interstitial_;
    IBOutlet UIProgressView *progress;
    IBOutlet UIBarButtonItem *back;
    IBOutlet UIBarButtonItem *forward;
    NSMutableData *responseData;
    long _totalFileSize;
    long _receivedDataBytes;
}
@property (nonatomic,retain) IBOutlet UIProgressView *progress;
@property (nonatomic,retain) IBOutlet UIWebView *webView;
@property (nonatomic,retain) NSString *currentUrl;
@property (nonatomic) int addCount;
@property (nonatomic,retain) MCSwipeTableViewCell *selectedCell;
@property (nonatomic,retain) FeedViewController *feed;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *back;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *forward;

-(IBAction)showActionSheet:(id)sender;


@end
