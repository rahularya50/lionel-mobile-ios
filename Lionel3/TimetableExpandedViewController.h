//
//  TimetableExpandedViewController.h
//  Lionel3
//
//  Created by Rahul Arya on 24/4/2016.
//  Copyright © 2016 No Empty Promises. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimetableExpandedViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *teacherLabel;
@property (weak, nonatomic) IBOutlet UILabel *classroomLabel;
@property (weak, nonatomic) IBOutlet UILabel *classCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *classLabel;

@property NSMutableString *className;
@property NSMutableString *teacher;
@property NSMutableString *classroom;
@property NSMutableString *classCode;

@end
