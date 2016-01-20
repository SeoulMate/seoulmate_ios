//
//  AppDelegate.m
//  Anypic
//
//  Created by Héctor Ramos on 5/04/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "AppDelegate.h"

#import "Reachability.h"
#import "MBProgressHUD.h"
#import "PAPHomeViewController.h"
#import "PAPLogInViewController.h"
#import "UIImage+ResizeAdditions.h"
#import "PAPAccountViewController.h"
#import "PAPWelcomeViewController.h"
#import "PAPActivityFeedViewController.h"
#import "PAPPhotoDetailsViewController.h"
#import "HomeFeedViewController.h"
#import "HomeKoreanViewController.h"
#import "HomeEventsViewController.h"
#import "BoardDetailsViewController.h"
#import "NotificationViewController.h"
#import "PAPFindFriendsViewController.h"
#import "SVWebViewController.h"
#import "SettingsViewController.h"

@interface AppDelegate () {
    BOOL firstLaunch;
}

@property (nonatomic, strong) PAPHomeViewController *homeViewController;
@property (nonatomic, strong) PAPActivityFeedViewController *activityViewController;
@property (nonatomic, strong) PAPWelcomeViewController *welcomeViewController;
@property (nonatomic, strong) HomeFeedViewController *homeFeedViewController;
@property (nonatomic, strong) HomeKoreanViewController *homeKoreanViewController;
@property (nonatomic, strong) HomeEventsViewController *homeEventsViewController;
@property (nonatomic, strong) NotificationViewController *homeNotificationViewController;
@property (nonatomic, strong) PAPFindFriendsViewController *findFriendsViewController;

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSTimer *autoFollowTimer;

- (void)setupAppearance;
- (BOOL)shouldProceedToMainInterface:(PFUser *)user;
- (BOOL)handleActionURL:(NSURL *)url;
@end

@implementation AppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // ****************************************************************************
    // Parse initialization
    [ParseCrashReporting enable];
//    [Parse setApplicationId:@"flPZLnYhd1R7XXWQSRJyBp008iQUFN7Rj7QQPoGL" clientKey:@"a6Tn9SSt35ja9urxqZJQywncuuDTpTrCldJnG6mw"];
    [Parse setApplicationId:@"zuH9FjEo3vlrY7sDtWVgTemrJS4qm53N4ZvuD3D1" clientKey:@"mqy6slvtUGqS7v0Y2eOlhsggPKIWhF1khoGCpYrS"];
    [PFFacebookUtils initializeFacebook];
//    [PFFacebookUtils initializeWithApplicationId:@"222622874583781"];
    // ****************************************************************************
  
    // Track app open.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveInBackground];
    }

    PFACL *defaultACL = [PFACL ACL];
    // Enable public read access by default, with any newly created PFObjects belonging to the current user
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];

    // Set up our app's global UIAppearance
    [self setupAppearance];

    // Use Reachability to monitor connectivity
    [self monitorReachability];

    self.welcomeViewController = [[PAPWelcomeViewController alloc] init];

    self.navController = [[UINavigationController alloc] initWithRootViewController:self.welcomeViewController];
    self.navController.navigationBarHidden = YES;

    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];

    [self handlePush:launchOptions];
    
    // Register for Push Notitications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];

    // Google Analytics
    
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
//    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL wasHandled = false;
    
    if ([PFFacebookUtils session]) {
        wasHandled |= [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
    } else {
        wasHandled |= [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    }
    
    wasHandled |= [self handleActionURL:url];

    return wasHandled;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
    }

    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	if (error.code != 3010) { // 3010 is for the iPhone Simulator
        NSLog(@"Application failed to register for push notifications: %@", error);
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:userInfo];
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        // Track app opens due to a push notification being acknowledged while the app wasn't active.
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }

    if ([PFUser currentUser]) {
        if ([self.tabBarController viewControllers].count > PAPActivityTabBarItemIndex) {
            UITabBarItem *tabBarItem = [[self.tabBarController.viewControllers objectAtIndex:PAPActivityTabBarItemIndex] tabBarItem];
            
            NSString *currentBadgeValue = tabBarItem.badgeValue;
            
            if (currentBadgeValue && currentBadgeValue.length > 0) {
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                NSNumber *badgeValue = [numberFormatter numberFromString:currentBadgeValue];
                NSNumber *newBadgeValue = [NSNumber numberWithInt:[badgeValue intValue] + 1];
                tabBarItem.badgeValue = [numberFormatter stringFromNumber:newBadgeValue];
            } else {
                tabBarItem.badgeValue = @"1";
            }
        }
    }
