//
//  HorizontalTableView.m
//  HorizontalTableView
//
//  Created by Aryan Gh on 1/29/14.
//  Copyright (c) 2014 Aryan Ghassemi. All rights reserved.
//

#import "HorizontalTableView.h"

@interface HorizontalTableView()
@property (nonatomic, strong) NSMutableSet *reusableCellQueue;
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
	self.reusableCellQueue = [NSMutableSet set];
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
	for (HorizontalTableViewCell *cell in self.reusableCellQueue)
	{
		if ([cell.identifier isEqual:identifier])
			NSLog(@"dequeue");
			return cell;
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

- (HorizontalTableViewCell *)viewAtIndex:(NSInteger)index
{
	return [self.dataSource horizontalTableView:self cellForColumnAtIndex:index];
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
			HorizontalTableViewCell *cell = [self viewAtIndex:i];
			cell.frame = rectForView;
			[self addSubview:cell];
		}
		
		x += widthForIndex;
	}
}

- (void)addCellsToViewIfNeeded
{
	CGRect visibleRect = [self visibleRect];
}

- (void)enqueueHiddenCells
{
	for (UIView *view in self.subviews)
	{
		if ([view isKindOfClass:[HorizontalTableViewCell class]] && !CGRectIntersectsRect(self.visibleRect, view.frame))
		{
			NSLog(@"enqueue");
			[view removeFromSuperview];
			[self.reusableCellQueue addObject:view];
		}
	}
}

@end
