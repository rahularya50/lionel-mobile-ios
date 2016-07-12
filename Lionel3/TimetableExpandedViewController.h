//
//  TimetableExpandedViewController.h
//  Lionel3
//
//  Created by Rahul Arya on 24/4/2016.
//  Copyright © 2016 No Empty Promises. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimetableExpandedViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *classLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property NSMutableString *className;
@property NSMutableString *teacher;
@property NSMutableString *classroom;
@property NSMutableString *classCode;
@property NSString *period;
@property NSMutableString *email;

@property NSMutableArray *keys;
@property NSMutableArray *values;
@end
