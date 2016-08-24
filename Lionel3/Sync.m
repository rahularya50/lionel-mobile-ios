//
//  Sync.m
//  Lionel3
//
//  Created by Rahul Arya on 23/6/2016.
//  Copyright © 2016 No Empty Promises. All rights reserved.
//

#import "Sync.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "TFHpple.h"
#import "Reachability.h"
#import "TabBarController.h"
#import "LoadingViewController.h"
#import "LoginViewController.h"

@interface Sync (){
    NSData *connData;
    NSData *l1Data;
    NSData *l2Data;
    NSArray *connCookies;
    NSArray *l1Cookies;
    NSArray *l2Cookies;
    NSString *uid;
    LoadingViewController *loading;
}

@end

@implementation Sync

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)login:(NSString*)username andPassword:(NSString*)password{
	connData = nil;
	l1Data = nil;
	l2Data = nil;
	connCookies = nil;
	l1Cookies = nil;
	l2Cookies = nil;
	uid = nil;
	loading = nil;
	
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filepath = [dir stringByAppendingPathComponent:@"userAuth.txt"];
    NSLog(@"%@",filepath);
    
	//NSString *userData = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
	
	NSLog(@"User credentials acquired");
	
	//NSLog(@"%@",userData);
	NSLog(@"%@", username);
	//NSLog(@"%@", password);
	
	/*username = [[userData componentsSeparatedByString:@"^"] objectAtIndex:0];
	password = [[userData componentsSeparatedByString:@"^"] objectAtIndex:1];
	
	NSLog(@"User credentials parsed");
	*/

	
    NSLog(@"Login function called.");
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if(networkStatus == NotReachable){
        [self performSelectorOnMainThread:@selector(throwInternetDialog) withObject:NULL waitUntilDone:YES];
        return NO;
        //NSLog(@"No internet connection.");
    }
    
    NSData *n = [@"" dataUsingEncoding:NSUTF8StringEncoding];
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:dir];
    
    [ASIHTTPRequest setSessionCookies:nil];
    
    NSURL *l1Url = [NSURL URLWithString:@"https://lionel.kgv.edu.hk/login/index.php"];
    ASIHTTPRequest *connRequest = [ASIHTTPRequest requestWithURL:l1Url];
    [connRequest setDelegate:self];
    //[connRequest setUseCookiePersistence:NO];
    [connRequest setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"conn",@"tag", nil]];
    [connRequest setTimeOutSeconds:60];
    [connRequest startSynchronous];
    
    connData = [connRequest responseData];
    connCookies = [connRequest responseCookies];
	
	NSLog(@"%@",[[NSString alloc] initWithData:connData encoding:NSUTF8StringEncoding]);
	
    //Send second request
    //NSLog(@"Request 2 sending.");
    NSURL *temp = [NSURL URLWithString:@"https://lionel.kgv.edu.hk/login/index.php"];
    ASIFormDataRequest *l1Request = [ASIFormDataRequest requestWithURL:temp];
    //ASIHTTPRequest *l1Request = [ASIHTTPRequest requestWithURL:temp];
    [l1Request setRequestCookies:[[connRequest responseCookies]mutableCopy]];
    NSLog(@"%@",username);
    [l1Request setPostValue:username forKey:@"username"];
    [l1Request setPostValue:password forKey:@"password"];
    [l1Request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"l1",@"tag", nil]];
    [l1Request setDelegate:self];
    [l1Request setTimeOutSeconds:60];
    [l1Request startSynchronous];
    
    
    
    l1Data = [l1Request responseData];
    NSLog(@"Received Lionel 1.");
    NSURL *l2Url = [NSURL URLWithString:@"http://lionel.kgv.edu.hk/auth/mnet/jump.php?hostid=10"];
    ASIHTTPRequest *l2Request = [ASIHTTPRequest requestWithURL:l2Url];
    [l2Request setRequestMethod:@"GET"];
    //NSLog(@"%@",connCookies);
    l1Cookies = [l1Request responseCookies];
    NSMutableArray *l2cookieList = [[l1Cookies arrayByAddingObjectsFromArray:connCookies] mutableCopy];
    //NSLog(@"%@",l2cookieList);
    [l2Request setRequestCookies:l2cookieList];
    [l2Request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"l2",@"tag", nil]];
    [l2Request setDelegate:self];
    [l2Request setTimeOutSeconds:60];
    [l2Request startSynchronous];

    NSLog(@"Lionel 2 works!!!!!!!");
    l2Data = [l2Request responseData];
    NSString* l1raw = [[NSString alloc] initWithData:l1Data encoding:NSUTF8StringEncoding];
	
    NSLog(@"%@",l1raw);
    
    NSRange range = [l1raw rangeOfString:@"http://lionel.kgv.edu.hk/user/view.php?id="];
    uid = [[l1raw substringWithRange:NSMakeRange(range.location+42, 4)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //Parsing to get user ID
    
    /*TFHpple *l1doc = [[TFHpple alloc] initWithHTMLData:l1Data];
    NSArray *menus = [l1doc searchWithXPathQuery:@"//div[contains(@class, 'menu clearfix')]"];
    TFHppleElement *l1menu = [menus objectAtIndex:0];
    NSString *a = [l1menu text];
    if(a.length < 13){
        NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filepath = [dir stringByAppendingPathComponent:@"userAuth.txt"];
        [@"" writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
		
		[NSException raise:@"Invalid user id" format:@"UID or PW likely incorrect"];

        return;
    }
    */
    
    //uid = @"8522";//[a substringWithRange:NSMakeRange(a.length - 13, a.length-10)];
    
    NSLog(@"Your student id is #%@",uid);
    
    NSURL *tUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://lionel2.kgv.edu.hk/local/mis/misc/printtimetable.php?sid=%@", uid]];
    ASIHTTPRequest *tRequest = [ASIHTTPRequest requestWithURL:tUrl];
    [tRequest setRequestMethod:@"GET"];
    //NSLog(@"%@",connCookies);
    l2Cookies = [l1Request responseCookies];
    NSMutableArray *tcookieList = [[l1Cookies arrayByAddingObjectsFromArray:l2Cookies] mutableCopy];
    //NSLog(@"%@",tcookieList);
    [tRequest setRequestCookies:tcookieList];
    [tRequest setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"timetable",@"tag", nil]];
    [tRequest setDelegate:self];
    [tRequest setTimeOutSeconds:60];
    [tRequest startSynchronous];

    NSLog(@"Timetable received.");
    
    NSString *tString = [[NSString alloc] initWithData:[tRequest responseData] encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",tString);
    
    dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    filepath = [dir stringByAppendingPathComponent:@"timetable.txt"];
    
    if (tString.length < 100)
    {
        [self performSelectorOnMainThread:@selector(throwInternetDialog) withObject:NULL waitUntilDone:YES];
        return NO;
    }
    NSError *error = nil;
    
    [[NSFileManager defaultManager] createFileAtPath:@"./timetable.txt" contents:n attributes:nil];
    [tString writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if(error){
        NSLog(@"Error: %@",error);
    }
    
    NSURL *hUrl = [NSURL URLWithString:@"https://lionel2.kgv.edu.hk/local/mis/mobile/myhomework.php"];
    ASIHTTPRequest *hRequest = [ASIHTTPRequest requestWithURL:hUrl];
    [hRequest setRequestMethod:@"GET"];
    //NSLog(@"%@",connCookies);
    NSMutableArray *hcookieList = [[l1Cookies arrayByAddingObjectsFromArray:l2Cookies] mutableCopy];
    [hRequest setRequestCookies:hcookieList];
    [hRequest setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"homework",@"tag", nil]];
    [hRequest setDelegate:self];
    [hRequest setTimeOutSeconds:60];
    [hRequest startSynchronous];

    NSLog(@"Homework received.");
    
    NSString *hString = [[NSString alloc] initWithData:[hRequest responseData] encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",hString);
    
    
    if (hString.length < 100)
    {
        [self performSelectorOnMainThread:@selector(throwInternetDialog) withObject:NULL waitUntilDone:YES];
        return NO;
    }
    
    dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    filepath = [dir stringByAppendingPathComponent:@"homework.txt"];
    [[NSFileManager defaultManager] createFileAtPath:@"./homework.txt" contents:n attributes:nil];
    [hString writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSURL *bUrl = [NSURL URLWithString:@"https://lionel2.kgv.edu.hk/local/mis/bulletin/bulletin.php"];
    ASIHTTPRequest *bRequest = [ASIHTTPRequest requestWithURL:bUrl];
    [bRequest setRequestMethod:@"GET"];
    //NSLog(@"%@",connCookies);
    NSMutableArray *bcookieList = [[l1Cookies arrayByAddingObjectsFromArray:l2Cookies] mutableCopy];
    [bRequest setRequestCookies:bcookieList];
    [bRequest setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"bulletin",@"tag", nil]];
    [bRequest setDelegate:self];
    [bRequest setTimeOutSeconds:60];
    [bRequest startSynchronous];
    
    NSLog(@"Bulletin received.");
    
    NSString *bString = [[NSString alloc] initWithData:[bRequest responseData] encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",bString);
    
    if (bString.length < 100)
    {
        [self performSelectorOnMainThread:@selector(throwInternetDialog) withObject:NULL waitUntilDone:YES];
        return NO;
    }
    
    dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    filepath = [dir stringByAppendingPathComponent:@"bulletin.txt"];
    [[NSFileManager defaultManager] createFileAtPath:@"./bulletin.txt" contents:n attributes:nil];
    [bString writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSURL *cUrl = [NSURL URLWithString:@"http://lionel.kgv.edu.hk/kgv-additions/Calendar/master.php?style=small"];
    ASIHTTPRequest *cRequest = [ASIHTTPRequest requestWithURL:cUrl];
    [bRequest setRequestMethod:@"GET"];
    //NSLog(@"%@",connCookies);
    NSMutableArray *ccookieList = [[l1Cookies arrayByAddingObjectsFromArray:l2Cookies] mutableCopy];
    [cRequest setRequestCookies:ccookieList];
    [cRequest setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"calendar",@"tag", nil]];
    [cRequest setDelegate:self];
    [cRequest setTimeOutSeconds:60];
    [cRequest startSynchronous];

    NSLog(@"Calendar received.");
    
    NSString *cString = [[NSString alloc] initWithData:[cRequest responseData] encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",bString);
    
    if (cString.length < 100)
    {
        [self performSelectorOnMainThread:@selector(throwInternetDialog) withObject:NULL waitUntilDone:YES];
        return NO;
    }
    
    dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    filepath = [dir stringByAppendingPathComponent:@"calendar.txt"];
    [[NSFileManager defaultManager] createFileAtPath:@"./calendar.txt" contents:n attributes:nil];
    [cString writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    return YES;
}

- (void)requestFailed:(ASIHTTPRequest *)request{
    NSLog(@"%@",[request error]);
}

- (void) throwInternetDialog
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                    message:@"You must be connected to the internet to synchronize with LIONeL. If you are receiving this error while on KGV wifi, try using your data connection or trying again once at home. If this error persists, please contact Lilian Luong at 16luongl1@kgv.hk."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
