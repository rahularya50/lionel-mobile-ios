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

@interface TimetableViewController2 ()
{
    NSArray *pageNames;
    NSArray *periodStrings;
    NSMutableArray *classes;
    int week;
}
@end

@implementation TimetableViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self parseTimetable];
        
    UIBarButtonItem *logOut = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStylePlain target:self action:@selector(logOut:)];
    self.navigationItem.leftBarButtonItem = logOut;
    self.navigationItem.title = @"Home";
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TimetablePageViewController"];
    self.pageViewController.dataSource = self;
    
    TimetableTableViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)logOut:(id)sender{
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filepath = [dir stringByAppendingPathComponent:@"userAuth.txt"];
    [@"" writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    LoginViewController *lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self presentViewController:lvc animated:YES completion:nil];
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
    
    NSString *cdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *cfilepath = [cdir stringByAppendingPathComponent:@"calendar.txt"];
    NSString *calendarString = [NSString stringWithContentsOfFile:cfilepath encoding:NSUTF8StringEncoding error:nil];
    NSData *calendarData = [calendarString dataUsingEncoding:NSUTF8StringEncoding];
    //NSLog(@"%@",[[NSString alloc] initWithData:timetableData encoding:NSUTF8StringEncoding]);
    //Parsing
    TFHpple *timetable = [[TFHpple alloc] initWithHTMLData:timetableData];
    NSMutableArray *classByPeriod = [[NSMutableArray alloc] init];
    [classByPeriod addObject:(NSArray *)[timetable searchWithXPathQuery:@"//tr/td[@class='cell c1']"]];
    [classByPeriod addObject:(NSArray *)[timetable searchWithXPathQuery:@"//tr/td[@class='cell c2']"]];
    [classByPeriod addObject:(NSArray *)[timetable searchWithXPathQuery:@"//tr/td[@class='cell c3']"]];
    [classByPeriod addObject:(NSArray *)[timetable searchWithXPathQuery:@"//tr/td[@class='cell c4']"]];
    [classByPeriod addObject:(NSArray *)[timetable searchWithXPathQuery:@"//tr/td[@class='cell c5']"]];
    
    TFHpple *calendar = [[TFHpple alloc] initWithHTMLData:calendarData];
    NSString *cHeader = [[[calendar searchWithXPathQuery:@"//div[@class='smallcal']/div"] objectAtIndex:0] content];
    NSString *cWeek = [cHeader substringFromIndex:cHeader.length-1];
    week = [cWeek intValue];
    NSLog(@"This is Week %d",week);
    for(int i = 0; i<10;i++){
        //NSLog(@"Creating day %d classes.",i);
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        
        for(int j = 0; j<5;j++){
            @try{
                NSArray *periodClasses = [classByPeriod objectAtIndex:j];
                TFHppleElement *tempElement = [periodClasses objectAtIndex:i];
                NSMutableArray *classDetails = [[NSMutableArray alloc]init];
                if([[tempElement content]isEqualToString:@"&nbsp"]){
                    [classDetails addObject:@""];
                    [classDetails addObject:@""];
                    [classDetails addObject:@"Free"];
                    [classDetails addObject:@""];
                }else{
                    NSString *classString = [tempElement raw];
                    NSString *c = [classString substringFromIndex:29];
                    NSString *classCode = [c substringToIndex:7];
                    NSString *a = [c substringFromIndex:9];
                    NSArray *b = [a componentsSeparatedByString:@"<br/>"];
                    NSString *classRoom = [b objectAtIndex:0];
                    NSString *className = [b objectAtIndex:1];
                    NSString *classTeacher = [[[b objectAtIndex:2]componentsSeparatedByString:@" <a"]objectAtIndex:0];
                    
                    [classDetails addObject:classCode];
                    [classDetails addObject:classRoom];
                    [classDetails addObject:className];
                    [classDetails addObject:classTeacher];
                }
                //NSLog(@"%@",classDetails);
                
                [temp addObject:classDetails];
            }
            @catch (NSException *e){
                NSLog(@"PROBLEM Error: %@",e);
            }
        }
        if(classes.count == 0 || classes.count==10){
            [classes addObject:temp];
        }
        [classes addObject:temp];
    }
    
    NSLog(@"%@", classes);
}

- (TimetableTableViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (index >= 12) {
        return nil;
    }
    
    NSMutableString *pageName;
    if(index==0){
        pageName = [pageNames objectAtIndex:9];
    }else if(index==11){
        pageName = [pageNames objectAtIndex:0];
    }else{
        pageName =[pageNames objectAtIndex:index-1];
    }
    
    TimetableTableViewController *tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"TimetableTableViewController"];
    
    if(index==0){
        tvc.classes = [classes objectAtIndex:10];
    }else if(index==11){
        tvc.classes = [classes objectAtIndex:0];
    }else{
        tvc.classes = [classes objectAtIndex:index];
    }
    tvc.day = pageName;
    tvc.pageIndex = index;
    
    return tvc;
}

#pragma mark - Timetable Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((TimetableTableViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((TimetableTableViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == 12) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}


- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return 12;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

@end
