//
//  AppDelegate.h
//  feemur
//
//  Created by Zachary Nagengast on 7/31/13.
//  Copyright (c) 2013 Zauce Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PocketAPI.h"
#import "ICETutorialController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ICETutorialController *viewController;

@end
