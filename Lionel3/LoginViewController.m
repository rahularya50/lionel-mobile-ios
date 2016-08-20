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
    
    int keyboardHeight;
    
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
		//NSLog(@"%@", userData);
		
    //if(userData.length>500){
        if(userData.length>5)
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
	//NSLog(@"%@", [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil]);
	
    [self presentTabBar];
}

-(void)keyboardWillShow:(NSNotification*)notification {
    // Animate the current view out of the way
    
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];

    keyboardHeight = keyboardFrameBeginRect.size.height;
    
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES andDHeight:keyboardHeight];
    }
}

-(void)keyboardWillHide {
    
    if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO andDHeight:keyboardHeight];
    }
}


//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp andDHeight:(int)dHeight
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    
    NSLog(@"%d", dHeight);
    
    int dist = MAX(450 - self.view.frame.size.height + dHeight, 0);
    
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        
        NSLog(@"kDown!");
        rect.origin.y -= dist;
//        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        NSLog(@"kUp!");
        rect.origin.y += dist;
//        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow :)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

@end
