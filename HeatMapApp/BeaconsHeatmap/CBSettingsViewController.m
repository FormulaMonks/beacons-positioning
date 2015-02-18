//
//  CBSettingsViewController.m
//  BeaconsHeatmap
//
//  Created by Luis Floreani on 1/30/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

#import "CBSettingsViewController.h"

@interface CBSettingsViewController () <UITextFieldDelegate>
@property IBOutlet UITextField *widthField;
@property IBOutlet UITextField *heightField;
@property IBOutlet UILabel *estimationMethodLabel;
@property IBOutlet UISwitch *heatmapSwitch;
@end

@implementation CBSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _widthField.delegate = self;
    _heightField.delegate = self;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _widthField.text = [NSString stringWithFormat:@"%.2f", [[defaults objectForKey:@"room_width"] floatValue]];
    _heightField.text = [NSString stringWithFormat:@"%.2f", [[defaults objectForKey:@"room_height"] floatValue]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSArray *methods = @[@"heuristic", @"levenberg"];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *index = [defaults objectForKey:@"estimation"];
    _estimationMethodLabel.text = methods[[index integerValue]];
    _heatmapSwitch.on = [[defaults objectForKey:@"heatmap"] boolValue];
}

- (void)save {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (_widthField.text.length > 0) {
        [defaults setObject:_widthField.text forKey:@"room_width"];
    }
    if (_heightField.text.length > 0) {
        [defaults setObject:_heightField.text forKey:@"room_height"];
    }
    
    [defaults setObject:[NSNumber numberWithBool:_heatmapSwitch.on] forKey:@"heatmap"];
    
    [defaults synchronize];
}

@end
