//
//  DataHandler.h
//  feemur
//
//  Created by Zachary Nagengast on 9/6/13.
//  Copyright (c) 2013 Zauce Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataHandler : NSObject


-(void)storeLinks:(NSDictionary *)linkDictionary forName:(NSString *) listName;
-(void)addToSaved:(NSString *)newId;
-(void)removeFromSaved:(NSString *)newId;

+(DataHandler*)sharedInstance;

@end
