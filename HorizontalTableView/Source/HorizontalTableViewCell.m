//
//  HorizontalTableViewCell.m
//  HorizontalTableView
//
//  Created by Aryan Gh on 1/29/14.
//  Copyright (c) 2014 Aryan Ghassemi. All rights reserved.
//

#import "HorizontalTableViewCell.h"

@implementation HorizontalTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	self.backgroundColor = (selected) ? [UIColor blueColor] : [UIColor whiteColor];
}

- (void)setHighLighted:(BOOL)highLighted animated:(BOOL)animated
{
	self.backgroundColor = (highLighted) ? [UIColor grayColor] : [UIColor whiteColor];
}

@end
