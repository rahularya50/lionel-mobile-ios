//
//  LoginViewController.m
//  Lionel3
//
//  Created by Rahul Arya on 10/3/16.
//  Copyright (c) 2016 No Empty Promises. All rights reserved.
//

#import "LoginViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "TFHpple.h"
#import "Reachability.h"
#import "TabBarController.h"
#import "LoadingViewController.h"
#import "Sync.h"

@interface LoginViewController (){
    NSString *username;
    NSString *password;
    NSData *connData;
    NSData *l1Data;
    NSData *l2Data;
    NSArray *connCookies;
    NSArray *l1Cookies;
    NSArray *l2Cookies;
    NSString *uid;
    LoadingViewController *loading;
}@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated{
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filepath = [dir stringByAppendingPathComponent:@"userAuth.txt"];
    NSLog(@"%@",filepath);
    
    @try{
		NSString *userData = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
		NSLog(@"%@", userData);
		
    //if(userData.length>500){
        if(userData.length>5 && false)
        {
            username = [[userData componentsSeparatedByString:@"^"] objectAtIndex:0];
            password = [[userData componentsSeparatedByString:@"^"] objectAtIndex:1];
            TabBarController *tabBar = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarViewController"];
            [self presentViewController:tabBar animated:YES completion:nil];
        }
    }
    @catch(NSException *e){
        [[NSFileManager defaultManager] createFileAtPath:filepath contents:NULL attributes:nil];
    }
    
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentTabBar {
    TabBarController *tabBar = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarViewController"];
    [self presentViewController:tabBar animated:YES completion:nil];
    NSLog(@"Presented tab bar");
}

- (IBAction)loginButtonPressed:(id)sender {
    username = _usernameField.text;
    password = _passwordField.text;
    
    //loading = [self.storyboard instantiateViewControllerWithIdentifier:@"LoadingViewController"];
    //[self presentViewController:loading animated:NO completion:nil];
	
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filepath = [dir stringByAppendingPathComponent:@"userAuth.txt"];
    NSString *userData = [NSString stringWithFormat:@"%@^%@",username,password];
	
    Sync *syncer = [[Sync alloc] init];
	
	@try{
		NSLog(@"%@", username);
		[syncer login:username andPassword: password];
	}
	@catch(NSException *e){
		NSLog(@"Wrong pw!");
		NSLog(@"%@",e);
		return;
	}
	NSLog(@"Initial synchronization concluded");
	
	[userData writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
	NSLog(@"%@", [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil]);
	
    [self presentTabBar];
}
@end
