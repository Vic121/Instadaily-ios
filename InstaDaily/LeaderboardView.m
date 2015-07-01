//
//  LeaderboardView.m
//  InstaDaily
//
//  Created by Marek Mikuliszyn on 11-05-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LeaderboardView.h"

@implementation LeaderboardView

@synthesize tableView;
@synthesize selectedContext, monthlyLeaderboard, overallLeaderboard, leaderboard;

- (IBAction)switchContext {
    if (self.selectedContext == @"monthly") {
        self.leaderboard = [self.overallLeaderboard copy];
        self.selectedContext = @"overall";
        self.navigationItem.title = @"General Ranking";
        self.navigationItem.rightBarButtonItem.title = @"Month";
    }
    else {
        self.leaderboard = [self.monthlyLeaderboard copy];
        self.selectedContext = @"monthly";
        self.navigationItem.title = @"Monthly Ranking";
        self.navigationItem.rightBarButtonItem.title = @"Overall";
    }
    [self.tableView reloadData];
}

- (void)fetchData {
    NSDictionary *tempLead = [ServerConnect getLeaderboard];
    
    // fetch avatars to display
    for (NSDictionary *l in [tempLead objectForKey:@"overall"]) {
        [ServerConnect downloadPhoto:[[l objectForKey:@"user"] objectForKey:@"pic"] withName:[NSString stringWithFormat:@"%@.jpg", [[l objectForKey:@"user"] objectForKey:@"name"]]];
    }
    
    for (NSDictionary *l in [tempLead objectForKey:@"month"]) {
        [ServerConnect downloadPhoto:[[l objectForKey:@"user"] objectForKey:@"pic"] withName:[NSString stringWithFormat:@"%@.jpg", [[l objectForKey:@"user"] objectForKey:@"name"]]];
    }
    
    self.monthlyLeaderboard = [tempLead objectForKey:@"month"];
    self.overallLeaderboard = [tempLead objectForKey:@"overall"];
    
    if (self.selectedContext == @"monthly") {
        self.leaderboard = [self.monthlyLeaderboard copy];
    }
    else {
        self.leaderboard = [self.overallLeaderboard copy];
    }
    
    [self.tableView reloadData];
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
    
    self.selectedContext = @"monthly";
    self.monthlyLeaderboard = [NSArray array];
    self.overallLeaderboard = [NSArray array];
    self.leaderboard = [NSArray array];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.monthlyLeaderboard = nil;
    self.overallLeaderboard = nil;
    self.leaderboard = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([self.leaderboard count] == 0 || [prefs integerForKey:@"counter_leaderboard"] == 0) {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.delegate = self;
        HUD.labelText = @"Loading";
        [HUD showWhileExecuting:@selector(fetchData) onTarget:self withObject:nil animated:YES];
        
        [prefs setInteger:7200 forKey:@"counter_leaderboard"];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.leaderboard count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"LeaderboardCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSDictionary *item = [self.leaderboard objectAtIndex:[indexPath row]];
    
    NSString *positions = @"";
    int pos_change = [[item objectForKey:@"position_change"] intValue];
    if (pos_change < 0) {
        positions = [NSString stringWithFormat:@", %d pos", pos_change];
    }
    else if ([[item objectForKey:@"position_change"] intValue] > 0) {
        positions = [NSString stringWithFormat:@", +%d pos", pos_change];
    }
    
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", [[item objectForKey:@"user"] objectForKey:@"name"]]];
    cell.imageView.image = [[[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:path]] autorelease];
    cell.textLabel.text = [NSString stringWithFormat:@"%@. %@", [item objectForKey:@"position"], [[item objectForKey:@"user"] objectForKey:@"name"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ points %@", [item objectForKey:@"points"], positions];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSDictionary *item = [[self.leaderboard objectAtIndex:[indexPath row]] objectForKey:@"user"];
    
    ProfileView *pv = [[ProfileView alloc] initWithNibName:nil bundle:nil];
    pv.profile = item;
    [self.navigationController pushViewController:pv animated:YES];
    [pv release];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
