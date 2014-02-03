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
	
	self.arrayOfStrings = [NSMutableArray array];
	
	for (int i=0 ; i<100 ; i++)
	{
		//[self.arrayOfStrings addObject:[NSString stringWithFormat:@"Cell %d", i]];
	}
	
	
	self.horizontalTableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
	self.horizontalTableView.layer.borderWidth = .6;
	
	self.horizontalTableView.delegate = self;
	self.horizontalTableView.dataSource = self;
	[self.horizontalTableView reloadData];
	
	[self printCellStats];
}

#pragma mark - HorizontalTableViewDelegate & HorizontalTableViewDataSource -

- (NSInteger)numberOfColumnsInHorizontalTableView:(HorizontalTableView *)horizontalTableView
{
	return self.arrayOfStrings.count;
}

- (CGFloat)horizontalTableView:(HorizontalTableView *)horizontalTableView widthForColumAtIndex:(int)index
{
	return 80;
	return (index%2 == 0) ? 80 : 120;
}

- (HorizontalTableViewCell *)horizontalTableView:(HorizontalTableView *)horizontalTableView cellForColumnAtIndex:(int)index
{
	MyCell *cell = (MyCell *) [self.horizontalTableView dequeueReusableViewWithIdentifier:@"MyCell"];
	
	if (!cell)
		cell = [[MyCell alloc] init];
	
	cell.lblTitle.text = [self.arrayOfStrings objectAtIndex:index];
	cell.lblTitle.backgroundColor = (index%2 == 0) ? [UIColor greenColor] : [UIColor redColor];
	
	return cell;
}

- (void)horizontalTableView:(HorizontalTableView *)horizontalTableView didSelectColumnAtIndex:(int)index
{
	
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self printCellStats];
}

#pragma mark - IBActions -

- (IBAction)addRowAndReloadTable:(id)sender
{
	[self.arrayOfStrings insertObject:[NSString stringWithFormat:@"Reload %d", self.counter] atIndex:0];
	
	[self.horizontalTableView reloadData];
	
	[self printCellStats];
	
	self.counter++;
}

- (IBAction)insertRowInTable:(id)sender
{
	[self.arrayOfStrings insertObject:[NSString stringWithFormat:@"Insert %d", self.counter] atIndex:0];
	
	[self.horizontalTableView insertColumnAtIndex:0 withColumnAnimation:HorizontalTableViewColumnAnimationNone];
	
	[self printCellStats];
	
	self.counter++;
}

- (IBAction)deleteRowInTable:(id)sender
{
	if (self.arrayOfStrings.count == 0)
		return;
	
	[self.arrayOfStrings removeObjectAtIndex:0];
	
	[self.horizontalTableView deleteColumnAtIndex:0 withColumnAnimation:HorizontalTableViewColumnAnimationNone];
	
	[self printCellStats];
}

#pragma mark - Private Methods -

- (void)printCellStats
{
	int cellsInViewCount = 0;
	for (UIView *view in self.horizontalTableView.subviews)
	{
		if ([view isKindOfClass:[HorizontalTableViewCell class]])
			cellsInViewCount++;
	}
	
	self.lblCellQueueStats.text = [NSString stringWithFormat:@"Cells in queue: %lu \nCells in view: %d \nNumber of columns: %lu",
								   (unsigned long)[[self.horizontalTableView valueForKey:@"reusableCellQueue"] count],
								   cellsInViewCount,
								   (unsigned long)self.arrayOfStrings.count];
}

@end
