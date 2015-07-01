//
//  InstaDailyAppDelegate.h
//  InstaDaily
//
//  Created by Marek Mikuliszyn on 11-04-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "GANTracker.h"
#import "Prefs.h"

@interface InstaDailyAppDelegate : NSObject <UIApplicationDelegate> {
    NSInteger gotAnalytics;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (void)countdown;
- (void)firstRun;
- (void)deleteAllObjects: (NSString *) entityDescription;
- (NSURL *)applicationDocumentsDirectory;
- (void)addAnalytics:(NSString *)section;
- (void)sendAnalytics;

@end
