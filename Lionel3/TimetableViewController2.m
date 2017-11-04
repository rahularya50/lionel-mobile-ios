//
//  TimetableViewController2.m
//  Lionel3
//
//  Created by Rahul Arya on 11/7/2016.
//  Copyright © 2016 No Empty Promises. All rights reserved.
//

#import "TimetableViewController2.h"

#import "TimetableTableViewController.h"
#import "TFHpple.h"
#import "LoginViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import "KeychainWrapper.h"

@interface TimetableViewController2 ()
{
    NSArray *pageNames;
    NSArray *periodStrings;
    NSMutableArray *classes;
	
	NSMutableArray *preloads;
    
    bool firstPageLoaded;
	
	int week;
	bool isNext;
}
@end

@implementation TimetableViewController2
- (void)viewDidLoad {
    [super viewDidLoad];
	[self today:self];

	
	[Answers logContentViewWithName:@"Timetable"
						contentType:@"Timetable"
						  contentId:@"Timetable"
				   customAttributes:@{}];
	
    [self parseTimetable];
	
	[self genpreloads];
    
    [[self view] setBackgroundColor:[UIColor whiteColor]];
    
    firstPageLoaded = false;
    
    
    preloads = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *logOut = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStylePlain target:self action:@selector(logOut:)];
    self.navigationItem.leftBarButtonItem = logOut;
    self.navigationItem.title = @"Timetable";

	UIBarButtonItem *today = [[UIBarButtonItem alloc] initWithTitle:@"Upcoming" style:UIBarButtonItemStylePlain target:self action:@selector(today:)];
	self.navigationItem.rightBarButtonItem = today;
	
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TimetablePageViewController"];
    self.pageViewController.dataSource = self;
	
	[self today:self];
	
    //TimetableTableViewController *startingViewController = [self viewControllerAtIndex:0];
    
    //NSArray *viewControllers = @[startingViewController];
    //[self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    //self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self today:self];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)logOut:(id)sender{
	UIAlertController* alert = [UIAlertController
								alertControllerWithTitle:@"Are you sure you want to log out?"
								message:@"Your saved credentials will be erased."
								preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction* defaultAction = [UIAlertAction
									actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault
         handler:^(UIAlertAction * action) {
			 KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"LIONeL" accessGroup:nil];
			 [keychainItem resetKeychainItem];
			 [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"logged_in"];

			 
			 LoginViewController *lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
			 [self presentViewController:lvc animated:YES completion:nil];}];

	UIAlertAction* cancelAction = [UIAlertAction
									actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
         handler:^(UIAlertAction * action) {}];
	
	[alert addAction:defaultAction];
	[alert addAction:cancelAction];
	[self presentViewController:alert animated:YES completion:nil];
}



- (void)genpreloads {
	for (int i = 0; i <= 9; i++)
	{
		NSMutableString *pageName;
		
		pageName = [pageNames objectAtIndex:i];
		
		TimetableTableViewController *tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"TimetableTableViewController"];
		
		tvc.classes = [classes objectAtIndex:i];
		tvc.day = pageName;
		tvc.pageIndex = i;
        
        [tvc view];
        [tvc.table reloadData];
        
		NSLog(@"tvc generated %d", tvc==nil);
	
		[preloads addObject:tvc];
        
        [self.view addSubview:tvc.view];
	}
	NSLog(@"Preload complete");
    NSLog(@"%@",preloads);
}

-(IBAction)today:(id)sender{

	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
	int weekday = (int)[comps weekday]-1;
    
    weekday = weekday % 7;
	
	[gregorian setFirstWeekday:2];
	NSDateComponents *dateComponent = [gregorian components:NSCalendarUnitWeekOfYear fromDate:[NSDate date]];
	week = ((int)dateComponent.weekOfYear); // + (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"weekParity"]) % 2;
	
	int realWeek = week;
	
	NSLog(@"Day is %d",weekday);
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:[NSDate date]];
    
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
	
    if (weekday >= 1 && weekday < 5 && (hour >= 15 || (hour == 14 && minute >= 45)))
    {
        weekday += 1;
    }
    else if (weekday == 5 && (hour >= 15 || (hour == 14 && minute >= 45)))
    {
        weekday = 1;
		realWeek = (realWeek + 1) % 2;
    }
	else if (weekday == 6 || weekday == 0)
    {
		weekday = 1;
		realWeek = (realWeek + 1) % 2;
	}
    
    NSLog(@"Real day is %d",weekday);
    
	//[NSInteger] *targetPage = [NSInteger numberWithInt:((week-1)*5 + weekday)];
	
	NSUInteger targetPage = (NSUInteger)(realWeek*5 + weekday);
    
	[self flipToPage: targetPage - 1];
	
	/*__weak UIPageViewController* pvcw = self.pageViewController;
	[self.pageViewController setViewControllers:@[targetPage]
				  direction:UIPageViewControllerNavigationDirectionForward
				   animated:YES completion:^(BOOL finished) {
					   UIPageViewController* pvcs = pvcw;
					   if (!pvcs) return;
					   dispatch_async(dispatch_get_main_queue(), ^{
						   [pvcs setViewControllers:@[targetPage]
										  direction:UIPageViewControllerNavigationDirectionForward
										   animated:NO completion:nil];
					   });
				   }];*/
}