//    [PFPush handlePush:userInfo];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

    // Clear badge and update installation, required for auto-incrementing badges.
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveInBackground];
    }

    // Clears out all notifications from Notification Center.
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    application.applicationIconBadgeNumber = 1;
    application.applicationIconBadgeNumber = 0;

    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}


#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)aTabBarController shouldSelectViewController:(UIViewController *)viewController {
    // The empty UITabBarItem behind our Camera button should not load a view controller
//    return ![viewController isEqual:aTabBarController.viewControllers[PAPEmptyTabBarItemIndex]];
    return true;
}

#pragma mark - AppDelegate

- (BOOL)isParseReachable {
    return self.networkStatus != NotReachable;
}

- (void)presentLoginViewController:(BOOL)animated {
    [self.welcomeViewController presentLoginViewController:animated];
}

- (void)presentLoginViewController {
    [self presentLoginViewController:YES];
}

- (void)presentTabBarController {    
    self.tabBarController = [[PAPTabBarController alloc] init];
    self.homeViewController = [[PAPHomeViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.homeViewController setFirstLaunch:firstLaunch];
    self.homeFeedViewController = [[HomeFeedViewController alloc] initWithStyle:UITableViewStylePlain];
    self.homeKoreanViewController = [[HomeKoreanViewController alloc] initWithStyle:UITableViewStylePlain];
    self.activityViewController = [[PAPActivityFeedViewController alloc] initWithStyle:UITableViewStylePlain];
    self.homeEventsViewController = [[HomeEventsViewController alloc] initWithStyle:UITableViewStylePlain];
    self.homeNotificationViewController = [[NotificationViewController alloc] initWithStyle:UITableViewStylePlain];
    self.findFriendsViewController = [[PAPFindFriendsViewController alloc] initWithStyle:UITableViewStylePlain];
    SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:@"http://seoulmateapp.co/privacy-policy"];
    SVWebViewController *helpWebViewController = [[SVWebViewController alloc] initWithAddress:@"http://seoulmateapp.co/help-center"];

    
    
    UINavigationController *homeNavigationController = [[UINavigationController alloc] initWithRootViewController:self.homeViewController];
    UINavigationController *koreanNavigationController = [[UINavigationController alloc] initWithRootViewController:self.homeKoreanViewController];
    UINavigationController *activityFeedNavigationController = [[UINavigationController alloc] initWithRootViewController:self.activityViewController];
    UINavigationController *feedNavigationController = [[UINavigationController alloc] initWithRootViewController:self.homeFeedViewController];
    UINavigationController *eventNavigationController = [[UINavigationController alloc] initWithRootViewController:self.homeEventsViewController];
    UINavigationController *notificationNavigationController = [[UINavigationController alloc] initWithRootViewController:self.homeNotificationViewController];
    UINavigationController *friendsNavigationController = [[UINavigationController alloc] initWithRootViewController:self.findFriendsViewController];
    UINavigationController *settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
     UINavigationController *helpNavigationController = [[UINavigationController alloc] initWithRootViewController:helpWebViewController];
    
    
    UITabBarItem *homeTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Board", @"Board") image:[[UIImage imageNamed:@"IconHome.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"IconHome.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [homeTabBarItem setTitleTextAttributes: @{ NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont boldSystemFontOfSize:13] } forState:UIControlStateSelected];
    [homeTabBarItem setTitleTextAttributes: @{ NSForegroundColorAttributeName: [UIColor colorWithRed:114.0f/255.0f green:114.0f/255.0f blue:114.0f/255.0f alpha:1.0f], NSFontAttributeName: [UIFont boldSystemFontOfSize:11] } forState:UIControlStateNormal];
    
    UITabBarItem *friendsTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Notification", @"Notification") image:[[UIImage imageNamed:@"iconNotification.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"iconNotification.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [friendsTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont boldSystemFontOfSize:13] } forState:UIControlStateSelected];
    [friendsTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor colorWithRed:114.0f/255.0f green:114.0f/255.0f blue:114.0f/255.0f alpha:1.0f], NSFontAttributeName: [UIFont boldSystemFontOfSize:11] } forState:UIControlStateNormal];
    
    UITabBarItem *feedTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Feed", @"Feed") image:[[UIImage imageNamed:@"IconTimeline.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"IconTimeline.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [feedTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont boldSystemFontOfSize:13] } forState:UIControlStateSelected];
    [feedTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor colorWithRed:114.0f/255.0f green:114.0f/255.0f blue:114.0f/255.0f alpha:1.0f], NSFontAttributeName: [UIFont boldSystemFontOfSize:11] } forState:UIControlStateNormal];
    
    // 4
    
    UITabBarItem *koreanTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Life in Korea", @"Life in Korea") image:[[UIImage imageNamed:@"IconLife.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"IconLife.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [koreanTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont boldSystemFontOfSize:13] } forState:UIControlStateSelected];
    [koreanTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor colorWithRed:114.0f/255.0f green:114.0f/255.0f blue:114.0f/255.0f alpha:1.0f], NSFontAttributeName: [UIFont boldSystemFontOfSize:11] } forState:UIControlStateNormal];
    
    // 5
    
    UITabBarItem *eventTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Events", @"Events") image:[[UIImage imageNamed:@"iconEvent.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"iconEvent.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [eventTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont boldSystemFontOfSize:13] } forState:UIControlStateSelected];
    [eventTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor colorWithRed:114.0f/255.0f green:114.0f/255.0f blue:114.0f/255.0f alpha:1.0f], NSFontAttributeName: [UIFont boldSystemFontOfSize:11] } forState:UIControlStateNormal];
    
    // 6
    
    UITabBarItem *settingsTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Settings", @"Settings") image:[[UIImage imageNamed:@"iconSettings.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"iconSettings.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [settingsTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont boldSystemFontOfSize:13] } forState:UIControlStateSelected];
    [settingsTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor colorWithRed:114.0f/255.0f green:114.0f/255.0f blue:114.0f/255.0f alpha:1.0f], NSFontAttributeName: [UIFont boldSystemFontOfSize:11] } forState:UIControlStateNormal];
    
    UITabBarItem *activityTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Activity", @"Activity") image:[[UIImage imageNamed:@"IconTimelineSelected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"IconTimelineSelected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [activityTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont boldSystemFontOfSize:13] } forState:UIControlStateSelected];
    [activityTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor colorWithRed:114.0f/255.0f green:114.0f/255.0f blue:114.0f/255.0f alpha:1.0f], NSFontAttributeName: [UIFont boldSystemFontOfSize:11] } forState:UIControlStateNormal];
    
    UITabBarItem *peopleTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"People", @"People") image:[[UIImage imageNamed:@"IconPeople.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"IconPeople.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [peopleTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont boldSystemFontOfSize:13] } forState:UIControlStateSelected];
    [peopleTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor colorWithRed:114.0f/255.0f green:114.0f/255.0f blue:114.0f/255.0f alpha:1.0f], NSFontAttributeName: [UIFont boldSystemFontOfSize:11] } forState:UIControlStateNormal];
    
    // 6
    
    UITabBarItem *privacyTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Privacy Policy", @"Privacy Policy") image:[[UIImage imageNamed:@"IconPrivacy.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"IconPrivacy.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [privacyTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont boldSystemFontOfSize:13] } forState:UIControlStateSelected];
    [privacyTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor colorWithRed:114.0f/255.0f green:114.0f/255.0f blue:114.0f/255.0f alpha:1.0f], NSFontAttributeName: [UIFont boldSystemFontOfSize:11] } forState:UIControlStateNormal];
    
    UITabBarItem *helpTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Help Center", @"Help Center") image:[[UIImage imageNamed:@"IconHelp.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"IconHelp.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [helpTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont boldSystemFontOfSize:13] } forState:UIControlStateSelected];
    [helpTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor colorWithRed:114.0f/255.0f green:114.0f/255.0f blue:114.0f/255.0f alpha:1.0f], NSFontAttributeName: [UIFont boldSystemFontOfSize:11] } forState:UIControlStateNormal];
    
    
    [koreanNavigationController setTabBarItem:koreanTabBarItem];
    [homeNavigationController setTabBarItem:homeTabBarItem];
    [activityFeedNavigationController setTabBarItem:activityTabBarItem];
    [feedNavigationController setTabBarItem:feedTabBarItem];
    [eventNavigationController setTabBarItem:eventTabBarItem];
    [notificationNavigationController setTabBarItem:friendsTabBarItem];
    [friendsNavigationController setTabBarItem:peopleTabBarItem];
    [settingsNavigationController setTabBarItem:privacyTabBarItem];
    [helpNavigationController setTabBarItem:helpTabBarItem];
    
    
    
    self.tabBarController.delegate = self;
    self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
    self.tabBarController.viewControllers = @[ homeNavigationController,feedNavigationController,notificationNavigationController,koreanNavigationController, eventNavigationController,friendsNavigationController,activityFeedNavigationController,settingsNavigationController,helpNavigationController];
    
    [self.navController setViewControllers:@[ self.welcomeViewController, self.tabBarController ] animated:NO];

  
}

