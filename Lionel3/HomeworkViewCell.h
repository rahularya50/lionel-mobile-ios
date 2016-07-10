//
//  HomeworkViewCell.h
//  Lionel3
//
//  Created by Rahul Arya on 22/3/16.
//  Copyright (c) 2016 No Empty Promises. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeworkViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *classLabel;
@property (weak, nonatomic) IBOutlet UILabel *dueLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *teacherLabel;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (nonatomic, retain) IBOutlet UITextView *descriptionLabel;

@property (weak, nonatomic) IBOutlet UIView *cardView;

@end
