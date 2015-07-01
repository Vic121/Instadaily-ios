//
//  ProfileSubjectView.h
//  InstaDaily
//
//  Created by Marek Mikuliszyn on 11-05-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "ServerConnect.h"
#import "Prefs.h"

@interface ProfileSubjectView : UIViewController <UIScrollViewDelegate, MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, copy) NSString *username;
@property (nonatomic, retain) NSDictionary *subjectDict;
@property (nonatomic, retain) NSArray *subjectPhotos;

- (id)initWithSubject:(NSDictionary *)subjectDict;
- (void)fetchData;

@end
