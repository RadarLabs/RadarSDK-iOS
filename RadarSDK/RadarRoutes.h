//
//  RadarRoutes.h
//  RadarSDKTests
//
//  Copyright © 2020 Radar Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RadarRoute.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Represents routes from an origin to a destination. For more information, see https://radar.io/documentation/api#route.
 
 @see https://radar.io/documentation/api#route
*/
@interface RadarRoutes : NSObject

/**
 The geodesic distance between the origin and destination.
 */
@property (nullable, strong, nonatomic, readonly) RadarRouteDistance *geodesic;

/**
 The route by foot between the origin and destination. May be `nil` if mode `foot` not specified.
 */
@property (nullable, strong, nonatomic, readonly) RadarRoute *foot;

/**
 The route by bike between the origin and destination. May be `nil` if mode `bike` not specified.
 */
@property (nullable, strong, nonatomic, readonly) RadarRoute *bike;

/**
 The route by car between the origin and destination. May be `nil` if mode `car` not specified.
 */
@property (nullable, strong, nonatomic, readonly) RadarRoute *car;

/**
 The route by transit between the origin and destination. May be `nil` if mode `transit` not specified.
 */
@property (nullable, strong, nonatomic, readonly) RadarRoute *transit;

@end

NS_ASSUME_NONNULL_END