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
#import "KeychainWrapper.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


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
    
    int direction;
    int shakes;
    
    int keyboardHeight;
    
    LoadingViewController *loading;
}@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[_spinner stopAnimating];
	[self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated{
	
	KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"LIONeL" accessGroup:nil];
	
	if(![[keychainItem objectForKey:(__bridge id)kSecAttrAccount]  isEqual: @""] && [keychainItem objectForKey:(__bridge id)kSecAttrAccount] != nil &&
	   [[NSUserDefaults standardUserDefaults] boolForKey:@"logged_in"] &&
	   [[NSUserDefaults standardUserDefaults] integerForKey:@"version"] == 2)
		{
		NSLog(@"Auto-login of user:");
		[CrashlyticsKit setUserEmail: [keychainItem objectForKey:(__bridge id)kSecAttrAccount]];
		NSLog(@"%@", [keychainItem objectForKey:(__bridge id)kSecAttrAccount]);
		//username = [[userData componentsSeparatedByString:@"^"] objectAtIndex:0];
		//password = [[userData componentsSeparatedByString:@"^"] objectAtIndex:1];
		TabBarController *tabBar = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarViewController"];
		[self presentViewController:tabBar animated:YES completion:nil];
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
	/*
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filepath = [dir stringByAppendingPathComponent:@"userAuth.txt"];
    NSString *userData = [NSString stringWithFormat:@"%@^%@",username,password];
	*/
    
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"LIONeL" accessGroup:nil];
    
    Sync *syncer = [[Sync alloc] init];
	[_spinner startAnimating];
	
	
	NSLog(@"Logging in");
	
	dispatch_queue_t queue = dispatch_queue_create("com.noemptypromises.Lionel3", NULL);
	dispatch_async(queue, ^{
		
		/*NSString *userData = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
		 
		 NSString *username = [[userData componentsSeparatedByString:@"^"] objectAtIndex:0];
		 NSString *password = [[userData componentsSeparatedByString:@"^"] objectAtIndex:1];*/
		
		@try{
			NSLog(@"%@", username);
			if (![syncer login:username andPassword: password])
			{
				@throw([NSException exceptionWithName:@"network" reason:@"nointernet" userInfo:NULL]);
			}
			else
			{
				dispatch_async(dispatch_get_main_queue(), ^{
					NSLog(@"Initial synchronization concluded");
					
					[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"logged_in"];
					
					
					//NSLog(@"%@", [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil]);
					
					[keychainItem setObject:(__bridge id)kSecAttrAccessibleAlways forKey:(__bridge id)kSecAttrAccount];
					[keychainItem setObject:(__bridge id)kSecAttrAccessibleAlways forKey:(__bridge id)kSecValueData];
					[keychainItem setObject:username forKey:(__bridge id)kSecAttrAccount];
					[keychainItem setObject:password forKey:(__bridge id)kSecValueData];
					[CrashlyticsKit setUserEmail: username];
					[[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"version"];

					[self presentTabBar];
				});
			}
		}
		@catch(NSException *e){
			NSLog(@"Wrong pw!");
			NSLog(@"%@",e);
			dispatch_async(dispatch_get_main_queue(), ^{
				_loginButton.titleLabel.text = @"Login";
				[_spinner stopAnimating];

				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication Error"
																message:@"Your username or password was entered incorrectly. Please try again. If this problem persists, please check your network connection."
															   delegate:nil
													  cancelButtonTitle:@"OK"
													  otherButtonTitles:nil];
				[alert show];
			});
		}
	});
	
	/*@try{
		NSLog(@"%@", username);
        _loginButton.titleLabel.text = @"Loading...";
		if (![syncer login:username andPassword: password])
        {
            @throw([NSException alloc]);
        }
	}
	@catch(NSException *e){
        _loginButton.titleLabel.text = @"Login";
		NSLog(@"Wrong pw!");
        shakes = 5;
        direction = 1;
        [self shake:_loginButton];
        NSLog(@"%@",e);
		return;
	}*/

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

-(void)shake:(UIView *)shakee
{
    [UIView animateWithDuration:0.03 animations:^
     {
         shakee.transform = CGAffineTransformMakeTranslation(5*direction, 0);
     }
                     completion:^(BOOL finished)
     {
         if(shakes >= 10)
         {
             shakee.transform = CGAffineTransformIdentity;
             return;
         }
         shakes++;
         direction = direction * -1;
         [self shake:shakee];
     }];
}

@end
