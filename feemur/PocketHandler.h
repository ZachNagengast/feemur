//
//  PocketHandler.h
//  feemur
//
//  Created by Zachary Nagengast on 8/1/13.
//  Copyright (c) 2013 Zauce Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PocketAPI.h"
#import "PocketAPILogin.h"
#import "DataHandler.h"
#import "MCSwipeTableViewCell.h"

@interface PocketHandler : NSObject{
    BOOL loggedIn;
    PocketAPI *pkt_API;
    PocketAPILogin *pkt_LOGIN;
    NSDictionary *latestResponse;
    NSMutableArray *urlList;
    NSMutableArray *titleList;
    NSMutableArray *dateList;
    DataHandler *data;
}

@property(nonatomic,retain) NSDictionary *latestResponse;
@property(nonatomic,retain) NSMutableArray *urlList;
@property(nonatomic,retain) NSMutableArray *titleList;
@property(nonatomic,retain) NSMutableArray *dateList;

-(void)getLinks;
-(void)saveLink:(NSString*)urlString forCell:(MCSwipeTableViewCell *)cell;
-(void)deleteLink:(NSString*)itemId forCell:(MCSwipeTableViewCell *)cell;
-(void)login;
-(BOOL)isLoggedIn;
-(NSString*)pocketUsername;
-(void)logout;

+(PocketHandler*)sharedInstance;


@end
