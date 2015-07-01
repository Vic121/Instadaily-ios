//
//  SubjectView.h
//  InstaDaily
//
//  Created by Marek Mikuliszyn on 11-05-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirstRunView.h"
#import "ServerConnect.h"

@interface SubjectView : UIViewController {
    NSTimer *countdownTimer;
}

@property (nonatomic, retain) IBOutlet UILabel *subjectLabel;
@property (nonatomic, retain) IBOutlet UILabel *dayCountLabel;
@property (nonatomic, retain) IBOutlet UILabel *hourCountLabel;
@property (nonatomic, retain) IBOutlet UILabel *minuteCountLabel;
@property (nonatomic, retain) IBOutlet UILabel *secondCountLabel;
@property (nonatomic, retain) IBOutlet UILabel *userPointLabel;
@property (nonatomic, retain) IBOutlet UILabel *userCurrentSubjectPointLabel;

@property (nonatomic, assign) NSDictionary *subjectDict;
@property (nonatomic, assign) NSDictionary *userDict;

- (void)downloadSubject;
- (void)countdown;

@end
