//
//  HorizontalTableView.m
//  HorizontalTableView
//
//  Created by Aryan Gh on 1/29/14.
//  Copyright (c) 2014 Aryan Ghassemi. All rights reserved.
//

#import "HorizontalTableView.h"

@interface HorizontalTableView()
@property (nonatomic, strong) NSMutableDictionary *reusableViewQueue;
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
	self.reusableViewQueue = [NSMutableDictionary dictionary];
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
	
}

- (UIView *)dequeueReusableViewWithIdentifier:(NSString *)identifier
{
	return nil;
}

#pragma mark - Private Methods -

@end
