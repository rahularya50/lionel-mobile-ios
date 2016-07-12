//
//  HomeworkExpandedViewController.h
//  Lionel3
//
//  Created by Rahul Arya on 26/3/2016.
//  Copyright © 2016 No Empty Promises. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeworkExpandedViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *classLabel;
@property (weak, nonatomic) IBOutlet UILabel *dueLabel;
@property (weak, nonatomic) IBOutlet UILabel *teacherLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UITextView *homeworkLabel;

@property NSMutableString *className;
@property NSMutableString *teacher;
@property NSMutableString *dueDate;
@property NSMutableString *time;
@property NSMutableString *desc;
@property NSMutableString *classCode;
@end
