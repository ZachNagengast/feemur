//
//  LoginViewController.m
//  feemur
//
//  Created by Zachary Nagengast on 9/12/13.
//  Copyright (c) 2013 Zauce Tech. All rights reserved.
//

#import "LoginViewController.h"
#import "FeemurHandler.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize username, password;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(IBAction)loginUser:(id)sender
{
    FeemurHandler *feemur = [[FeemurHandler alloc]init];
    [feemur login:[username text] withPassword:[password text]];
    [feemur getLinks];
    [self dismissView:nil];
}

-(IBAction)dismissView:(id)sender
{
    NSLog(@"login dismissed");
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
