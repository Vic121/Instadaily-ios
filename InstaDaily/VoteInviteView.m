//
//  VoteInviteView.m
//  InstaDaily
//
//  Created by Marek Mikuliszyn on 11-05-25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VoteInviteView.h"

@implementation VoteInviteView

@synthesize webView;

- (IBAction)closeWindow {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [HUD show:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [HUD hide:YES];
}

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
    
    NSString *urlAddress = @"http://twitter.com/home?status=hey%2C%20if%20you%20use%20Instagram%20this%20app%20is%20for%20you.%20Make%20photos%20based%20on%20current%20subject%20and%20compete%20with%20others%2C%20http%3A%2F%2Fbit.ly%2Finstadaily";
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:urlAddress]];
    [self.webView loadRequest:requestObj];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    HUD.delegate = self;
    HUD.labelText = @"Loading";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