- (void)logOut {
    // clear cache
    [[PAPCache sharedCache] clear];

    // clear NSUserDefaults
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsCacheFacebookFriendsKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // Unsubscribe from push notifications by removing the user association from the current installation.
    [[PFInstallation currentInstallation] removeObjectForKey:kPAPInstallationUserKey];
    [[PFInstallation currentInstallation] saveInBackground];
    
    // Clear all caches
    [PFQuery clearAllCachedResults];
    
    // Log out
    [PFUser logOut];
    [FBSession setActiveSession:nil];
    
    // clear out cached data, view controllers, etc
    [self.navController popToRootViewControllerAnimated:NO];
    
    [self presentLoginViewController];
    
    self.homeViewController = nil;
    self.activityViewController = nil;
}


#pragma mark - ()

// Set up appearance parameters to achieve Anypic's custom look and feel
- (void)setupAppearance {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    /*
     App theme colors 
     Primary Color : Teal rgb(0,150,136);
     Ascent Color : rgb(124,77,255);  
     
     */
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.0f/255.0f green:150.0f/255.0f blue:136.0f/255.0f alpha:1.0f]];

    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                NSForegroundColorAttributeName: [UIColor whiteColor]
                                }];
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleColor:[UIColor whiteColor]
     forState:UIControlStateNormal];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName:[UIColor whiteColor]
                                                           }
                                                forState:UIControlStateNormal];
    
    [[UISearchBar appearance] setTintColor:[UIColor colorWithRed:254.0f/255.0f green:149.0f/255.0f blue:50.0f/255.0f alpha:1.0f]];
