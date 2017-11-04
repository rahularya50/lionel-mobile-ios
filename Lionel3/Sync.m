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
	
	NSLog(@"User credentials acquired");
	
	NSLog(@"%@", username);
	
    NSLog(@"Login function called.");
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if(networkStatus == NotReachable){
        return NO;
    }
    
    NSData *n = [@"" dataUsingEncoding:NSUTF8StringEncoding];
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:dir];
    
    [ASIHTTPRequest setSessionCookies:nil];
    
    NSURL *l1Url = [NSURL URLWithString:@"https://lionel2.kgv.edu.hk/login/index.php"];
    ASIHTTPRequest *connRequest = [ASIHTTPRequest requestWithURL:l1Url];
    [connRequest setDelegate:self];
    [connRequest setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"conn",@"tag", nil]];
    [connRequest setTimeOutSeconds:60];
    [connRequest startSynchronous];
    
    connData = [connRequest responseData];
    connCookies = [connRequest responseCookies];
	
    NSURL *temp = [NSURL URLWithString:@"https://lionel2.kgv.edu.hk/login/index.php"];
    ASIFormDataRequest *l1Request = [ASIFormDataRequest requestWithURL:temp];
    [l1Request setRequestCookies:[connCookies mutableCopy]];
    NSLog(@"%@",username);
    [l1Request setPostValue:username forKey:@"username"];
	[l1Request setPostValue:password forKey:@"password"];
	[l1Request setPostValue:@"0" forKey:@"rememberusername"];
    [l1Request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"l1",@"tag", nil]];
    [l1Request setDelegate:self];
    [l1Request setTimeOutSeconds:60];
    [l1Request startSynchronous];
	l1Data = [l1Request responseData];
	NSLog(@"Received Lionel 1.");
	
	connCookies = [l1Request responseCookies];

	NSString *cString = [[NSString alloc] initWithData:[l1Request responseData] encoding:NSUTF8StringEncoding];
	if (cString.length < 100)
	{
		return NO;
	}
	dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	filepath = [dir stringByAppendingPathComponent:@"calendar.txt"];
	[[NSFileManager defaultManager] createFileAtPath:@"./calendar.txt" contents:n attributes:nil];
	[cString writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
	
	NSString *cdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *cfilepath = [cdir stringByAppendingPathComponent:@"calendar.txt"];
	NSString *calendarString = [NSString stringWithContentsOfFile:cfilepath encoding:NSUTF8StringEncoding error:nil];
	NSData *calendarData = [calendarString dataUsingEncoding:NSUTF8StringEncoding];
	
	TFHpple *calendar = [[TFHpple alloc] initWithHTMLData:calendarData];
	NSString *cHeader = [[[calendar searchWithXPathQuery:@"//div[@class='greeting']/div"] objectAtIndex:0] content];
	
	bool isNext = [cHeader characterAtIndex:0] != 'T';
	
	int week = [cHeader characterAtIndex:[cHeader rangeOfString:@"Week "].location + 5] - 1 - '0';
	NSLog(@"Week is: %d", week);
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
	int weekday = (int)[comps weekday]-1;
	[gregorian setFirstWeekday:2];
	NSDateComponents *dateComponent = [gregorian components:NSCalendarUnitWeekOfYear fromDate:[NSDate date]];
	int weekNumber = (int)dateComponent.weekOfYear;
	int parity;
	
	weekday = weekday % 7;

	if (1 <= weekday && weekday <= 5 && !isNext)
	{
		parity = week + weekNumber;
	}
	else
	{
		parity = week + weekNumber + 1;
	}
	
	NSLog(@"%d", parity);
		
	[[NSUserDefaults standardUserDefaults] setInteger:parity forKey:@"weekParity"];


    NSString* l1raw = [[NSString alloc] initWithData:l1Data encoding:NSUTF8StringEncoding];
	
    NSRange range = [l1raw rangeOfString:@"<a alt=\"summary\" class=\" \" href=\"https://lionel2.kgv.edu.hk/local/mis/students/summary.php?sid="];
    uid = [[l1raw substringWithRange:NSMakeRange(range.location+95, 4)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	NSLog(@"Your student id is #%@",uid);
	
    NSURL *tUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://lionel2.kgv.edu.hk/local/mis/misc/printtimetable.php?sid=%@", uid]];
    ASIHTTPRequest *tRequest = [ASIHTTPRequest requestWithURL:tUrl];
    [tRequest setRequestMethod:@"GET"];
    [tRequest setRequestCookies:[connCookies mutableCopy]];
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
        //[self performSelectorOnMainThread:@selector(throwInternetDialog) withObject:NULL waitUntilDone:YES];
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
    [hRequest setRequestCookies:[connCookies mutableCopy]];
    [hRequest setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"homework",@"tag", nil]];
    [hRequest setDelegate:self];
    [hRequest setTimeOutSeconds:60];
    [hRequest startSynchronous];

    NSLog(@"Homework received.");
    
    NSString *hString = [[NSString alloc] initWithData:[hRequest responseData] encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",hString);
    
    
    if (hString.length < 100)
    {
        //[self performSelectorOnMainThread:@selector(throwInternetDialog) withObject:NULL waitUntilDone:YES];
        return NO;
    }
    
    dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    filepath = [dir stringByAppendingPathComponent:@"homework.txt"];
    [[NSFileManager defaultManager] createFileAtPath:@"./homework.txt" contents:n attributes:nil];
    [hString writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSURL *bUrl = [NSURL URLWithString:@"https://lionel2.kgv.edu.hk/local/mis/bulletin/bulletin.php"];
    ASIHTTPRequest *bRequest = [ASIHTTPRequest requestWithURL:bUrl];
    [bRequest setRequestMethod:@"GET"];
    [bRequest setRequestCookies:[connCookies mutableCopy]];
    [bRequest setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"bulletin",@"tag", nil]];
    [bRequest setDelegate:self];
    [bRequest setTimeOutSeconds:60];
    [bRequest startSynchronous];
    
    NSLog(@"Bulletin received.");
    
    NSString *bString = [[NSString alloc] initWithData:[bRequest responseData] encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",bString);
    
    if (bString.length < 100)
    {
        //[self performSelectorOnMainThread:@selector(throwInternetDialog) withObject:NULL waitUntilDone:YES];
        return NO;
    }
    
    dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    filepath = [dir stringByAppendingPathComponent:@"bulletin.txt"];
    [[NSFileManager defaultManager] createFileAtPath:@"./bulletin.txt" contents:n attributes:nil];
    [bString writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
	
	[[NSUserDefaults standardUserDefaults] setInteger:CFAbsoluteTimeGetCurrent() forKey:@"prevSyncTime"];

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
