//
//  ViewController.h
//  HorizontalTableView
//
//  Created by Aryan Gh on 1/29/14.
//  Copyright (c) 2014 Aryan Ghassemi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HorizontalTableView.h"

@interface ViewController : UIViewController <HorizontalTableViewDelegate, HorizontalTableViewDataSource>

@property (nonatomic, strong) IBOutlet HorizontalTableView *horizontalTableView;

@end
