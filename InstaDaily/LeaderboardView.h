//
//  LeaderboardView.h
//  InstaDaily
//
//  Created by Marek Mikuliszyn on 11-05-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "ServerConnect.h"
#import "ProfileView.h"

@interface LeaderboardView : UIViewController <MBProgressHUDDelegate, UITableViewDelegate> {
    MBProgressHUD *HUD;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, assign) NSString *selectedContext;
@property (nonatomic, retain) NSArray *monthlyLeaderboard;
@property (nonatomic, retain) NSArray *overallLeaderboard;
@property (nonatomic, retain) NSArray *leaderboard;

- (IBAction)switchContext;
- (void)fetchData;

@end
