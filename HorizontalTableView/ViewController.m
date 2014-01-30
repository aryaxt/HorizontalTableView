//
//  ViewController.m
//  HorizontalTableView
//
//  Created by Aryan Gh on 1/29/14.
//  Copyright (c) 2014 Aryan Ghassemi. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.horizontalTableView.delegate = self;
	self.horizontalTableView.dataSource = self;
	[self.horizontalTableView reloadData];
}

#pragma mark - HorizontalTableViewDelegate & HorizontalTableViewDataSource -

- (NSInteger)numberOfColumnsInHorizontalTableView:(HorizontalTableView *)horizontalTableView
{
	return 30;
}

- (CGFloat)horizontalTableView:(HorizontalTableView *)horizontalTableView widthForColumAtIndex:(NSInteger)index
{
	return 100;
}

- (HorizontalTableViewCell *)horizontalTableView:(HorizontalTableView *)horizontalTableView cellForColumnAtIndex:(NSInteger)index
{
	HorizontalTableViewCell *cell = [self.horizontalTableView dequeueReusableViewWithIdentifier:@"MyView"];
	
	if (!cell)
	{
		cell = [[HorizontalTableViewCell alloc] initWithFrame:CGRectMake(0, 0, 70, 100)];
		
		UILabel *lbl = [[UILabel alloc] initWithFrame:cell.frame];
		lbl.text = @"Hello";
		[cell addSubview:lbl];
	}
	
	return cell;
}

- (void)horizontalTableView:(HorizontalTableView *)horizontalTableView didSelectColumnAtIndex:(NSInteger)index
{
	
}

@end
