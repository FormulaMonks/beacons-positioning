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
@property IBOutlet UILabel *beaconsLabel;
@property IBOutlet UIStepper *beaconsStepper;
@end

@implementation CBSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _widthField.delegate = self;
    _heightField.delegate = self;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _widthField.text = [NSString stringWithFormat:@"%.2f", [[defaults objectForKey:@"room_width"] floatValue]];
    _heightField.text = [NSString stringWithFormat:@"%.2f", [[defaults objectForKey:@"room_height"] floatValue]];
    _beaconsLabel.text = [NSString stringWithFormat:@"%d", [[defaults objectForKey:@"beacons"] intValue]];
    _beaconsStepper.minimumValue = 1;
    _beaconsStepper.value = [_beaconsLabel.text doubleValue];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSArray *methods = @[@"heuristic", @"levenberg"];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *index = [defaults objectForKey:@"estimation"];
    _estimationMethodLabel.text = methods[[index integerValue]];
    _heatmapSwitch.on = [[defaults objectForKey:@"heatmap"] boolValue];
}

- (IBAction)stepperChanged:(UIStepper *)sender {
    _beaconsLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
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
    [defaults setObject:[NSNumber numberWithInt:[_beaconsLabel.text intValue]] forKey:@"beacons"];
    
    [defaults synchronize];
}

@end
