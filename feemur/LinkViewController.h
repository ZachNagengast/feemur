//
//  LinkViewController.h
//  feemur
//
//  Created by Zachary Nagengast on 10/19/13.
//  Copyright (c) 2013 Zauce Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedViewController.h"

@interface LinkViewController : UIViewController

@property (nonatomic,retain) IBOutlet UIWebView *webView;
@property (nonatomic,retain) NSString *currentUrl;

@end
