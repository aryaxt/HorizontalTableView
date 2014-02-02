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
@property (nonatomic, strong) NSMutableArray *xLocationOfCells;
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
	self.xLocationOfCells = [NSMutableArray array];
	self.reusableCellQueue = [NSMutableArray array];
}

#pragma mark - Overrides -

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[self enqueueInvisibleCells];
	[self reloadCellsInVisibleContent];
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
	[self.xLocationOfCells removeAllObjects];
	CGFloat x = 0;
	
	for (int i=0 ; i<self.numberOfColumns ; i++)
	{
		CGFloat width = [self.dataSource horizontalTableView:self widthForColumAtIndex:i];
		[self.xLocationOfCells insertObject:[NSValue valueWithCGRect:CGRectMake(x, 0, width, self.frame.size.height)] atIndex:i];
		
		x+= width;
	}
	
	self.contentSize = CGSizeMake(x, self.frame.size.height);
	
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

- (NSInteger)numberOfColumns
{
	return [self.dataSource numberOfColumnsInHorizontalTableView:self];
}

- (HorizontalTableViewCell *)cellAtIndex:(NSInteger)index
{
	for (UIView *view in self.subviews)
	{
		if ([view isKindOfClass:[HorizontalTableViewCell class]])
		{
			HorizontalTableViewCell *cell = (HorizontalTableViewCell *) view;
			
			if (cell.index == index)
				return cell;
		}
	}
	
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

/*- (CGRect)rectForColumnAtIndex:(NSInteger)index
{
	CGFloat x = 0;
	
	for (int i=0 ; i<self.numberOfColumns ; i++)
	{
		x += [self widthAtIndex:i];
	}
	
	return CGRectMake(x, 0, [self widthAtIndex:index], self.frame.size.height);
}*/

- (void)reloadCellsInVisibleContent
{
	CGRect visibleRect = [self visibleRect];
	
	for (int i=0 ; i<self.numberOfColumns ; i++)
	{
		CGRect rectForView = [[self.xLocationOfCells objectAtIndex:i] CGRectValue];
		rectForView.size.height = self.frame.size.height;
		
		if (CGRectIntersectsRect(visibleRect, rectForView))
		{
			HorizontalTableViewCell *cell = [self cellAtIndex:i];
			
			// If cell is already added don't re-add, it causes lag
			if (!cell.superview)
			{
				cell.index = i;
				cell.frame = rectForView;
				[self insertSubview:cell atIndex:0];
			}
		}
		
		// Improve performance get out of this loop
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

- (void)enqueueInvisibleCells
{
	for (UIView *view in self.subviews)
	{
		if ([view isKindOfClass:[HorizontalTableViewCell class]] && !CGRectIntersectsRect(self.visibleRect, view.frame))
		{
			HorizontalTableViewCell *cell = (HorizontalTableViewCell *)view;
			//NSLog(@"enqueue: %d", cell.index);
			
			[cell removeFromSuperview];
			[self.reusableCellQueue addObject:cell];
		}
	}
}

@end
