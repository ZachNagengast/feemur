//
//  LinkViewController.m
//  feemur
//
//  Created by Zachary Nagengast on 10/19/13.
//  Copyright (c) 2013 Zauce Tech. All rights reserved.
//

#import "LinkViewController.h"
#import "FeedViewController.h"
#import "GADInterstitial.h"
#import "ProgressHUD.h"

@interface LinkViewController ()

@end

@implementation LinkViewController
@synthesize webView, back, forward;

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
    
    //load ad
    interstitial_ = [[GADInterstitial alloc] init];
    [interstitial_ setDelegate:self];
    interstitial_.adUnitID = @"a1527d9e9f1c696";
    if (self.addCount >=3) {//determines how often to load an ad
        self.addCount = 0;
        GADRequest *request = [GADRequest request];
        [interstitial_ loadRequest:request];
        request.testDevices = [NSArray arrayWithObjects:@"35fc1a6db48b646709d7dcb0184b015b", nil];
    }
    
    NSString *fullURL = self.currentUrl;
    NSURL *url = [NSURL URLWithString:fullURL];
    NSMutableURLRequest *requestObj = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:60];
    
    [[NSURLConnection alloc] initWithRequest:requestObj delegate:self];
    [webView loadRequest:requestObj];
    webView.delegate = self;
//    NSLog(@"%@",self.currentUrl);
	// Do any additional setup after loading the view.
}

-(void)interstitialDidReceiveAd:(GADInterstitial *)ad{
    [interstitial_ presentFromRootViewController:self];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _totalFileSize = response.expectedContentLength;
    responseData = [[NSMutableData alloc] init];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    _receivedDataBytes += [data length];
    progress.progress = _receivedDataBytes / (float)_totalFileSize;
    [responseData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"finished loading");
}



- (void)webViewDidFinishLoad:(UIWebView *)webview {
    if ([[webview stringByEvaluatingJavaScriptFromString:@"document.readyState"] isEqualToString:@"complete"]) {
        NSString* title = [webview stringByEvaluatingJavaScriptFromString: @"document.title"];
        [self.navigationController.navigationBar.topItem setTitle:title];
    }
    if ([webview canGoBack]) {
        [back setEnabled:TRUE];
    }else{
        [back setEnabled:FALSE];
    }
    if ([webview canGoForward]) {
        [forward setEnabled:TRUE];
    }else{
        [forward setEnabled:FALSE];
    }
}

-(IBAction)showActionSheet:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:@"Pocket"
                                  otherButtonTitles: @"Copy Link", @"Share", nil];
    [actionSheet showInView:self.view];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    //Get the name of the current pressed button
    FeedViewController *feedView = self.feed;
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if  ([buttonTitle isEqualToString:@"Pocket"]) {
        [feedView saveToggle:feedView.selectedCell];
    }
    if ([buttonTitle isEqualToString:@"Copy Link"]) {
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        [pb setString:self.selectedCell.urlString];
        NSLog(@"Pasteboard: %@",pb.string);
        [ProgressHUD showSuccess:@"Copied Link"];
    }
    if ([buttonTitle isEqualToString:@"Share"]) {
        NSString *shareText = @"Via Feemur App";
        NSURL *shareURL = [NSURL URLWithString:self.selectedCell.urlString];
        
        UIActivity *activity = [[UIActivity alloc] init];
        
        NSArray *activityItems = @[shareURL, shareText];
        NSArray *applicationActivities = @[activity];
        NSArray *excludeActivities = @[];
        
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
        activityController.excludedActivityTypes = excludeActivities;
        
        [self presentViewController:activityController animated:YES completion:^{
            NSLog(@"Activity complete");
        }];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
