//
//  DataHandler.m
//  feemur
//
//  Created by Zachary Nagengast on 9/6/13.
//  Copyright (c) 2013 Zauce Tech. All rights reserved.
//

#import "DataHandler.h"

@implementation DataHandler

-(void)storeLinks:(NSDictionary *)linkDictionary forName:(NSString *)listName
{
    NSLog(@"Storing new data for %@", listName);
    // pointer to standart user defaults
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:linkDictionary forKey:listName];
    // do not forget to save changes
    [defaults synchronize];
}

@end
