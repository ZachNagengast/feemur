//
//  API.h
//  Review
//
//  Created by Zachary Nagengast on 10/20/12.
//  Copyright (c) 2012 Zachary Nagengast. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

//API call completion block with result as json
typedef void (^JSONResponseBlock)(NSDictionary* json);

@interface API : AFHTTPClient

//the authorized user
@property (strong, nonatomic) NSDictionary* user;

+(API*)sharedInstance;

//check whether there's an authorized user
-(BOOL)isAuthorized;

//send an API command to the server
-(void)commandWithParams:(NSMutableDictionary*)params onCompletion:(JSONResponseBlock)completionBlock;

-(NSURL*)urlForImageWithId:(NSNumber*)IdPhoto isThumb:(BOOL)isThumb;

@end
