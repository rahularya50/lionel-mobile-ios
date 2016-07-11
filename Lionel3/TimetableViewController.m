//
//  TimetableViewController.m
//  Lionel3
//
//  Created by Rahul Arya on 16/3/16.
//  Copyright (c) 2016 No Empty Promises. All rights reserved.
//

#import "TimetableViewController.h"
#import "TimetableTableViewController.h"
#import "TFHpple.h"
#import "LoginViewController.h"

@interface TimetableViewController ()
{
    NSArray *pageNames;
    NSArray *periodStrings;
    NSMutableArray *classes;
    int week;
}
@end

@implementation TimetableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _scrollView.scrollEnabled = YES;
    [self parseTimetable];
    UIBarButtonItem *logOut = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStylePlain target:self action:@selector(logOut:)];
    self.navigationItem.leftBarButtonItem = logOut;
    // Do any additional setup after loading the view.
}

-(IBAction)logOut:(id)sender{
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filepath = [dir stringByAppendingPathComponent:@"userAuth.txt"];
    [@"" writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    LoginViewController *lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self presentViewController:lvc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    //NSLog(@"%f",self.view.frame.size.width);
    _scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _scrollView.contentInset = UIEdgeInsetsZero;
    _scrollView.contentOffset = CGPointZero;
    _scrollView.contentSize = CGSizeMake(12*_scrollView.bounds.size.width,_scrollView.frame.size.height);
    int i = 1;
    while(i<13){
        NSLog(@"%d", i);
        [self loadPage:i];
        i++;
    }
    [_pageControl setFrame:CGRectMake(0,self.view.frame.size.height-90,self.view.frame.size.width,30)];
    [self.view addSubview:_pageControl];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    int weekday = (int)[comps weekday]-1;
    NSLog(@"Day is %d",weekday);
    if(weekday>5 || weekday==0){
        weekday = 1;
    }
    int targetPage = ((week-1)*5 + weekday);
    //NSLog(@"%d",targetPage);
    [_scrollView scrollRectToVisible:CGRectMake(_scrollView.contentOffset.x+targetPage*_scrollView.frame.size.width,0,_scrollView.frame.size.width,_scrollView.frame.size.height) animated:NO];
}

- (void)loadPage:(NSInteger)page{
    NSMutableString *pageName;
    if(page==1){
        pageName = [pageNames objectAtIndex:9];
    }else if(page==12){
        pageName = [pageNames objectAtIndex:0];
    }else{
        pageName =[pageNames objectAtIndex:page-2];
    }
    
    //CGRect tableFrame = CGRectMake(page*_scrollView.frame.size.width,0,_scrollView.frame.size.width,_scrollView.frame.size.height);
    
    TimetableTableViewController *tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"TimetableTableViewController"];
    CGFloat pageWidth = _scrollView.bounds.size.width;
    //tvc.view.bounds = CGRectMake((pageWidth)*(page-1),0,pageWidth,_scrollView.bounds.size.height);
    if(page==1){
        tvc.classes = [classes objectAtIndex:10];
    }else if(page==12){
        tvc.classes = [classes objectAtIndex:0];
    }else{
        tvc.classes = [classes objectAtIndex:page-1];
    }
    tvc.day = pageName;
    
    NSLog(@"%ld", (long)page);
    
    [self addChildViewController:tvc];
    [_scrollView addSubview:tvc.view];
    [tvc didMoveToParentViewController:self];
    
    //tvc.view.bounds = CGRectMake((pageWidth)*(page-1),0,pageWidth,_scrollView.bounds.size.height);
    //tvc.view.frame = CGRectMake((pageWidth)*(page-1),0,pageWidth,_scrollView.bounds.size.height);
    NSLog(@"%f",tvc.view.center.x);
    
       /*
    if(page<12){
        [self loadPage:page+1];
    }else if(page==12){
        [self.view addSubview:_pageControl];
    }
     */
}

-(void)scrollViewDidScroll:(UIScrollView *)sender{
    _scrollView.contentOffset = CGPointMake(_scrollView.contentOffset.x,-64);
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x-(pageWidth/2))/pageWidth)+1;
    _pageControl.currentPage = page-1;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)sender{
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x)/pageWidth)+1;
    if(page==1){
        //[_scrollView scrollRectToVisible:CGRectMake(pageWidth*10,0,pageWidth,_scrollView.frame.size.height) animated:NO];
    }else if(page==12){
        //[_scrollView scrollRectToVisible:CGRectMake(pageWidth,0,pageWidth,_scrollView.frame.size.height) animated:NO];
    }
    int p2 = floor((_scrollView.contentOffset.x-(pageWidth/2))/pageWidth)+1;
    _pageControl.currentPage = p2-1;
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
