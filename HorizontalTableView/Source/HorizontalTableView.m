//
//  HorizontalTableView.m
//  HorizontalTableView
//
//  Created by Aryan Gh on 1/29/14.
//  Copyright (c) 2014 Aryan Ghassemi. All rights reserved.
//

#import "HorizontalTableView.h"

@interface HorizontalTableView()
@property (nonatomic, strong) NSMutableArray *reusableCellQueue;
@property (nonatomic, assign) BOOL isEditing;
@end

@implementation HorizontalTableView

#pragma mark - Initialization -

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
	{
		[self initialize];
		[self reloadData];
	}
	
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		[self initialize];
		[self reloadData];
	}
	
	return self;
}

- (void)initialize
{
	self.reusableCellQueue = [NSMutableArray array];
}

#pragma mark - Overrides -

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[self enqueueHiddenCells];
	[self addCellsToViewIfNeeded];
}

#pragma mark - Public Methods -

- (void)beginUpdates
{
	self.isEditing = YES;
}

- (void)endUpdates
{
	self.isEditing = NO;
}

- (void)reloadData
{
	[self resizeContentView];
	[self reloadCellsInVisibleContent];
}

- (HorizontalTableViewCell *)dequeueReusableViewWithIdentifier:(NSString *)identifier
{
	for (int i=0 ; i<self.reusableCellQueue.count ; i++)
	{
		HorizontalTableViewCell *cell = [self.reusableCellQueue objectAtIndex:i];
		
		if ([cell.identifier isEqual:identifier])
		{
			[self.reusableCellQueue removeObject:cell];
			return cell;
		}
	}
	
	return nil;
}

#pragma mark - Private Methods -

- (void)resizeContentView
{
	CGFloat width = 0;
	
	for (int i=0 ; i<self.numberOfColumns ; i++)
	{
		width += [self.dataSource horizontalTableView:self widthForColumAtIndex:i];
	}
	
	self.contentSize = CGSizeMake(width, self.frame.size.height);
}

- (NSInteger)numberOfColumns
{
	return [self.dataSource numberOfColumnsInHorizontalTableView:self];
}

- (HorizontalTableViewCell *)cellAtIndex:(NSInteger)index
{
	HorizontalTableViewCell *cell = [self.dataSource horizontalTableView:self cellForColumnAtIndex:index];
	cell.index = index;
	return cell;
}

- (CGFloat)widthAtIndex:(NSInteger)index
{
	return [self.dataSource horizontalTableView:self widthForColumAtIndex:index];
}

- (CGRect)visibleRect
{
	return CGRectMake(self.contentOffset.x, self.contentOffset.y, self.frame.size.width, self.frame.size.height);
}

- (void)reloadCellsInVisibleContent
{
	CGRect visibleRect = [self visibleRect];
	CGFloat x = 0;
	
	for (int i=0 ; i<self.numberOfColumns ; i++)
	{
		CGFloat widthForIndex = [self.dataSource horizontalTableView:self widthForColumAtIndex:i];
		CGRect rectForView = CGRectMake(x, 0, widthForIndex, self.frame.size.height);
		
		if (CGRectIntersectsRect(visibleRect, rectForView))
		{
			HorizontalTableViewCell *cell = [self cellAtIndex:i];
			cell.index = i;
			cell.frame = rectForView;
			[self addSubview:cell];
		}
		
		// Improve performance get out of this loop
		
		x += widthForIndex;
	}
}

- (void)addCellsToViewIfNeeded
{
	CGRect visibleRect = [self visibleRect];
	
	HorizontalTableViewCell *firstVisibleCell = [self firstVisibleCell];
	HorizontalTableViewCell *lastVisibleCell = [self lastVisibleCell];
	
	if (firstVisibleCell.frame.origin.x > visibleRect.origin.x &&
		firstVisibleCell.index > 0)
	{
		//NSLog(@"Add leftC ell");
		HorizontalTableViewCell *newFirstCell = [self cellAtIndex:firstVisibleCell.index-1];
		CGFloat width = [self widthAtIndex:firstVisibleCell.index-1];
		newFirstCell.frame = CGRectMake(firstVisibleCell.frame.origin.x - width, 0, width, self.frame.size.height);
		[self addSubview:newFirstCell];
	}
	
	if (lastVisibleCell.frame.origin.x + lastVisibleCell.frame.size.width < visibleRect.origin.x + visibleRect.size.width &&
		lastVisibleCell.index < self.numberOfColumns-1)
	{
		//NSLog(@"Add right cell");
		HorizontalTableViewCell *newLastCell = [self cellAtIndex:lastVisibleCell.index+1];
		CGFloat width = [self widthAtIndex:lastVisibleCell.index+1];
		newLastCell.frame = CGRectMake(lastVisibleCell.frame.origin.x + lastVisibleCell.frame.size.width, 0, width, self.frame.size.height);
		[self addSubview:newLastCell];
	}
}

- (HorizontalTableViewCell *)firstVisibleCell
{
	HorizontalTableViewCell *firstCell;
	
	for (UIView *view in self.subviews)
	{
		if ([view isKindOfClass:[HorizontalTableViewCell class]])
		{
			HorizontalTableViewCell *cell = (HorizontalTableViewCell *) view;
			
			if (!firstCell || cell.index < firstCell.index)
				firstCell = cell;
		}
	}
	
	return firstCell;
}

- (HorizontalTableViewCell *)lastVisibleCell
{
	HorizontalTableViewCell *lastCell;
	
	for (UIView *view in self.subviews)
	{
		if ([view isKindOfClass:[HorizontalTableViewCell class]])
		{
			HorizontalTableViewCell *cell = (HorizontalTableViewCell *) view;
			
			if (!lastCell || cell.index > lastCell.index)
				lastCell = cell;
		}
	}
	
	return lastCell;
}

- (void)enqueueHiddenCells
{
	for (UIView *view in self.subviews)
	{
		if ([view isKindOfClass:[HorizontalTableViewCell class]] && !CGRectIntersectsRect(self.visibleRect, view.frame))
		{
			HorizontalTableViewCell *cell = (HorizontalTableViewCell *)view;
			//NSLog(@"enqueue: %d", cell.index);
			
			cell.index = -1;
			
			[view removeFromSuperview];
			[self.reusableCellQueue addObject:view];
		}
	}
}

@end
