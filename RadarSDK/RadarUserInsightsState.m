//
//  RadarUserInsightsState.m
//  RadarSDK
//
//  Copyright © 2019 Radar Labs, Inc. All rights reserved.
//

#import "RadarUserInsightsState.h"
#import "RadarUserInsightsState+Internal.h"

@implementation RadarUserInsightsState

- (instancetype _Nullable)initWithHome:(BOOL)home office:(BOOL)office traveling:(BOOL)traveling commuting:(BOOL)commuting {
    self = [super init];
    if (self) {
        _home = home;
        _office = office;
        _traveling = traveling;
        _commuting = commuting;
    }
    return self;
}

- (instancetype _Nullable)initWithObject:(id)object {
    if (!object || ![object isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSDictionary *userInsightsStateDict = (NSDictionary *)object;
    
    id userInsightsStateHomeObj = userInsightsStateDict[@"home"];
    id userInsightsStateOfficeObj = userInsightsStateDict[@"office"];
    id userInsightsStateTravelingObj = userInsightsStateDict[@"traveling"];
    id userInsightsStateCommutingObj = userInsightsStateDict[@"commuting"];
    if (!userInsightsStateHomeObj || ![userInsightsStateHomeObj isKindOfClass:[NSNumber class]] || !userInsightsStateOfficeObj || ![userInsightsStateOfficeObj isKindOfClass:[NSNumber class]] || !userInsightsStateTravelingObj || ![userInsightsStateTravelingObj isKindOfClass:[NSNumber class]]|| !userInsightsStateCommutingObj || ![userInsightsStateCommutingObj isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    
    BOOL userInsightsStateHome = [(NSNumber *)userInsightsStateHomeObj boolValue];
    BOOL userInsightsStateOffice = [(NSNumber *)userInsightsStateOfficeObj boolValue];
    BOOL userInsightsStateTraveling = [(NSNumber *)userInsightsStateTravelingObj boolValue];
    BOOL userInsightsStateCommuting = [(NSNumber *)userInsightsStateCommutingObj boolValue];
    
    return [[RadarUserInsightsState alloc] initWithHome:userInsightsStateHome office:userInsightsStateOffice traveling:userInsightsStateTraveling commuting:userInsightsStateCommuting];
}

@end
