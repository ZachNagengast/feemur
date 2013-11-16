//
//  FeemurHandler.h
//  feemur
//
//  Created by Zachary Nagengast on 8/24/13.
//  Copyright (c) 2013 Zauce Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataHandler.h"
#import "KeychainItemWrapper.h"
#import "PocketHandler.h"

@interface FeemurHandler : NSObject{
    BOOL loggedIn;
    NSDictionary *latestResponse;
    DataHandler *data;
    PocketHandler *pocket;
    int linklimit;
    KeychainItemWrapper *keychainItem;
}

@property(nonatomic,retain) NSDictionary *latestResponse;
@property(nonatomic) int linklimit;
@property(nonatomic) BOOL loggedIn;

-(void)getLinks;
-(void)submitLinks;
-(void)increaseLinkLimit;
-(BOOL)hasLoginData;
-(void)login:(NSString *)username withPassword:(NSString *)password;
-(void)registerUser:(NSString *)username withPassword:(NSString *)password;
-(void)logout;

+(FeemurHandler*)sharedInstance;

@end
