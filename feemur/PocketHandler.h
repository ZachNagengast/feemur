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

@interface PocketHandler : NSObject{
    BOOL loggedIn;
    PocketAPI *pkt_API;
    PocketAPILogin *pkt_LOGIN;
    NSDictionary *latestResponse;
    NSMutableArray *urlList;
    NSMutableArray *titleList;
    NSMutableArray *dateList;
}

@property(nonatomic,retain) NSDictionary *latestResponse;
@property(nonatomic,retain) NSMutableArray *urlList;
@property(nonatomic,retain) NSMutableArray *titleList;
@property(nonatomic,retain) NSMutableArray *dateList;

-(void)getLinks;
-(void)saveLink:(NSString*)urlString;
-(void)login;
-(BOOL)isLoggedIn;
-(NSString*)pocketUsername;


@end
