//
//  LinkViewController.m
//  feemur
//
//  Created by Zachary Nagengast on 10/19/13.
//  Copyright (c) 2013 Zauce Tech. All rights reserved.
//

#import "LinkViewController.h"
#import "FeedViewController.h"

@interface LinkViewController ()

@end

@implementation LinkViewController
@synthesize webView;

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
    NSString *fullURL = self.currentUrl;
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView loadRequest:requestObj];
    webView.delegate = self;
//    NSLog(@"%@",self.currentUrl);
	// Do any additional setup after loading the view.
}

- (void)webViewDidFinishLoad:(UIWebView *)webview {
    if ([[webview stringByEvaluatingJavaScriptFromString:@"document.readyState"] isEqualToString:@"complete"]) {
        NSString* title = [webview stringByEvaluatingJavaScriptFromString: @"document.title"];
        [self.navigationController.navigationBar.topItem setTitle:title];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
