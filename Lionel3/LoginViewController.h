//
//  LoginViewController.h
//  Lionel3
//
//  Created by Rahul Arya on 10/3/16.
//  Copyright (c) 2016 No Empty Promises. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
- (IBAction)loginButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
- (void)presentTabBar;
@end
