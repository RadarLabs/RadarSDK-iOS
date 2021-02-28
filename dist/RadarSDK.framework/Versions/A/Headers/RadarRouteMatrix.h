//
//  RadarRouteMatrix.h
//  RadarSDK
//
//  Copyright © 2021 Radar Labs, Inc. All rights reserved.
//

#import "RadarRoute.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Represents routes between multiple origins and destinations. For more information, see https://radar.io/documentation/api#matrix.

 @see https://radar.io/documentation/api#routing
*/
@interface RadarRouteMatrix : NSObject

/**
 Returns the route between the specified origin and destination.
 
 @param originIndex The index of the origin.
 @param destinationIndex The index of the destination.

 @return The route between the specified origin and destination.
 */
- (RadarRoute *_Nullable)routeBetweenOriginIndex:(NSUInteger)originIndex destinationIndex:(NSUInteger)destinationIndex;

- (NSArray<NSArray<NSDictionary *> *> *_Nonnull)arrayValue;

@end

NS_ASSUME_NONNULL_END
