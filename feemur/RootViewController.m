//
//  RootViewController.m
//  feemur
//
//  Created by Zachary Nagengast on 10/23/13.
//  Copyright (c) 2013 Zauce Tech. All rights reserved.
//

#import "RootViewController.h"
#import "MenuViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

-(void)awakeFromNib{
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menuController"];
    self.backgroundImage = [UIImage imageNamed:@"background.png"];
    self.delegate = (MenuViewController *)self.menuViewController;
}

@end
