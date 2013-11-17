//
//  DataHandler.m
//  feemur
//
//  Created by Zachary Nagengast on 9/6/13.
//  Copyright (c) 2013 Zauce Tech. All rights reserved.
//

#import "DataHandler.h"

#define POCKET_LIST_KEY @"pocketLinks"
#define FEEMUR_LIST_KEY @"feemurLinks"
#define SAVED_LIST_KEY @"savedLinks"

@implementation DataHandler

+(DataHandler*)sharedInstance
{
    static DataHandler *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

-(void)resetDefaults{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:SAVED_LIST_KEY];
    [defaults removeObjectForKey:FEEMUR_LIST_KEY];
    [defaults removeObjectForKey:POCKET_LIST_KEY];
}


-(void)removeFromSaved:(NSString *)newId{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *savedDict = [[defaults objectForKey:SAVED_LIST_KEY] mutableCopy];
    if ([savedDict objectForKey:newId] != nil) {
        [savedDict setValue:@"0" forKey:newId];
        NSLog(@"Removed from saved");
    }
    NSDictionary *newDict = [savedDict copy];
    [defaults setObject:newDict forKey:SAVED_LIST_KEY];
    [defaults synchronize];
}

-(void)addToSaved:(NSString *)newId{
    NSLog(@"Added to saved");
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *savedDict = [NSMutableDictionary dictionary];
    if ([defaults objectForKey:SAVED_LIST_KEY]) {
        savedDict = [[defaults objectForKey:SAVED_LIST_KEY] mutableCopy];
    }
    NSDictionary *newDict =[NSDictionary dictionaryWithObjectsAndKeys:@"1", newId, nil];
    if ([savedDict objectForKey:newId] == nil) {
        [savedDict addEntriesFromDictionary:newDict];
    }else{
        [savedDict setValue:@"1" forKey:newId];
    }
    newDict = [savedDict copy];
    [defaults setObject:newDict forKey:SAVED_LIST_KEY];
    // do not forget to save changes
    [defaults synchronize];
}

-(void)storeLinks:(NSDictionary *)linkDictionary forName:(NSString *)listName
{
    NSLog(@"Storing new data for %@", listName);
    // pointer to standart user defaults
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:listName];
    [defaults setObject:linkDictionary forKey:listName];
    // do not forget to save changes
    [defaults synchronize];
}

-(BOOL)wasSaved:(NSString *)newId{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *savedDict = [[defaults objectForKey:SAVED_LIST_KEY] mutableCopy];
    if ([savedDict objectForKey:newId] != nil) {
        return TRUE;
    }else{
        return FALSE;
    }
}

@end
