//
//  FirstViewController.h
//  feemur
//
//  Created by Zachary Nagengast on 7/31/13.
//  Copyright (c) 2013 Zauce Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PocketHandler.h"

@interface FirstViewController : UIViewController{
    PocketHandler *pocket;
    NSDictionary *latestLinks;
    NSTimer *timeoutTimer;
    int timeout;
}

@property(nonatomic,retain) NSTimer *timeoutTimer;
@property(nonatomic,retain) NSDictionary *latestLinks;

-(void)pocketTimeout;

@end
