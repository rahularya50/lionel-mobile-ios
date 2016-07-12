//
//  TimetableExpandedViewController.m
//  Lionel3
//
//  Created by Rahul Arya on 24/4/2016.
//  Copyright © 2016 No Empty Promises. All rights reserved.
//

#import "TimetableExpandedViewController.h"

@interface TimetableExpandedViewController ()

@end

@implementation TimetableExpandedViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
	self.classLabel.text = self.className;
	
	_keys = [[NSMutableArray alloc]initWithObjects: @"Period", @"Location", @"Class Code", @"Teacher", @"Email", nil];
	_values = [[NSMutableArray alloc]initWithObjects: _period, _classroom, _classCode, _teacher, _email, nil];
}

- (void)viewDidAppear {
	[self.tableView sizeToFit];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:
(NSInteger)section{
	if (section == 0)
	{
		return 5;
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
(NSIndexPath *)indexPath{
	
	if (indexPath.row >= 5)
	{
		return nil;
	}
	
	static NSString *cellIdentifier = @"cellID";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
							 cellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc]initWithStyle:
				UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
	}
	NSString *key = [_keys objectAtIndex:indexPath.row];
	NSString *value = [_values objectAtIndex:indexPath.row];

	[cell.textLabel setText:key];
	[cell.detailTextLabel setText:value];
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:
(NSInteger)section{

	return @"";
}

@end
