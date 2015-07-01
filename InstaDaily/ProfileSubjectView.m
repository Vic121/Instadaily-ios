//
//  ProfileSubjectView.m
//  InstaDaily
//
//  Created by Marek Mikuliszyn on 11-05-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProfileSubjectView.h"

@implementation ProfileSubjectView

@synthesize scrollView;
@synthesize subjectDict, subjectPhotos, username;

- (id)initWithSubject:(NSDictionary *)subjectDict {
    self.subjectDict = subjectDict;
    
//    NSLog(@"subject = %@", self.subjectDict);
    self.navigationItem.title = [[self.subjectDict objectForKey:@"subject"] objectForKey:@"name"];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = @"Loading";
    [HUD showWhileExecuting:@selector(fetchData) onTarget:self withObject:nil animated:YES];
    
    return self;
}

- (void)fetchData {
    NSLog(@"%@", self.username);
    
    self.subjectPhotos = [ServerConnect getUserSubjectPhotos:[[self.subjectDict objectForKey:@"subject"] objectForKey:@"id"] forUser:self.username];
//    [ServerConnect downloadPhotos:self.subjectPhotos];
    [ServerConnect downloadPhotoThumbs:self.subjectPhotos];
    
    // clean up
    for (UIView *subview in self.scrollView.subviews) {
        [subview removeFromSuperview];
    }
    
    // add images to view
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	self.scrollView.scrollEnabled = YES;
    
    CGFloat curXLoc = 3;
    CGFloat curYLoc = 3;
    
    NSUInteger i = 1;
    for (NSDictionary *imgDict in self.subjectPhotos) {
        NSString *imageName = [NSString stringWithFormat:@"%@_t.jpg", [imgDict objectForKey:@"instagram_id"]];
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:imageName];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            continue;
        }
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(curXLoc, curYLoc+150, 150, 12)];
        label.font = [UIFont fontWithName:@"Courier-Bold" size:12];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor colorWithRed:106 green:74 blue:60 alpha:0];
        if ([[imgDict objectForKey:@"total_score"] intValue] == 1) {
            label.text = [NSString stringWithFormat:@"#%d 1 point", i];
        }
        else {
            label.text = [NSString stringWithFormat:@"#%d %@ points", (i == 1 ? i : i-1), [imgDict objectForKey:@"total_score"]];
        }
        
        UIImage *tempImg = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:path]];
        UIImageView *img = [[UIImageView alloc] initWithImage:tempImg];
        [tempImg release];
        
		CGRect rect = img.frame;
        rect.size = CGSizeMake(150, 150);
        
        if (i == 1) {
            rect.origin = CGPointMake(100, curYLoc);
            label.frame = CGRectMake(100, curYLoc+150, 150, 12);
//            curYLoc += 170;
            i++;
        }
        else {
            rect.origin = CGPointMake(curXLoc, curYLoc);
        }
        
		img.frame = rect;
		img.tag = i;
		[self.scrollView addSubview:img];
        [self.scrollView addSubview:label];
        
        if (i % 2 == 0) {
            curXLoc  = 3;
            curYLoc += 170;
        }
        else {
            curXLoc += 160;
        }
        
        [label release];
		[img release];
        i++;
    }
    
    [self.scrollView setContentSize:CGSizeMake([self.scrollView bounds].size.width, curYLoc+170)];
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
    
    NSString *section = [NSString stringWithFormat:@"profile/%@", [[self.subjectDict objectForKey:@"subject"] objectForKey:@"id"]];
    [[[UIApplication sharedApplication] delegate] addAnalytics:section];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.scrollView = nil;
    self.subjectPhotos = nil;
    self.subjectDict = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end