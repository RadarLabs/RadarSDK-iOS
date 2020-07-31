//
//  RadarContext+Internal.h
//  RadarSDK
//
//  Copyright © 2020 Radar Labs, Inc. All rights reserved.
//

#import "RadarContext.h"
#import "RadarGeofence.h"
#import "RadarJSONCoding.h"
#import "RadarUserInsights.h"
#import <Foundation/Foundation.h>

@interface RadarContext ()<RadarJSONCoding>

- (instancetype _Nullable)initWithGeofences:(NSArray* _Nonnull)geofences
                                      place:(RadarPlace* _Nullable)place
                                    country:(RadarRegion* _Nullable)country
                                      state:(RadarRegion* _Nullable)state
                                        dma:(RadarRegion* _Nullable)dma
                                 postalCode:(RadarRegion* _Nullable)postalCode;

@end
