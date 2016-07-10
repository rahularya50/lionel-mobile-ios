//
//  BulletinViewCell.h
//  Lionel3
//
//  Created by Rahul Arya on 28/3/2016.
//  Copyright © 2016 No Empty Promises. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BulletinViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *datesLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *previewLabel;
@property (nonatomic, retain) IBOutlet UITextView *textsLabel;

@property (weak, nonatomic) IBOutlet UIView *cardView;

@end
