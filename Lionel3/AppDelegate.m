//
//  AppDelegate.m
//  Lionel3
//
//  Created by Rahul Arya on 10/3/16.
//  Copyright (c) 2016 No Empty Promises. All rights reserved.
//

#import "AppDelegate.h"
#import "Sync.h"
#import "KeychainWrapper.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window.tintColor = [UIColor redColor];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];
    
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
	CFAbsoluteTime timeInSeconds = CFAbsoluteTimeGetCurrent();
	NSInteger prevSyncTime = [[NSUserDefaults standardUserDefaults] integerForKey:@"prevSyncTime"];
	
	NSLog(@"Checking for sync");
	NSLog(@"Time since previous sync: %f", timeInSeconds - prevSyncTime);
	
	KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"LIONeL" accessGroup:nil];
	
	if (
		[[keychainItem objectForKey:(__bridge id)kSecAttrAccount]  isEqual: @""]
		|| [keychainItem objectForKey:(__bridge id)kSecAttrAccount] == nil
		|| ![[NSUserDefaults standardUserDefaults] boolForKey:@"logged_in"]
		)
	{
		return;
	}
	
	if (timeInSeconds < prevSyncTime + 3600*4)
	{
		return;
	}
	
	
	NSLog(@"Reloading");
	
	
	Sync *syncer = [[Sync alloc] init];
	
	dispatch_queue_t queue = dispatch_queue_create("com.noemptypromises.Lionel3", NULL);
	dispatch_async(queue, ^{
		NSString *username;
		NSString *password;
		
		/*NSString *userData = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
		 
		 NSString *username = [[userData componentsSeparatedByString:@"^"] objectAtIndex:0];
		 NSString *password = [[userData componentsSeparatedByString:@"^"] objectAtIndex:1];*/
		
		username = [keychainItem objectForKey:(__bridge id)kSecAttrAccount];
		password = [[NSString alloc] initWithData:[keychainItem objectForKey:(__bridge id)kSecValueData] encoding:NSUTF8StringEncoding];
		
		@try{
			NSLog(@"%@", username);
			if (![syncer login:username andPassword: password])
			{
				return;
			}
		}
		@catch(NSException *e){
			NSLog(@"Wrong pw!");
			NSLog(@"%@",e);
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Synchronization Error"
															message:@"An unexpected error occurred. Please try logging out and reentering your LIONeL credentials. If this error persists, please contact Lilian Luong at 16luongl1@kgv.hk."
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			[alert show];
		}
	});
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
