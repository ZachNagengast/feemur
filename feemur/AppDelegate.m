//
//  AppDelegate.m
//  feemur
//
//  Created by Zachary Nagengast on 7/31/13.
//  Copyright (c) 2013 Zauce Tech. All rights reserved.
//

#import "AppDelegate.h"
#import "ICETutorialController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    NSString *deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPhone"])
    {
        [[PocketAPI sharedAPI] setConsumerKey:@"17051-ab7c88cebd4dd6037e6267cf"];
    }
    if([deviceType isEqualToString:@"iPad"]) {
        [[PocketAPI sharedAPI] setConsumerKey:@"17051-0ea35db855b04a1c86b7d8c8"];
    }
    if([deviceType isEqualToString:@"iPhone Simulator"])
    {
        [[PocketAPI sharedAPI] setConsumerKey:@"17051-ab7c88cebd4dd6037e6267cf"];
    }
    
    NSLog(@"Device: %@", deviceType);
    
    //Show welcome only once
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ( ![defaults boolForKey:@"notFirstRun"]) {
        // display alert...
        
   
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Init the pages texts, and pictures.
    ICETutorialPage *layer1 = [[ICETutorialPage alloc] initWithSubTitle:@"A network for Pocket users"
                                                            description:@"View and share\n interesting articles, videos or web pages "
                                                            pictureName:@"Slide1.png"];
    ICETutorialPage *layer2 = [[ICETutorialPage alloc] initWithSubTitle:@""
                                                            description:@"See interesting articles\n Pocket users have saved\n for later"
                                                            pictureName:@"Slide_two.jpg"];
    ICETutorialPage *layer3 = [[ICETutorialPage alloc] initWithSubTitle:@""
                                                            description:@"One screen. All the most\n relevant new media. "
                                                            pictureName:@"monumentWbdropin4.png"];
    ICETutorialPage *layer4 = [[ICETutorialPage alloc] initWithSubTitle:@""
                                                            description:@"A swipe away from\n your Pocket."
                                                            pictureName:@"monumentWCdropin4.png"];
    ICETutorialPage *layer5 = [[ICETutorialPage alloc] initWithSubTitle:@""
                                                            description:@"You're ready to go!"
                                                            pictureName:@"Slide1.png"];
    
    // Set the common style for SubTitles and Description (can be overrided on each page)
    ICETutorialLabelStyle *subStyle = [[ICETutorialLabelStyle alloc] init];
    [subStyle setFont:TUTORIAL_SUB_TITLE_FONT];
    [subStyle setTextColor:TUTORIAL_LABEL_TEXT_COLOR];
    [subStyle setLinesNumber:TUTORIAL_SUB_TITLE_LINES_NUMBER];
    [subStyle setOffset:TUTORIAL_SUB_TITLE_OFFSET];
    
    ICETutorialLabelStyle *descStyle = [[ICETutorialLabelStyle alloc] init];
    [descStyle setFont:TUTORIAL_DESC_FONT];
    [descStyle setTextColor:TUTORIAL_LABEL_TEXT_COLOR];
    [descStyle setLinesNumber:TUTORIAL_DESC_LINES_NUMBER];
    [descStyle setOffset:TUTORIAL_DESC_OFFSET];
    
    // Load into an array.
    NSArray *tutorialLayers = @[layer1,layer2,layer3,layer4,layer5];
    
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[ICETutorialController alloc] initWithNibName:@"ICETutorialController_iPhone"
                                                                      bundle:nil
                                                                    andPages:tutorialLayers];
    } 
    
    // Set the common styles, and start scrolling (auto scroll, and looping enabled by default)
    [self.viewController setCommonPageSubTitleStyle:subStyle];
    [self.viewController setCommonPageDescriptionStyle:descStyle];
    
    // Set button 1 (start button) action.
    [self.viewController setButton1Block:^(UIButton *button){
        [defaults setBool:YES forKey:@"notFirstRun"];
        [defaults synchronize];
        self.window.rootViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"rootViewController"];
        [self.window makeKeyAndVisible];
    }];
    
    // Set button 2 action, stop the scrolling.
    __unsafe_unretained typeof(self) weakSelf = self;
    [self.viewController setButton2Block:^(UIButton *button){
        NSLog(@"Button 2 pressed.");
        NSLog(@"Auto-scrolling stopped.");
        
        [weakSelf.viewController stopScrolling];
    }];
    
    // Run it.
//    [self.viewController startScrolling];
    
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
}
    return YES;
}

-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation{
    
    if([[PocketAPI sharedAPI] handleOpenURL:url]){
        return YES;
    }else{
        // if you handle your own custom url-schemes, do it here
        return NO;
    }
    
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
