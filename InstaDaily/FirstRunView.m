//
//  FirstRunView.m
//  InstaDaily
//
//  Created by Marek Mikuliszyn on 11-05-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FirstRunView.h"


@implementation FirstRunView

@synthesize webView;

- (IBAction) authButton {
    NSString *urlAddress = @"https://instagram.com/oauth/authorize/?client_id=2ee24a3169434caf8ee4af20ba84312d&redirect_uri=http://instadaily.appspot.com/auth/&response_type=code&scope=comments+likes+relationships&display=touch";
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:urlAddress]];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(15, 15, 290, 450)];
    self.webView.delegate = self;
    [self.webView loadRequest:requestObj];
    [self.view addSubview:self.webView]; 
    [self.webView release];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    HUD.delegate = self;
    HUD.labelText = @"Loading";
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    // indicator on
    [HUD show:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // indicator off
    [HUD hide:YES];
    
    // read content and dismiss window if access granted
    NSString *html = [webView stringByEvaluatingJavaScriptFromString: @"document.body.innerHTML"];
    
    if ([html hasPrefix:@"{\"status\": \"ok\""]) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        NSDictionary *json = [html yajl_JSON];
        NSDictionary *json_user = [json objectForKey:@"user"];
        [prefs setObject:[json objectForKey:@"token"] forKey:@"user_token"];
        [prefs setObject:[json_user objectForKey:@"id"] forKey:@"user_id"];
        [prefs setObject:[json_user objectForKey:@"instagram_id"] forKey:@"user_instagram_id"];
        [prefs setObject:[json_user objectForKey:@"name"] forKey:@"user_name"];
        [prefs setObject:[json_user objectForKey:@"pic"] forKey:@"user_pic"];
        [prefs setObject:[json_user objectForKey:@"points"] forKey:@"user_points"];
        
        [prefs setInteger:0 forKey:@"counter_subject"];
        [prefs setBool:NO forKey:@"firstRun"];
        [self dismissModalViewControllerAnimated:YES];
    }
}

/*
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"didFail: %@ stillLoading:%@ error code:%i", [[webView request]URL], (webView.loading?@"NO":@"YES"), [error code]);
    if ([error code] != -999) {
        // Handle your other errors here
    }
}
*/

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[[UIApplication sharedApplication] delegate] addAnalytics:@"hello"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.webView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
