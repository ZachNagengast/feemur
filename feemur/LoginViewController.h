//
//  LoginViewController.h
//  feemur
//
//  Created by Zachary Nagengast on 9/12/13.
//  Copyright (c) 2013 Zauce Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController{
    IBOutlet UITextField *username;
    IBOutlet UITextField *password;
}

@property (nonatomic, retain) IBOutlet UITextField *username;
@property (nonatomic, retain) IBOutlet UITextField *password;

-(IBAction)loginUser:(id)sender;
-(IBAction)registerUser:(id)sender;
-(IBAction)dismissView:(id)sender;


@end
