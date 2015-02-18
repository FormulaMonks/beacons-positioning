//
//  CBSettingsViewController.h
//  BeaconsHeatmap
//
//  Created by Luis Floreani on 1/30/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBSettingsViewController;

@protocol CBSettingsViewControllerDelegate
- (void)settingsViewControllerDeleteBeacons:(CBSettingsViewController *)viewController;
@end

@interface CBSettingsViewController : UITableViewController

@property (nonatomic, weak) id<CBSettingsViewControllerDelegate> delegate;

- (void)save;

@end
