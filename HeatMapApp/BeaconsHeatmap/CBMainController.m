//
//  ViewController.m
//  BeaconsHeatmap
//
//  Created by Luis Floreani on 22/1/15.
//  Copyright (c) 2015 Citrusbyte LLC. All rights reserved.
//

#import "CBMainController.h"
#import "LFHeatMap.h"
#import "CBBeaconsMap.h"
#import "CBBeaconsSimulator.h"
#import "CBSettingsViewController.h"
#import "CBBeaconsRanger.h"
#import "CBLogsViewController.h"
#import "CBBeaconsHelper.h"
#import "CBBeacon.h"

@interface CBMainController () <CBBeaconsMapDelegate, CBBeaconsSimulatorDelegate, CBBeaconsRangerDelegate, CBSettingsViewControllerDelegate, CBLogsViewControllerDelegate, CBBeaconsHelperDelegate>

@property IBOutlet UIImageView *imageView;
@property IBOutlet CBBeaconsMap *beaconsView;
@property IBOutlet UIBarButtonItem *logButton;

@property CBBeaconsRanger *ranger;

@property CBBeaconsHelper *helper;

@property CBDrawMethod drawMethod;

@property dispatch_queue_t queue;

@property NSArray *lastMeasuredPoints;

@end

@implementation CBMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _queue = dispatch_queue_create("com.citrusbyte.heatmap", NULL);
    
    _helper = [CBBeaconsHelper new];
    _helper.delegate = self;
    
    _ranger = [CBBeaconsRanger new];
    _ranger.delegate = self;
    
    _beaconsView.physicalSize = [_helper roomSize];
    _beaconsView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    CBEstimationMethod method = [[defaults objectForKey:@"estimation"] integerValue];
    
    _beaconsView.method = method;
    _ranger.uuid = [defaults objectForKey:@"uuid"];
    _drawMethod = [[defaults objectForKey:@"drawMethod"] integerValue];
    _beaconsView.drawMethod = _drawMethod;
    _imageView.alpha = _drawMethod == CBDrawMethodHeatmap ? 1.0 : 0.0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _beaconsView.beacons = [_helper loadBeacons];
    
    NSMutableArray *minors = [NSMutableArray array];
    for (CBBeacon *beacon in _beaconsView.beacons) {
        [minors addObject:beacon.minor];
    }
    _ranger.minorsFilter = minors;
    
    [_beaconsView updateBeacons];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [_beaconsView updateBeacons];
    [self refreshHeatmap:CGRectMake(0, 0, size.width, size.height)];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"logSegue"]) {
        if ([_logButton.title isEqualToString:@"Stop Log"]) {
            [_helper stopPlayingLog];
            _logButton.title = @"Logs";
            _logButton.tintColor = nil;
            return NO;
        }
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *vc = (UINavigationController *)segue.destinationViewController;
        if ([vc.viewControllers[0] isKindOfClass:[CBSettingsViewController class]]) {
            CBSettingsViewController *settings = (CBSettingsViewController *)(vc.viewControllers[0]);
            settings.delegate = self;
        } else if ([vc.viewControllers[0] isKindOfClass:[CBLogsViewController class]]) {
            CBLogsViewController *logs = (CBLogsViewController *)(vc.viewControllers[0]);
            logs.delegate = self;
        }
        
    }
}

- (IBAction)changeRanging:(UIBarButtonItem *)sender {
    if ([sender.title hasPrefix:@"Start"]) {
        BOOL ret = [_ranger startRanging];
        if (ret) {
            [_helper initLogTimers];
            sender.title = @"Stop Ranging";
            sender.tintColor = [UIColor greenColor];
            [_beaconsView resetPreviousData];            
        }
    } else {
        [_helper saveLog];
        sender.title = @"Start Ranging";
        sender.tintColor = nil;
        [_ranger stopRanging];
    }
}

- (IBAction)dismissViewController:(UIStoryboardSegue *)segue {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // update room size
    _beaconsView.physicalSize = [_helper roomSize];
    [_beaconsView updateBeacons];
}

// Delegates

- (void)helperDidFinishLog:(CBBeaconsHelper *)helper {
    _logButton.title = @"Logs";
    _logButton.tintColor = nil;
}

- (void)helper:(CBBeaconsHelper *)helper didReadBeaconsFromLog:(NSArray *)signals {
    [self beaconsRanger:nil didRangeBeacons:signals];
}

- (void)logsViewController:(CBLogsViewController *)viewController didSelectLog:(NSMutableArray *)logItems {
    _logButton.title = @"Stop Log";
    _logButton.tintColor = [UIColor greenColor];
    
    [_beaconsView resetPreviousData];

    [_helper playLog:logItems];
}

- (void)settingsViewControllerDeleteBeacons:(CBSettingsViewController *)viewController {
    [_helper deleteBeacons];
}

- (void)beaconsRanger:(CBBeaconsRanger *)ranger didRangeBeacons:(NSArray *)signals {
    [_helper appendToLog:signals];
    
    for (CBBeacon *beaconView in _beaconsView.beacons) {
        for (CBSignal *signal in signals) {
            if (beaconView.name == nil || [beaconView.name isEqualToString:[signal.minor stringValue]]) { // in case it's empty assign the first empty
                beaconView.name = [signal.minor stringValue];
                beaconView.distance = [signal.distance floatValue];
                beaconView.rssi = [[signal rssi] integerValue];
                beaconView.proximity = signal.proximity;
            }
        }
    }
    
    [_beaconsView updateBeacons];
}

- (void)refreshHeatmap:(CGRect)rect {
    if (_drawMethod == CBDrawMethodHeatmap) {
        dispatch_async(_queue, ^{
            NSMutableArray *weights = [NSMutableArray arrayWithCapacity:_lastMeasuredPoints.count];
            for (int i = 0; i < _lastMeasuredPoints.count; i++) {
                [weights addObject:[NSNumber numberWithFloat:10.0 + i]]; // we give more weight to newest ones
            }
            
            UIImage *map = [LFHeatMap heatMapWithRect:rect boost:0.6 points:[_lastMeasuredPoints copy] weights:weights];
            dispatch_async(dispatch_get_main_queue(), ^{
                _imageView.image = map;
            });
        });
    }
}

- (void)beaconMap:(CBBeaconsMap *)beaconMap lastMeasuredPoints:(NSArray *)points {
    _lastMeasuredPoints = points;
    
    [self refreshHeatmap:_imageView.bounds];
}

- (void)beaconMap:(CBBeaconsMap *)beaconMap beaconsPropertiesChanged:(NSArray *)beacons {
    [_helper saveBeacons:beacons];
}

-(void)beaconSimulatorDidChange:(CBBeaconsSimulator *)simulator {
    [_beaconsView updateBeacons];
}

@end
