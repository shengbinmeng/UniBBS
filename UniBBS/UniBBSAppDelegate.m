//
//  UniBBSAppDelegate.m
//  UniBBS
//
//  Created by Meng Shengbin on 3/7/12.
//  Copyright (c) 2012 Peking University. All rights reserved.
//

#import "UniBBSAppDelegate.h"

#import "PopularTopicsViewController.h"
#import "BoardListViewController.h"
#import "SettingsViewController.h"
#import "ProfileViewController.h"

@implementation UniBBSAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.tintColor = [UIColor colorWithRed:246.0/255 green:18.0/255 blue:81.0/255 alpha:1.0];
    
    // Override point for customization after application launch.
    PopularTopicsViewController *viewController1 = [[[PopularTopicsViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    BoardListViewController *viewController2 = [[[BoardListViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    viewController2.listAddress = @"http://www.bdwm.net/bbs/bbsxboa.php?group=0";

    ProfileViewController *viewController3 = [[[ProfileViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
    SettingsViewController *viewController4 = [[[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
    
    UINavigationController *popularViewController, *boardListViewController, *profileViewController, *settingsViewController;
    popularViewController = [[[UINavigationController alloc] initWithRootViewController:viewController1] autorelease];
    boardListViewController = [[[UINavigationController alloc] initWithRootViewController:viewController2] autorelease];
    profileViewController = [[[UINavigationController alloc] initWithRootViewController:viewController3] autorelease];
    settingsViewController = [[[UINavigationController alloc] initWithRootViewController:viewController4] autorelease];

    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:popularViewController, boardListViewController, profileViewController, settingsViewController, nil];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
