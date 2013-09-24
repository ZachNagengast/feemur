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

@interface FeemurHandler : NSObject{
    BOOL loggedIn;
    NSDictionary *latestResponse;
    DataHandler *data;
    int linklimit;
    KeychainItemWrapper *keychainItem;
}

@property(nonatomic,retain) NSDictionary *latestResponse;
@property(nonatomic) int linklimit;
@property(nonatomic) BOOL loggedIn;

-(void)getLinks;
-(void)increaseLinkLimit;
-(BOOL)hasLoginData;
-(void)login:(NSString *)username withPassword:(NSString *)password;

@end
