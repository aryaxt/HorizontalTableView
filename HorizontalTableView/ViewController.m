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
	
	self.horizontalTableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
	self.horizontalTableView.layer.borderWidth = .6;
	
	self.horizontalTableView.delegate = self;
	self.horizontalTableView.dataSource = self;
	[self.horizontalTableView reloadData];
}

#pragma mark - HorizontalTableViewDelegate & HorizontalTableViewDataSource -

- (NSInteger)numberOfColumnsInHorizontalTableView:(HorizontalTableView *)horizontalTableView
{
	return 500;
}

- (CGFloat)horizontalTableView:(HorizontalTableView *)horizontalTableView widthForColumAtIndex:(NSInteger)index
{
	return (index%2 == 0) ? 50 : 100;
}

- (HorizontalTableViewCell *)horizontalTableView:(HorizontalTableView *)horizontalTableView cellForColumnAtIndex:(NSInteger)index
{
	MyCell *cell = (MyCell *) [self.horizontalTableView dequeueReusableViewWithIdentifier:@"MyView"];
	
	if (!cell)
		cell = [[MyCell alloc] init];
	
	cell.lblTitle.text = [NSString stringWithFormat:@"%d", index];
	cell.lblTitle.backgroundColor = (index%2 == 0) ? [UIColor greenColor] : [UIColor redColor];
	
	return cell;
}

- (void)horizontalTableView:(HorizontalTableView *)horizontalTableView didSelectColumnAtIndex:(NSInteger)index
{
	
}

@end
