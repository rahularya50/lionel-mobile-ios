//
//  HomeworkTableViewController.m
//  Lionel3
//
//  Created by Rahul Arya on 20/3/16.
//  Copyright (c) 2016 No Empty Promises. All rights reserved.
//

#import "HomeworkTableViewController.h"
#import "TFHpple.h"
#import "HomeworkViewCell.h"
#import "HomeworkExpandedViewController.h"
#import "LoginViewController.h"
#import "Sync.h"
#import "KeychainWrapper.h"

@interface HomeworkTableViewController ()
{
    NSMutableArray *descriptions;
    NSMutableArray *teachers;
    NSMutableArray *classCodes;
    NSMutableArray *times;
    NSMutableArray *dueDates;
    NSMutableArray *classNames;
    NSMutableArray *classes;
    int item;
}
@end

@implementation HomeworkTableViewController

- (void)viewDidLoad {
    item = 0;
    //[self parseHomework];
    //[super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIBarButtonItem *logOut = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStylePlain target:self action:@selector(logOut:)];
    self.navigationItem.leftBarButtonItem = logOut;
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [self parseHomework];
    [super viewDidLoad];
    
    [self.tableView reloadData];
}

-(IBAction)logOut:(id)sender{
	UIAlertController* alert = [UIAlertController
								alertControllerWithTitle:@"Are you sure you want to log out?"
								message:@"Your saved credentials will be erased."
								preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction* defaultAction = [UIAlertAction
									actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault
         handler:^(UIAlertAction * action) {	KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"LIONeL" accessGroup:nil];
			 [keychainItem resetKeychainItem];
			 
			 LoginViewController *lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
			 [self presentViewController:lvc animated:YES completion:nil];}];
	
	UIAlertAction* cancelAction = [UIAlertAction
								   actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
								   handler:^(UIAlertAction * action) {}];
	
	[alert addAction:defaultAction];
	[alert addAction:cancelAction];
	[self presentViewController:alert animated:YES completion:nil];
}

