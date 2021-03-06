//
//  TimetableTableViewController.m
//  Lionel3
//
//  Created by Rahul Arya on 18/3/16.
//  Copyright (c) 2016 No Empty Promises. All rights reserved.
//

#import "TimetableTableViewController.h"
#import "TimetableViewCell.h"
#import "TimetableExpandedViewController.h"
#import "Sync.h"

@interface TimetableTableViewController ()
//- (IBAction)refresh:(UIRefreshControl *)sender;
@end


@implementation TimetableTableViewController
@synthesize table;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"TimetableDayLoaded");
    
    table.alwaysBounceVertical = NO;
    
    NSLog(@"%lu", (unsigned long)_pageIndex);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[[self view] setFrame:[[UIScreen mainScreen] bounds]];
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
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int item = (int)indexPath.row;
    
    tableView.rowHeight = 100;
    TimetableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimetableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.periodLabel.text = [@"Period " stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)item+1]];
    cell.classLabel.text = [[_classes objectAtIndex:item]objectAtIndex:2];
    cell.classLabel.numberOfLines = 0;
    //cell.daycodeLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)_pageIndex];
	
	cell.selectionStyle = UITableViewCellSelectionStyleDefault;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    
    view.tintColor = [UIColor colorWithRed:0.984 green:0.686 blue:0.247 alpha:1];
    
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	[[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextAlignment:NSTextAlignmentCenter];
    
	return _day;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 40.0f;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger index = indexPath.row;
	
	
	
    TimetableExpandedViewController *tevc = [[TimetableExpandedViewController alloc] initWithNibName:@"TimetableExpandedViewController" bundle:nil];
	
    //NSLog(@"Class Name: %@",[classNames objectAtIndex:index]);
    
    tevc.className = [[_classes objectAtIndex:index]objectAtIndex:2];
    tevc.classroom = [[_classes objectAtIndex:index]objectAtIndex:1];
    tevc.classCode = [[_classes objectAtIndex:index]objectAtIndex:0];
	tevc.teacher = [[_classes objectAtIndex:index]objectAtIndex:3];
	tevc.email = [[_classes objectAtIndex:index]objectAtIndex:4];
	tevc.period = [@"Period " stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)indexPath.row+1]];
	
    [self.navigationController pushViewController:tevc animated:YES];
}


- (IBAction)refresh:(UIRefreshControl *)sender {
	NSLog(@"Reloading");
	
	//Sync *syncer = [[Sync alloc] init];
	
	dispatch_queue_t queue = dispatch_queue_create("com.noemptypromises.Lionel3", NULL);
	dispatch_async(queue, ^{
		//[syncer login];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.tableView reloadData];
			
			[sender endRefreshing];
			//Reload TableView
		});
	});
}

@end
