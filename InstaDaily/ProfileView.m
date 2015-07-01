//
//  ProfileView.m
//  InstaDaily
//
//  Created by Marek Mikuliszyn on 11-05-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProfileView.h"

@implementation ProfileView

@synthesize nav, tableView, logoutBtn, usernameLabel, pointsLabel, avatar;
@synthesize profile, subjects;

- (void)fetchData {
    NSString *avatarFilename = [NSString stringWithFormat:@"%@.jpg", [self.profile objectForKey:@"name"]];
    self.avatar.image = [ServerConnect downloadAndReturnPhoto:[self.profile objectForKey:@"pic"] withName:avatarFilename];
    
    self.subjects = [ServerConnect getUserSubjects:[self.profile objectForKey:@"name"]];
    
    // fetch thumbs to display
    for (NSDictionary *subject in self.subjects) {
        if ([subject objectForKey:@"best_photo"] == [NSNull null]) {
            continue;
        }
        [ServerConnect downloadPhotoThumbs:[NSArray arrayWithObject:[subject objectForKey:@"best_photo"]]];
    }
    
    [self.tableView reloadData];
}

- (IBAction) logout {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:YES forKey:@"firstRun"];
    [prefs setInteger:0 forKey:@"counter_subject"];
    [prefs setInteger:0 forKey:@"counter_my_photos"];
    [prefs setInteger:0 forKey:@"counter_profile"];
    [prefs setInteger:0 forKey:@"counter_leaderboard"];
    
    NSString *urlAddress = @"https://instagram.com/accounts/logout/";
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:urlAddress]];
    
    UIWebView *webView = [[UIWebView alloc] init];
    webView.delegate = self;
    [webView loadRequest:requestObj];
//    [webView release];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = @"Logging out";
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    // indicator on
    [HUD show:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // indicator off
    [HUD hide:YES];
    [self.tabBarController setSelectedIndex:0];
}

- (void)dealloc
{
    [HUD release];
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
    
    [[[UIApplication sharedApplication] delegate] addAnalytics:@"profile"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.profile = nil;
    self.subjects = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (self.subjects == nil || [prefs integerForKey:@"counter_profile"] == 0) {
        
        if (self.profile == nil) {
            self.profile = [prefs objectForKey:@"user"];
        }
        
        self.usernameLabel.text = [self.profile objectForKey:@"name"];
        self.pointsLabel.text = [[self.profile objectForKey:@"points"] stringValue];
        
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.delegate = self;
        HUD.labelText = @"Loading";
        [HUD showWhileExecuting:@selector(fetchData) onTarget:self withObject:nil animated:YES];
        
        [prefs setInteger:60 forKey:@"counter_profile"];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.subjects count] == 0) {
        return 1;
    }
    return [self.subjects count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.subjects count] == 0) {
        UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        cell.textLabel.text = @"History of your subjects";
        cell.textLabel.textColor = [UIColor whiteColor];
        return cell;
    }
    
    static NSString *CellIdentifier = @"UserSubjectCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary *item = [self.subjects objectAtIndex:[indexPath row]];
    
    cell.textLabel.text = [[item objectForKey:@"subject"] objectForKey:@"name"];
    if ([[[item objectForKey:@"subject"] objectForKey:@"current"] intValue] == 1) {
        cell.detailTextLabel.text = @"current subject";
    }
    else if ([item objectForKey:@"best_photo"] == [NSNull null]) {
        cell.detailTextLabel.text = @"0 points";
    }
    else {
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_t.jpg", [[item objectForKey:@"best_photo"] objectForKey:@"instagram_id"]]];
        cell.imageView.image = [[[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:path]] autorelease];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"+%@ points", [item objectForKey:@"points"]];
    }
    
    if ([item objectForKey:@"best_photo"] != [NSNull null]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.subjects count] == 0 || ([self.subjects count] > 0 && [[self.subjects objectAtIndex:[indexPath row]] objectForKey:@"best_photo"] == [NSNull null])) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
//    NSLog(@"%@", [self.subjects objectAtIndex:[indexPath row]]);
    ProfileSubjectView *profileView = [[ProfileSubjectView alloc] initWithSubject:[self.subjects objectAtIndex:[indexPath row]]];
    profileView.username = [self.profile objectForKey:@"name"];
    [self.navigationController pushViewController:profileView animated:YES];
    [profileView release];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"History of your subjects";
}

@end