-(void) flipToPage:(NSUInteger)index {
    NSArray *viewControllers = nil;
    
    if (!firstPageLoaded)
    {
		NSLog(@"First page flip index: %lu", (unsigned long)index);
	
        TimetableTableViewController *viewController = [self viewControllerAtIndex:index];

        viewControllers = [NSArray arrayWithObjects:viewController, nil];
        
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
	
        return;
    }
    
    
    TimetableTableViewController *theCurrentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
	
	NSUInteger retrievedIndex = theCurrentViewController.pageIndex;
	
	TimetableTableViewController *viewController = [self viewControllerAtIndex:index];
		
	viewControllers = [NSArray arrayWithObjects:viewController, nil];
	
    NSLog(@"%lu", (unsigned long)index);
    NSLog(@"%lu", (unsigned long)retrievedIndex);
    
	if (index == retrievedIndex){
		
		[self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
		
	} else if (((int)index - (int)retrievedIndex + 10) % 10 > 5)
    {
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:NULL];
	}
    else
    {
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];    }
} 



- (void)parseTimetable{
    pageNames = [NSArray arrayWithObjects:@"Monday (Week 1)", @"Tuesday (Week 1)",@"Wednesday (Week 1)",@"Thursday (Week 1)", @"Friday (Week 1)", @"Monday (Week 2)", @"Tuesday (Week 2)", @"Wednesday (Week 2)", @"Thursday (Week 2)", @"Friday (Week 2)", nil];
    periodStrings = [NSArray arrayWithObjects:@"Period 1",@"Period 2",@"Period 3",@"Period 4", @"Period 5", nil];
    classes = [[NSMutableArray alloc] init];
    
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filepath = [dir stringByAppendingPathComponent:@"timetable.txt"];
    //NSLog(@"%@",filepath);
    NSString *timetableString = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
    NSData *timetableData = [timetableString dataUsingEncoding:NSUTF8StringEncoding];
	
	//NSLog(@"%@",[[NSString alloc] initWithData:timetableData encoding:NSUTF8StringEncoding]);
    //Parsing
    TFHpple *timetable = [[TFHpple alloc] initWithHTMLData:timetableData];
    NSMutableArray *classByPeriod = [[NSMutableArray alloc] init];
    [classByPeriod addObject:(NSArray *)[timetable searchWithXPathQuery:@"//tr/td[@class='cell c1'] | //tr/td[@class='empty cell c1']"]];
    [classByPeriod addObject:(NSArray *)[timetable searchWithXPathQuery:@"//tr/td[@class='cell c2'] | //tr/td[@class='empty cell c2']"]];
    [classByPeriod addObject:(NSArray *)[timetable searchWithXPathQuery:@"//tr/td[@class='cell c3'] | //tr/td[@class='empty cell c3']"]];
    [classByPeriod addObject:(NSArray *)[timetable searchWithXPathQuery:@"//tr/td[@class='cell c4'] | //tr/td[@class='empty cell c4']"]];
    [classByPeriod addObject:(NSArray *)[timetable searchWithXPathQuery:@"//tr/td[@class='cell c5'] | //tr/td[@class='empty cell c5']"]];
	
    for(int i = 0; i<10;i++){
        NSLog(@"Creating day %d classes.",i);
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        
        for(int j = 0; j<5;j++){
            @try{
                NSArray *periodClasses = [classByPeriod objectAtIndex:j];
                TFHppleElement *tempElement = [periodClasses objectAtIndex:i];
                NSMutableArray *classDetails = [[NSMutableArray alloc]init];
				
				NSLog(@"%lu", (unsigned long)[[tempElement content] length]);
				
                if([[tempElement content] length] < 5){
					NSLog(@"Free Period!");
                    [classDetails addObject:@"Free Period"];
                    [classDetails addObject:@"Wherever you want!"];
                    [classDetails addObject:@"Free Period"];
					[classDetails addObject:@"Yourself"];
					[classDetails addObject:@"16luongl1@kgv.hk"];
                }else{
                    NSString *classString = [tempElement raw];
                    NSString *c = [classString substringFromIndex:29];
                    NSString *classCode = [c substringToIndex:7];
                    NSString *a = [c substringFromIndex:9];
                    NSArray *b = [a componentsSeparatedByString:@"<br/>"];
                    NSString *classRoom = [b objectAtIndex:0];
                    NSString *className = [b objectAtIndex:1];
                    NSString *classTeacher = [[[b objectAtIndex:2]componentsSeparatedByString:@" <a"]objectAtIndex:0];
					NSString *email = [[[[[[[b objectAtIndex:2]componentsSeparatedByString:@" <a"]objectAtIndex:1]componentsSeparatedByString:@"mailto:"]objectAtIndex:1]componentsSeparatedByString:@"\" class="]objectAtIndex:0];
                    
                    [classDetails addObject:classCode];
                    [classDetails addObject:classRoom];
                    [classDetails addObject:className];
					[classDetails addObject:classTeacher];
					[classDetails addObject:email];
                }
                //NSLog(@"%@",classDetails);
                
                [temp addObject:classDetails];
            }
            @catch (NSException *e){
                NSLog(@"PROBLEM Error: %@",e);
            }
        }
        [classes addObject:temp];
    }
    
    NSLog(@"%@", classes);
}

- (TimetableTableViewController *)viewControllerAtIndex:(NSUInteger)index
{
	if (index >= 10) {
		return nil;
	}
    
    if (!firstPageLoaded)
    {
        [self genpreloads];
        firstPageLoaded = true;
    }
    else
    {
        NSLog(@"Preparing TableView");
        [[preloads[index] view] removeFromSuperview];
    }
	
	NSLog(@"Loading %lu", (unsigned long)index);
    
	return preloads[index];
}

#pragma mark - Timetable Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((TimetableTableViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index = (index + 9) % 10;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((TimetableTableViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    
    index = index % 10;
    
    return [self viewControllerAtIndex:index];
}


- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return 10;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
	TimetableTableViewController *currentVC = (pageViewController.viewControllers)[0];
	return currentVC.pageIndex;
}

@end
