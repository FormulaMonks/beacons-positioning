//
//  CBLogsViewController.m
//  BeaconsHeatmap
//
//  Created by Luis Floreani on 2/19/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

#import "CBLogsViewController.h"

@interface CBLogsViewController()
@property NSArray *logFiles;
@end

@implementation CBLogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSString *file = _logFiles[indexPath.row];
    
    cell.textLabel.text = file;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"unwind" sender:nil];
}


@end
