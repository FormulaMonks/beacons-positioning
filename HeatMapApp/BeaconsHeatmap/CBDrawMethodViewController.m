//
//  CBDrawMethodViewController.m
//  BeaconsHeatmap
//
//  Created by Luis Floreani on 3/29/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

#import "CBDrawMethodViewController.h"

@interface CBDrawMethodViewController ()
@property NSIndexPath *selectedIndex;
@end

@implementation CBDrawMethodViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger index = [[defaults objectForKey:@"drawMethod"] integerValue];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    _selectedIndex = indexPath;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_selectedIndex];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_selectedIndex) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_selectedIndex];
        
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    _selectedIndex = indexPath;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_selectedIndex];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInteger:indexPath.row] forKey:@"drawMethod"];
    [defaults synchronize];
}


@end
