//
//  ProfileView.h
//  InstaDaily
//
//  Created by Marek Mikuliszyn on 11-05-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "ServerConnect.h"
#import "Prefs.h"
#import "ProfileSubjectView.h"

@interface ProfileView : UIViewController <UIWebViewDelegate, UITableViewDelegate, MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}

@property (nonatomic, retain) IBOutlet UINavigationItem *nav;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *logoutBtn;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIImageView *avatar;
@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) IBOutlet UILabel *pointsLabel;

@property (nonatomic, retain) NSDictionary *profile;
@property (nonatomic, retain) NSArray *subjects;

- (void)fetchData;
- (IBAction) logout;

@end
