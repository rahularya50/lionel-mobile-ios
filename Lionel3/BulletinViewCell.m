//
//  BulletinViewCell.m
//  Lionel3
//
//  Created by Rahul Arya on 28/3/2016.
//  Copyright © 2016 No Empty Promises. All rights reserved.
//

#import "BulletinViewCell.h"

@implementation BulletinViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) layoutSubviews {
    [self cardSetup];
}

-(void)cardSetup
{
    [self.cardView setAlpha:1];
    self.cardView.layer.masksToBounds = NO;
    
    self.cardView.layer.borderColor = [UIColor clearColor].CGColor;
    
    //self.cardView.layer.borderWidth = 1;
    //self.cardView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.cardView.layer.cornerRadius = 2; // if you like rounded corners
    self.cardView.layer.shadowOffset = CGSizeMake(-.2f, .2f); //%%% this shadow will hang slightly down and to the right
    self.cardView.layer.shadowRadius = 1; //%%% I prefer thinner, subtler shadows, but you can play with this
    self.cardView.layer.shadowOpacity = 0.2; //%%% same thing with this, subtle is better for me
    
    //%%% This is a little hard to explain, but basically, it lowers the performance required to build shadows.  If you don't use this, it will lag
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.cardView.bounds];
    self.cardView.layer.shadowPath = path.CGPath;
    
	self.textsLabel.contentInset = UIEdgeInsetsMake(-4, -4, 0, 0);
	[self.textsLabel setFont:[UIFont systemFontOfSize:16]];
	self.previewLabel.contentInset = UIEdgeInsetsMake(-4, -4, 0, 0);
	[self.previewLabel setFont:[UIFont systemFontOfSize:16]];
	
    self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1]; //%%% I prefer choosing colors programmatically than on the storyboard
}

@synthesize textsLabel;

@end
