//
//  CBLogsViewController.m
//  BeaconsHeatmap
//
//  Created by Luis Floreani on 2/19/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

#import "CBLogsViewController.h"
#import "BeaconsHeatmap-Swift.h"

@interface CBLogsViewController()
@property NSArray *logFiles;
@end

@implementation CBLogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadLogs];
}

- (void)loadLogs {
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [documentPath objectAtIndex:0];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:docDirectory error:nil];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"self BEGINSWITH 'log-'"];
    _logFiles = [[dirContents filteredArrayUsingPredicate:filter] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *s1 = (NSString *)obj1;
        NSString *s2 = (NSString *)obj2;
        return [s2 compare:s1];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_logFiles count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDirectory = [documentPath objectAtIndex:0];
        NSFileManager *fm = [NSFileManager defaultManager];

        [fm removeItemAtPath:[docDirectory stringByAppendingPathComponent:_logFiles[indexPath.row]] error:nil];
        
        [self loadLogs];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSString *file = _logFiles[indexPath.row];
    
    cell.textLabel.text = file;
    
    return cell;
}

- (NSMutableArray *)readLogs:(NSIndexPath *)indexPath {
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [documentPath objectAtIndex:0];
    
    NSMutableArray *logs = [NSMutableArray arrayWithContentsOfFile:[docDirectory stringByAppendingPathComponent:_logFiles[indexPath.row]]];
    
    return logs;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[CBLogChartViewController class]]) {
        CBLogChartViewController *vc = segue.destinationViewController;
        vc.logs = [self readLogs:[self.tableView indexPathForCell:sender]];        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *logs = [self readLogs:indexPath];
        
    [_delegate logsViewController:self didSelectLog:logs];
    
    [self performSegueWithIdentifier:@"unwind" sender:nil];
}


@end
