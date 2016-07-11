//
//  TimetableTableViewController.h
//  Lionel3
//
//  Created by Rahul Arya on 18/3/16.
//  Copyright (c) 2016 No Empty Promises. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimetableTableViewController : UITableViewController

@property (nonatomic) NSArray *classes;
@property (nonatomic) NSString *day;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property NSUInteger pageIndex;

@end
