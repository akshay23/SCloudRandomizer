//
//  AppDelegate.m
//  SCloudRandomizer
//
//  Created by Akshay Bharath on 12/3/14.
//  Copyright (c) 2014 Akshay Bharath. All rights reserved.
//

#import "AppDelegate.h"
#import "iRate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "GlobalData.h"

@interface AppDelegate ()

@property (nonatomic, strong) UIAlertView *alertView;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // SoundCloud client auth
    [SCSoundCloud  setClientID:@"96002082c5bda6dc3b4301258f819c2b"
                        secret:@"1656c693b8bbe5727bc5fd2263514fd3"
                   redirectURL:[NSURL URLWithString:@"scloudy://oauth"]];
    
    // Play audio in the background
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    // Set up iRate
    [iRate sharedInstance].daysUntilPrompt = 5;
    [iRate sharedInstance].remindPeriod = 10;
    [iRate sharedInstance].promptForNewVersionIfUserRated = YES;
    [iRate sharedInstance].appStoreGenreID = 1;
    
    // Instantiate crashlytics
    [Fabric with:@[CrashlyticsKit]];
    
    // Instantiate wormhole
    if (![GlobalData getInstance].wormhole) {
        [GlobalData getInstance].wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.com.actionman.scloudy" optionalDirectory:@"wormhole"];
        NSLog(@"wormhole instantiated");
    }
    
    // Notify watch that app has been launched
    [[GlobalData getInstance].wormhole passMessageObject:@"YES" identifier:@"AppRunning"];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Notify watch that app has been terminated
    [[GlobalData getInstance].wormhole passMessageObject:@"NO" identifier:@"AppRunning"];
}

// Handle Scloudy watchkit requests
- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void(^)(NSDictionary *replyInfo))reply {
    if ([userInfo valueForKey:@"Active"] != nil) {
        reply(@{@"Active": @"YES"});
        NSLog(@"Told WatchKit that app is active");
    } else if ([userInfo valueForKey:@"RefreshData"] != nil) {
        reply(@{@"Refresh": @"YES"});
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.actionman.Scloudy.WatchAppRefreshData" object:self];
        NSLog(@"Told WatchKit that data will be refreshed");
    } else if ([userInfo valueForKey:@"NextTrack"] != nil) {
        reply(@{@"NextTrack": @"YES"});
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.actionman.Scloudy.WatchAppNextTrack" object:self];
        NSLog(@"Told WatchKit that next track will play");
    } else if ([userInfo valueForKey:@"PlayPauseTrack"] != nil) {
        reply(@{@"PlayPauseTrack": @"YES"});
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.actionman.Scloudy.WatchAppPlayPauseTrack" object:self];
        NSLog(@"Told WatchKit that current track will play/pause");
    }
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "actionman.SCloudRandomizer" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SCloudRandomizer" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SCloudRandomizer.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
