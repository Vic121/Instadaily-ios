//
//  SubjectView.m
//  InstaDaily
//
//  Created by Marek Mikuliszyn on 11-05-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SubjectView.h"

@implementation SubjectView

@synthesize subjectDict, userDict;
@synthesize subjectLabel, dayCountLabel, hourCountLabel, minuteCountLabel, secondCountLabel, userPointLabel, userCurrentSubjectPointLabel;

- (void)downloadSubject {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs objectForKey:@"user_token"] == nil) {
        return;
    }
    
    NSDictionary *json = [ServerConnect getSubject];    
    if (json != nil) 
    {
        self.subjectDict = [json objectForKey:@"subject"];
        self.userDict = [json objectForKey:@"user"];
    
        [prefs setObject:self.userDict forKey:@"user"];
        [prefs setObject:self.subjectDict forKey:@"subject"];
        [prefs setInteger:60 forKey:@"counter_subject"];
    }
    else 
    {
        if ([prefs objectForKey:@"subject"] != nil && [prefs objectForKey:@"user"] != nil) 
        {
            self.subjectDict = [prefs objectForKey:@"subject"];
            self.userDict = [prefs objectForKey:@"user"];
            [self.subjectDict setValue:nil forKey:@"due"];
            [prefs setInteger:0 forKey:@"counter_subject"];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] init];
        [alert setTitle:@"Internet Connection"];
        [alert setMessage:@"Failed to download current subject, please check you connection."];
        [alert setDelegate:nil];
        [alert addButtonWithTitle:@"OK"];
        [alert show];
        [alert release];
        [prefs setInteger:0 forKey:@"counter_subject"];
    }
}

- (void)countdown {
    if ([self.dayCountLabel.text hasPrefix:@"-"] || [self.hourCountLabel.text hasPrefix:@"-"] || [self.minuteCountLabel.text hasPrefix:@"-"] || [self.secondCountLabel.text hasPrefix:@"-"]) {
        self.dayCountLabel.text = @"0";
        self.hourCountLabel.text = @"00";
        self.minuteCountLabel.text = @"00";
        self.secondCountLabel.text = @"00";
        [countdownTimer invalidate];
        countdownTimer = nil;
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setInteger:0 forKey:@"counter_subject"];
    }
    else {
        int secs = [self.secondCountLabel.text intValue];
        secs += [self.minuteCountLabel.text intValue] * 60;
        secs += [self.hourCountLabel.text intValue] * 3600;
        secs += [self.dayCountLabel.text intValue] * 3600 * 24;
        secs--;
        
        // day
        int day = secs / (24 * 3600);
        self.dayCountLabel.text = [NSString stringWithFormat:@"%d", day];
        secs -= day * (24 * 3600);
        
        // hour
        int hour = secs / 3600;
        self.hourCountLabel.text = [NSString stringWithFormat:@"%02d", hour];
        secs -= hour * 3600;
        
        // minute
        int minute = secs / 60;
        self.minuteCountLabel.text = [NSString stringWithFormat:@"%02d", minute];
        secs -= minute * 60;
        
        // second
        self.secondCountLabel.text = [NSString stringWithFormat:@"%02d", secs];
    }
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
    [[[UIApplication sharedApplication] delegate] addAnalytics:@"subject"];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs boolForKey:@"firstRun"] == YES) {
        FirstRunView *frv = [[FirstRunView alloc] initWithNibName:nil bundle:nil];
        [self.navigationController presentModalViewController:frv animated:YES];
        [frv release];
    }
    
    if (self.subjectDict == nil || [prefs integerForKey:@"counter_subject"] == 0) {
        [self downloadSubject];
        
        self.subjectLabel.text = [self.subjectDict objectForKey:@"name"];
        self.dayCountLabel.text = [[[self.subjectDict objectForKey:@"due"] objectForKey:@"day"] stringValue];
        self.hourCountLabel.text = [[self.subjectDict objectForKey:@"due"] objectForKey:@"hour"];
        self.minuteCountLabel.text = [[self.subjectDict objectForKey:@"due"] objectForKey:@"minute"];
        self.secondCountLabel.text = [[self.subjectDict objectForKey:@"due"] objectForKey:@"second"];
        
        self.userPointLabel.text = [[self.userDict objectForKey:@"points"] stringValue];
        if ([self.userDict objectForKey:@"last_subject_points"] != nil) {
            self.userCurrentSubjectPointLabel.text = [NSString stringWithFormat:@"+%@", [self.userDict objectForKey:@"last_subject_points"]];
        }
        if (countdownTimer == nil) {
            countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdown) userInfo:NULL repeats:YES];
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.subjectDict = nil;
    self.userDict = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
