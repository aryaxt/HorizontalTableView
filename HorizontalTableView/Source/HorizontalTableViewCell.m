//
//  HorizontalTableViewCell.m
//  HorizontalTableView
//
//  Created by Aryan Gh on 1/29/14.
//  Copyright (c) 2014 Aryan Ghassemi. All rights reserved.
//

#import "HorizontalTableViewCell.h"

@interface HorizontalTableViewCell()
@property (nonatomic, strong) UIView *highLightAndSelectedView;
@end

#define ANIMATION_DURATION .2

@implementation HorizontalTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[self showHighlightView:selected animated:animated];
}

- (void)setHighLighted:(BOOL)highLighted animated:(BOOL)animated
{
	[self showHighlightView:highLighted animated:animated];
}

#pragma mark - Private Methods -

- (void)showHighlightView:(BOOL)show animated:(BOOL)animated
{
	if (show)
	{
		self.highLightAndSelectedView.frame = self.bounds;
		[self insertSubview:self.highLightAndSelectedView atIndex:0];
		
		[UIView animateWithDuration:(animated) ? ANIMATION_DURATION : 0 animations:^{
			self.highLightAndSelectedView.alpha = 1;
		}];
	}
	else
	{
		[UIView animateWithDuration:(animated) ? ANIMATION_DURATION : 0 animations:^{
			self.highLightAndSelectedView.alpha = 0;
		} completion:^(BOOL finished){
			[self.highLightAndSelectedView removeFromSuperview];
		}];
	}
}

#pragma mark - Setter & Getter -

- (UIView *)highLightAndSelectedView
{
	if (!_highLightAndSelectedView)
	{
		_highLightAndSelectedView = [[UIView alloc] init];
		_highLightAndSelectedView.backgroundColor = [UIColor lightGrayColor];
		_highLightAndSelectedView.alpha = 0;
	}
	
	return _highLightAndSelectedView;
}

@end
