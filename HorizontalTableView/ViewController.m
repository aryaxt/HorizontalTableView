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
}

#pragma mark - HorizontalTableViewDelegate & HorizontalTableViewDataSource -

- (NSInteger)numberOfRowsInHorizontalTableView:(HorizontalTableView *)horizontalTableView
{
	return 30;
}

- (CGFloat)horizontalTableView:(HorizontalTableView *)horizontalTableView widthForColumAtIndex:(NSInteger)index
{
	return 30;
}

- (UIView *)horizontalTableView:(HorizontalTableView *)horizontalTableView viewForColumnAtIndex:(NSInteger)index
{
	return [[UIView alloc] init];
}

- (void)horizontalTableView:(HorizontalTableView *)horizontalTableView didSelectColumnAtIndex:(NSInteger)index
{
	
}

@end
