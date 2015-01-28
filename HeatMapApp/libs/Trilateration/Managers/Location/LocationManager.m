//
//  LocationManager.m
//  Group5iBeacons
//
//  Created by Nemanja Joksovic on 6/15/14.
//  Copyright (c) 2014 John Tubert. All rights reserved.
//

#import "LocationManager.h"

#import "NonLinear.h"
#import "Trilateration.h"

@implementation LocationManager

+ (void)determine:(NSArray *)transmissions
          success:(void (^)(CGPoint location))success
          failure:(void (^)(NSError *error))failure
{
    @synchronized(self) {
        BOOL nonLinearRegression = YES;
    
        if (nonLinearRegression) {
            CGPoint location = [NonLinear determine:transmissions];
        
            if (location.x && location.y) {
                success(location);
            }
            else {
                failure([NSError errorWithDomain:@"Location not found"
                                            code:0
                                        userInfo:nil]);
                }
        }
        else {
            [Trilateration trilaterate:transmissions
                               success:success
                               failure:failure];
        }
    }
}

@end