//    [[UISearchBar appearance] setTintColor:[UIColor whiteColor]];
}

- (void)monitorReachability {
    Reachability *hostReach = [Reachability reachabilityWithHostname:@"api.parse.com"];

    hostReach.reachableBlock = ^(Reachability*reach) {
        _networkStatus = [reach currentReachabilityStatus];
        
        if ([self isParseReachable] && [PFUser currentUser] && self.homeViewController.objects.count == 0) {
            // Refresh home timeline on network restoration. Takes care of a freshly installed app that failed to load the main timeline under bad network conditions.
            // In this case, they'd see the empty timeline placeholder and have no way of refreshing the timeline unless they followed someone.
            [self.homeViewController loadObjects];
        }
    };
    
    hostReach.unreachableBlock = ^(Reachability*reach) {
        _networkStatus = [reach currentReachabilityStatus];
    };
    
    [hostReach startNotifier];
}

- (void)handlePush:(NSDictionary *)launchOptions {

    // If the app was launched in response to a push notification, we'll handle the payload here
    NSDictionary *remoteNotificationPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotificationPayload) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:remoteNotificationPayload];
        
        if (![PFUser currentUser]) {
            return;
        }
                
        // If the push notification payload references a photo, we will attempt to push this view controller into view
        NSString *photoObjectId = [remoteNotificationPayload objectForKey:kPAPPushPayloadPhotoObjectIdKey];
        if (photoObjectId && photoObjectId.length > 0) {
            [self shouldNavigateToPhoto:[PFObject objectWithoutDataWithClassName:kPAPBoardClassKey objectId:photoObjectId]];
            return;
        }
        
        // If the push notification payload references a user, we will attempt to push their profile into view
        NSString *fromObjectId = [remoteNotificationPayload objectForKey:kPAPPushPayloadFromUserObjectIdKey];
        if (fromObjectId && fromObjectId.length > 0) {
            PFQuery *query = [PFUser query];
            query.cachePolicy = kPFCachePolicyCacheElseNetwork;
            [query getObjectInBackgroundWithId:fromObjectId block:^(PFObject *user, NSError *error) {
                if (!error) {
                    UINavigationController *homeNavigationController = self.tabBarController.viewControllers[PAPHomeTabBarItemIndex];
                    self.tabBarController.selectedViewController = homeNavigationController;
                    
                    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
                    NSLog(@"Presenting account view controller with user: %@", user);
                    accountViewController.user = (PFUser *)user;
                    [homeNavigationController pushViewController:accountViewController animated:YES];
                }
            }];
        }
    }
}