- (void) parseHomework{
    classCodes = [[NSMutableArray alloc] init];
    times = [[NSMutableArray alloc] init];
    classNames = [[NSMutableArray alloc] init];
    dueDates = [[NSMutableArray alloc] init];
    teachers = [[NSMutableArray alloc] init];
    descriptions = [[NSMutableArray alloc] init];
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filepath = [dir stringByAppendingPathComponent:@"homework.txt"];
    NSString *homeworkString = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
    NSData *homeworkData = [homeworkString dataUsingEncoding:NSUTF8StringEncoding];
    
    //Getting class list
    NSString *tFile = [dir stringByAppendingPathComponent:@"timetable.txt"];
    NSData *timetableData = [[NSString stringWithContentsOfFile:tFile encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    
    TFHpple *timetable = [[TFHpple alloc] initWithHTMLData:timetableData];
    NSMutableArray *classByPeriod = [[NSMutableArray alloc] init];
	[classByPeriod addObject:(NSArray *)[timetable searchWithXPathQuery:@"//tr/td[@class='cell c1'] | //tr/td[@class='empty cell c1']"]];
	[classByPeriod addObject:(NSArray *)[timetable searchWithXPathQuery:@"//tr/td[@class='cell c2'] | //tr/td[@class='empty cell c2']"]];
	[classByPeriod addObject:(NSArray *)[timetable searchWithXPathQuery:@"//tr/td[@class='cell c3'] | //tr/td[@class='empty cell c3']"]];
	[classByPeriod addObject:(NSArray *)[timetable searchWithXPathQuery:@"//tr/td[@class='cell c4'] | //tr/td[@class='empty cell c4']"]];
	[classByPeriod addObject:(NSArray *)[timetable searchWithXPathQuery:@"//tr/td[@class='cell c5'] | //tr/td[@class='empty cell c5']"]];
    classes = [[NSMutableArray alloc] init];
    for(int i = 0; i<10;i++){
        for(int j = 0; j<5;j++){
            @try{
                NSArray *periodClasses = [classByPeriod objectAtIndex:j];
                TFHppleElement *tempElement = [periodClasses objectAtIndex:i];
                NSMutableArray *classDetails = [[NSMutableArray alloc]init];
				if([[tempElement content] length] < 5){
                    [classDetails addObject:@"Free"];
                    [classDetails addObject:@"Free"];
                }else{
                    NSString *classString = [tempElement raw];
                    NSString *c = [classString substringFromIndex:29];
                    NSString *classCode = [c substringToIndex:7];
                    NSString *a = [c substringFromIndex:9];
                    NSArray *b = [a componentsSeparatedByString:@"<br/>"];
                    NSString *className = [b objectAtIndex:1];
                    [classDetails addObject:classCode];
                    [classDetails addObject:className];

                }
                //NSLog(@"%@",classDetails);
                int status = 0;
                for(NSArray *class in classes){
                    if([[class objectAtIndex:0]isEqualToString:[classDetails objectAtIndex:0]]){
                        status = 1;
                        break;
                    }
                }
                if(status==0){
                    [classes addObject:classDetails];
                }
            }
            @catch (NSException *e){
                NSLog(@"PROBLEM Error: %@",e);
            }
        }
    }
    //NSLog(@"%@", classes);

    
    //NSLog(@"%@",homeworkData);
    //Parsing homework
    
    TFHpple *homework = [[TFHpple alloc] initWithHTMLData:homeworkData];
    NSMutableArray *elements = [[homework searchWithXPathQuery:@"//div[@class=' homework']/div"]mutableCopy];
	
	for (int i=0; i<elements.count; i++) {
		NSString *code;
		NSString *className;
		NSString *time;
		NSString *dueDate;
		NSString *body;
		NSString *teacher;
		
		TFHppleElement *element = elements[i];
		
		@try {
			code = [[[element searchWithXPathQuery:@"//div[@class=' span3']/div/div"] objectAtIndex: 1] content];
		}
		@catch (NSException *e) {
			code = @"Unknown";
		}
		@try {
			time = [[[element searchWithXPathQuery:@"//div[@class=' span3']/div/div"] objectAtIndex: 2] content];
		}
		@catch (NSException *e) {
			time = @"Unknown";
		}
		@try {
			dueDate = [[[[element searchWithXPathQuery:@"//div[@class=' span3']/div/div"] objectAtIndex: 3] content] substringFromIndex:7];
		}
		@catch (NSException *e) {
			dueDate = @"Unknown";
		}
		@try {
			body = [[[element searchWithXPathQuery:@"//div[@class=' span6']/div"] objectAtIndex:1] content];
		}
		@catch (NSException *e) {
			body = @"Unknown";
		}
		@try {
			teacher = [[[[[element searchWithXPathQuery:@"//div[@class=' span6']/div"] objectAtIndex:2] searchWithXPathQuery: @"//p"] objectAtIndex:0] content];
		}
		@catch (NSException *e) {
			teacher = @"Unknown";
		}
		
		className = code;
		
		for (int j = 0; j < classes.count; j++)
		{
			if ([classes[j] objectAtIndex: 0] == code) {
				className = [classes[j] objectAtIndex: 1];
			}
		}
		
		[descriptions addObject:body];
		[teachers addObject: teacher];
		[classCodes addObject:code];
		[dueDates addObject: dueDate];
		[times addObject:time];
		[classNames addObject:className];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return descriptions.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    //NSLog(@"%@", item);
    
    NSLog(@"Creating row %d",item);
    HomeworkViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeworkViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    //NSLog(@"%@",classNames);
    
    cell.classLabel.text = [classNames objectAtIndex:indexPath.row];
    cell.codeLabel.text = [classCodes objectAtIndex:indexPath.row];
    cell.teacherLabel.text = [teachers objectAtIndex:indexPath.row];
    cell.descriptionLabel.text = [descriptions objectAtIndex:indexPath.row];
    cell.timeLabel.text = [times objectAtIndex:indexPath.row];
    cell.dueLabel.text = [dueDates objectAtIndex:indexPath.row];
	
	cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    //cell.descriptionLabel.numberOfLines = 0;
    
    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
    HomeworkExpandedViewController *hevc = [[HomeworkExpandedViewController alloc] initWithNibName:@"HomeworkExpandedViewController" bundle:nil];
    
    //NSLog(@"Class Name: %@",[classNames objectAtIndex:index]);

    hevc.className = [classNames objectAtIndex:indexPath.row];
    hevc.dueDate = [dueDates objectAtIndex:indexPath.row];
    hevc.teacher = [teachers objectAtIndex:indexPath.row];
    hevc.time = [times objectAtIndex:indexPath.row];
    hevc.classCode = [classCodes objectAtIndex:indexPath.row];
    hevc.desc = [descriptions objectAtIndex:indexPath.row];
    //NSLog(@"Pushing %@",hevc.className);
    
    
    [self.navigationController pushViewController:hevc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
/*
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(selectedCellIndex && indexPath.row == selectedCellIndex.row){
        return 300;
    }
    return 180;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)refresh:(UIRefreshControl *)sender {
	NSLog(@"Reloading");
	
	Sync *syncer = [[Sync alloc] init];
	
	dispatch_queue_t queue = dispatch_queue_create("com.noemptypromises.Lionel3", NULL);
	dispatch_async(queue, ^{
        NSString *username;
        NSString *password;
        
        /*NSString *userData = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
		
		NSString *username = [[userData componentsSeparatedByString:@"^"] objectAtIndex:0];
		NSString *password = [[userData componentsSeparatedByString:@"^"] objectAtIndex:1];*/
        
        KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"LIONeL" accessGroup:nil];
        
        username = [keychainItem objectForKey:(__bridge id)kSecAttrAccount];
        password = [[NSString alloc] initWithData:[keychainItem objectForKey:(__bridge id)kSecValueData] encoding:NSUTF8StringEncoding];
		
		@try{
			NSLog(@"%@", username);
            if (![syncer login:username andPassword: password])
            {
                [sender endRefreshing];
                return;
            }
        }
		@catch(NSException *e){
			NSLog(@"Wrong pw!");
			NSLog(@"%@",e);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication Error"
                                                            message:@"An unexpected error occurred. Please try logging out and reentering your LIONeL credentials. If this error persists, please contact Lilian Luong at 16luongl1@kgv.hk."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.tableView reloadData];
			
			[sender endRefreshing];
			[self parseHomework];
			[self.tableView reloadData];
		});
	});
}
@end
