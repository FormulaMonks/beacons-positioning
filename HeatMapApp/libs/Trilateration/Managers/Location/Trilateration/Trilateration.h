//
//  Trilateration.h
//  G5-iBeacon-Demo
//
//  Created by Nemanja Joksovic on 3/3/14.
//  Copyright (c) 2014 R/GA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface Trilateration : NSObject

+ (void)trilaterate:(NSArray *)transmissions
            success:(void (^)(CGPoint location))success
            failure:(void (^)(NSError *error))failure;

@end
