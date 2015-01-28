//
//  Global.h
//  iBeacon-Geo-Demo
//
//  Created by Nemanja Joksovic on 4/5/14.
//  Copyright (c) 2014 R/GA. All rights reserved.
//

#define kBeaconProximityUUID @"2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"
//#define kBeaconProximityUUID @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
#define kBeaconRegionIdentifier @"com.rga.iBeacon-Geo-Demo"
#define kWebServiceHostname @"http://fast-taiga-2263.herokuapp.com"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define kDefaultFont [UIFont fontWithName:@"HelveticaNeue-Light" size:IS_IPHONE ? 11 : 14]

