//
//  CBLogsViewController.h
//  BeaconsHeatmap
//
//  Created by Luis Floreani on 2/19/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CBLogsViewController;

@protocol CBLogsViewControllerDelegate
- (void)logsViewController:(CBLogsViewController *)viewController didSelectLog:(NSMutableArray *)logItems;
@end

@interface CBLogsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, weak) id<CBLogsViewControllerDelegate> delegate;

@end
