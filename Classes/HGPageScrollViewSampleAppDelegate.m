//
//  HGPageScrollViewSampleAppDelegate.m
//  HGPageScrollViewSample
//
//  Created by Rotem Rubnov on 13/3/2011.
//	Copyright (C) 2011 TomTom
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//
//

#import "HGPageScrollViewSampleAppDelegate.h"
#import "BrowserViewController.h"
#import "BrowserViewController.h"
#import "SettingViewController.h"
#import "DownloadViewController.h"
#import "FileListViewController.h"
#import "ShareViewController.h"
@implementation HGPageScrollViewSampleAppDelegate

@synthesize window;
@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    
   
	// Set the view controller as the window's root view controller and display.
    [self.window setBackgroundColor:[UIColor redColor]];
   // self.viewController = [[HGPageScrollViewSampleViewController alloc]init];
    //self.window.rootViewController = self.viewController;


    [self setTabBar];
    [self.window makeKeyAndVisible];

    return YES;
}

-(void) setTabBar{
    UITabBarController *tabBarController = [[UITabBarController alloc]init];
    
    BrowserViewController *objBrowser = [[BrowserViewController alloc]init];
    objBrowser.title = @"Browser";
    UINavigationController *nav1 = [[UINavigationController alloc]initWithRootViewController:objBrowser];
    
    DownloadViewController *objDownload = [[DownloadViewController alloc]init];
    objDownload.title = @"Download";
    UINavigationController *nav2 = [[UINavigationController alloc]initWithRootViewController:objDownload];
    [[NSNotificationCenter defaultCenter] addObserver:objDownload selector:@selector(downloadNotification:) name:DOWNLOAD_NOTIFICATION object:nil];

    
    FileListViewController *objFile = [[FileListViewController alloc]init];
    objFile.title = @"Files";
    UINavigationController *nav3 = [[UINavigationController alloc]initWithRootViewController:objFile];
    [[NSNotificationCenter defaultCenter] addObserver:objFile selector:@selector(fileNotification:) name:FILE_NOTIFICATION object:nil];

    
    ShareViewController *objShare = [[ShareViewController alloc]init];
    objShare.title = @"Share";
    UINavigationController *nav4 = [[UINavigationController alloc]initWithRootViewController:objShare];
    
    SettingViewController *objSetting = [[    SettingViewController alloc]init];
    objSetting.title = @"Settings";
    UINavigationController *nav5 = [[UINavigationController alloc]initWithRootViewController:objSetting];
    
    tabBarController.viewControllers = [NSArray arrayWithObjects:nav1,nav2,nav3,nav4,nav5, nil];
    [self.window setRootViewController:tabBarController];
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


// The completion handler passed from the system to our app is stored to the property we just declared.
//The backgroundTransferCompletionHandler is the one that is called when all downloads are complete
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    self.backgroundTransferCompletionHandler = completionHandler;
}


@end
