//
//  LocationManager.h
//  Group5iBeacons
//
//  Created by Nemanja Joksovic on 6/15/14.
//  Copyright (c) 2014 John Tubert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LocationManager : NSObject

+ (void)determine:(NSArray *)transmissions
          success:(void (^)(CGPoint location))success
          failure:(void (^)(NSError *error))failure;

@end
