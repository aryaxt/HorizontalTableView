//
//  MyCell.m
//  HorizontalTableView
//
//  Created by Aryan Ghassemi on 1/30/14.
//  Copyright (c) 2014 Aryan Ghassemi. All rights reserved.
//

#import "MyCell.h"

@implementation MyCell

- (id)init
{
	self = [[[NSBundle mainBundle] loadNibNamed:@"MyCell" owner:nil options:nil] lastObject];
	self.identifier = @"MyCell";
	self.layer.borderWidth = .4;
	self.layer.borderColor = [UIColor blackColor].CGColor;
	return self;
}

@end
