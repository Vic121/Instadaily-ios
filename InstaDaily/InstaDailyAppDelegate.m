//
//  InstaDailyAppDelegate.m
//  InstaDaily
//
//  Created by Marek Mikuliszyn on 11-04-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InstaDailyAppDelegate.h"

@implementation InstaDailyAppDelegate

@synthesize window=_window;

@synthesize managedObjectContext=__managedObjectContext;

@synthesize managedObjectModel=__managedObjectModel;

@synthesize persistentStoreCoordinator=__persistentStoreCoordinator;

@synthesize tabBarController;

- (void)countdown {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger i = 0;
    
//    i = [prefs integerForKey:@"counter_subject"];
//    i -= 30;
//    [prefs setInteger:i forKey:@"counter_subject"];
    
    i = [prefs integerForKey:@"counter_my_photos"];
    i -= 30;
    [prefs setInteger:i forKey:@"counter_my_photos"];
    
//    i = [prefs integerForKey:@"counter_profile"];
//    i -= 30;
//    [prefs setInteger:i forKey:@"counter_profile"];
    
    i = [prefs integerForKey:@"counter_leaderboard"];
    i -= 30;
    [prefs setInteger:i forKey:@"counter_leaderboard"];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarHidden:YES];
    
    NSString* currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs objectForKey:@"user_token"] == nil) {
        [self firstRun];
        [prefs setBool:YES forKey:@"firstRun"];
    }
    else if (currentVersion != [prefs objectForKey:@"userVersion"]) {
        if ([prefs objectForKey:@"userVersion"] == @"0.9") {
            // upgrade from 0.9 to current
        }
        // ...
    }
    [prefs setObject:currentVersion forKey:@"userVersion"]; // after upgrades
    
    [self.window addSubview:[self.tabBarController view]];
    [self.window makeKeyAndVisible];
    
    [prefs setInteger:60 forKey:@"counter_subject"];
    [prefs setInteger:60 forKey:@"counter_my_photos"];
    [prefs setInteger:60 forKey:@"counter_profile"];
    [prefs setInteger:7200 forKey:@"counter_leaderboard"];
    
    [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(countdown) userInfo:NULL repeats:YES];
    
    // Google Analytics
    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-317705-23"
                                           dispatchPeriod:10
                                                 delegate:nil];
    
    return YES;
}

- (void) firstRun {
    
    /*
    // fetch new user_id and secret
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@/", NEW_GAME_URL, uniqueIdentifier, deviceType]]];
    [request startSynchronous];
    
    NSError *error = [request error];
    NSArray *data = [NSArray array];
    if (!error) {
        data = [[request responseString] componentsSeparatedByString:@","];
    }
    else {
        data = [NSArray arrayWithObjects:@"0", @"", nil];
    }
    
    // save data
    NSMutableDictionary *user = [NSMutableDictionary dictionary];
    [user setObject:[data objectAtIndex:0] forKey:@"user_id"];
    [user setObject:@"Yuri" forKey:@"name"];
    [user setObject:[NSNumber numberWithInt:100000] forKey:@"money"];
    [user setObject:[NSNumber numberWithInt:0] forKey:@"total_value"];
    [user setObject:[NSNumber numberWithInt:0] forKey:@"total_spent"];
    [user setObject:[NSNumber numberWithInt:0] forKey:@"total_earnt"];
    [user setObject:[NSNumber numberWithInt:0] forKey:@"total_payments"];
    [user setObject:uniqueIdentifier forKey:@"device_id"];
    [user setObject:deviceType forKey:@"device_type"];
    [user setObject:[data objectAtIndex:1] forKey:@"secret_key"];
    
    NSLog(@"user = %@", user);
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:user forKey:@"user"];
    */
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:0 forKey:@"counter_subject"];
    [prefs setInteger:0 forKey:@"counter_my_photos"];
    [prefs setInteger:0 forKey:@"counter_profile"];
    [prefs setInteger:0 forKey:@"counter_leaderboard"];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    [self sendAnalytics];
}

- (void)dealloc
{
    [_window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [[GANTracker sharedTracker] stopTracker];
    [super dealloc];
}

- (void)awakeFromNib
{
    /*
     Typically you should set up the Core Data stack here, usually by passing the managed object context to the first view controller.
     self.<#View controller#>.managedObjectContext = self.managedObjectContext;
    */
}

- (void) deleteAllObjects: (NSString *) entityDescription  {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    for (NSManagedObject *managedObject in items) {
        [self.managedObjectContext deleteObject:managedObject];
        //        NSLog(@"%@ object deleted", entityDescription);
    }
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error deleting %@ - error:%@", entityDescription, error);
    }
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"InstaDaily" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"InstaDaily.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)addAnalytics:(NSString *)section {
    NSString* currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *username = @"unknown";
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *profile = [prefs objectForKey:@"user"];
    if ([profile objectForKey:@"name"] != nil) {
        username = [profile objectForKey:@"name"];
    }
    
    // Device ID
    UIDevice *device = [UIDevice currentDevice];
    NSString *uniqueIdentifier = [device uniqueIdentifier];
    
    // Device type
    NSString *deviceType = @"ipod";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        deviceType = @"iphone";
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        deviceType = @"ipad";
    }
    
    NSError *error;
    if (![[GANTracker sharedTracker] setCustomVariableAtIndex:1
                                                         name:@"app_version"
                                                        value:currentVersion
                                                    withError:&error]) {}
    
    if (![[GANTracker sharedTracker] setCustomVariableAtIndex:2
                                                         name:@"ios_version"
                                                        value:[device systemVersion]
                                                    withError:&error]) {}
    
//    if (![[GANTracker sharedTracker] setCustomVariableAtIndex:3
//                                                         name:@"uuid"
//                                                        value:uniqueIdentifier
//                                                    withError:&error]) {}
    
    if (![[GANTracker sharedTracker] setCustomVariableAtIndex:4
                                                         name:@"username"
                                                        value:username
                                                    withError:&error]) {}
    //    
    //    if (![[GANTracker sharedTracker] setCustomVariableAtIndex:5
    //                                                         name:@"iPhone1"
    //                                                        value:@"iv1"
    //                                                    withError:&error]) {}
    
    //    if (![[GANTracker sharedTracker] trackEvent:@"my_category"
    //                                         action:@"my_action"
    //                                          label:@"my_label"
    //                                          value:-1
    //                                      withError:&error]) {}
    //     

    NSString *req = [NSString stringWithFormat:@"/%@/%@/", deviceType, section];
    if (![[GANTracker sharedTracker] trackPageview:req
                                         withError:&error]) {}
    
    gotAnalytics++;
    if (gotAnalytics >= 10) {
        [self sendAnalytics];
    }
    
//    NSLog(@"added %@", req);

}

- (void)sendAnalytics {
    [[GANTracker sharedTracker] dispatch];
    gotAnalytics -= 10;
    
//    NSLog(@"sent analytics");
}

@end
