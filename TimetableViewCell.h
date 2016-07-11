//
//  TimetableViewCell.h
//  Lionel3
//
//  Created by Rahul Arya on 16/3/16.
//  Copyright (c) 2016 No Empty Promises. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimetableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *classLabel;
@property (weak, nonatomic) IBOutlet UILabel *periodLabel;
@property (weak, nonatomic) IBOutlet UILabel *daycodeLabel;

@end