- (void)autoFollowTimerFired:(NSTimer *)aTimer {
    [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:YES];
    [MBProgressHUD hideHUDForView:self.homeViewController.view animated:YES];
    [self.homeViewController loadObjects];
}

- (BOOL)shouldProceedToMainInterface:(PFUser *)user {
    [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:YES];
    [self presentTabBarController];

    [self.navController dismissViewControllerAnimated:YES completion:nil];
    return YES;
}

- (BOOL)handleActionURL:(NSURL *)url {
    if ([[url host] isEqualToString:kPAPLaunchURLHostTakePicture]) {
        if ([PFUser currentUser]) {
            return [self.tabBarController shouldPresentPhotoCaptureController];
        }
    } else {
        if ([[url fragment] rangeOfString:@"^pic/[A-Za-z0-9]{10}$" options:NSRegularExpressionSearch].location != NSNotFound) {
            NSString *photoObjectId = [[url fragment] substringWithRange:NSMakeRange(4, 10)];
            if (photoObjectId && photoObjectId.length > 0) {
              NSLog(@"WOOP: %@", photoObjectId);
                [self shouldNavigateToPhoto:[PFObject objectWithoutDataWithClassName:kPAPPhotoClassKey objectId:photoObjectId]];
                return YES;
            }
        }
    }

    return NO;
}

- (void)shouldNavigateToPhoto:(PFObject *)targetPhoto {
    for (PFObject *photo in self.homeViewController.objects) {
        if ([photo.objectId isEqualToString:targetPhoto.objectId]) {
            NSLog(@"found the object!");
            targetPhoto = photo;
            break;
        }
    }
    
    // if we have a local copy of this photo, this won't result in a network fetch
    [targetPhoto fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            UINavigationController *homeNavigationController = [[self.tabBarController viewControllers] objectAtIndex:PAPHomeTabBarItemIndex];
            [self.tabBarController setSelectedViewController:homeNavigationController];
            
            BoardDetailsViewController *detailViewController = [[BoardDetailsViewController alloc] initWithBoard:object board:object];
            [homeNavigationController pushViewController:detailViewController animated:YES];
            NSLog(@"started Board Details View Controller");
        }
    }];
}



- (void)autoFollowUsers {
//    firstLaunch = YES;
//    [PFCloud callFunctionInBackground:@"autoFollowUsers" withParameters:nil block:^(id object, NSError *error) {
//        if (error) {
//            NSLog(@"Error auto following users: %@", error);
//        }
//        [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:NO];
//        [self.homeViewController loadObjects];
//    }];
}

@end
