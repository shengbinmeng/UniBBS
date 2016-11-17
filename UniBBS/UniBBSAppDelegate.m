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
#import "BDWMUserModel.h"
#import "BDWMSettings.h"

@implementation UniBBSAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.tintColor = [UIColor colorWithRed:246.0/255 green:18.0/255 blue:81.0/255 alpha:1.0];
    
    // Override point for customization after application launch.
    PopularTopicsViewController *viewController1 = [[PopularTopicsViewController alloc] initWithStyle:UITableViewStylePlain];
    BoardListViewController *viewController2 = [[BoardListViewController alloc] initWithStyle:UITableViewStylePlain];
    viewController2.listURI = @"http://www.bdwm.net/bbs/bbsxboa.php?group=0";

    ProfileViewController *viewController3 = [[ProfileViewController alloc] initWithStyle:UITableViewStyleGrouped];
    SettingsViewController *viewController4 = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    UINavigationController *popularViewController, *boardListViewController, *profileViewController, *settingsViewController;
    popularViewController = [[UINavigationController alloc] initWithRootViewController:viewController1];
    boardListViewController = [[UINavigationController alloc] initWithRootViewController:viewController2];
    profileViewController = [[UINavigationController alloc] initWithRootViewController:viewController3];
    settingsViewController = [[UINavigationController alloc] initWithRootViewController:viewController4];

    /*
     *Set auto login flag according to "auto login" switch.
     *This switch can be set at setting view.
     *The default value is true.
     */
    if ([BDWMSettings boolAutoLogin]) {
        [BDWMUserModel setEnterAppAndAutoLogin:YES];
    }
    
    self.tabBarController = [[UITabBarController alloc] init];
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

@end
