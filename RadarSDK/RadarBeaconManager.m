//
//  RadarBeaconManager.m
//  RadarSDK
//
//  Copyright © 2020 Radar Labs, Inc. All rights reserved.
//

#import "RadarBeaconManager.h"

#import "RadarBeacon+Internal.h"
#import "RadarLogger.h"

@interface RadarBeaconManager ()

@property (assign, nonatomic) BOOL started;
@property (nonnull, strong, nonatomic) NSMutableArray<RadarBeaconCompletionHandler> *completionHandlers;
@property (nonnull, strong, nonatomic) NSMutableSet<NSString *> *nearbyBeaconIdentifers;
@property (nonnull, strong, nonatomic) NSMutableSet<NSString *> *failedBeaconIdentifiers;
@property (nonnull, strong, nonatomic) NSArray<RadarBeacon *> *beacons;

@end

@implementation RadarBeaconManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    if ([NSThread isMainThread]) {
        dispatch_once(&once, ^{
            sharedInstance = [self new];
        });
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            dispatch_once(&once, ^{
                sharedInstance = [self new];
            });
        });
    }
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
        
        _completionHandlers = [NSMutableArray<RadarBeaconCompletionHandler> new];
        
        _beacons = @[];
        _nearbyBeaconIdentifers = [NSMutableSet new];
        _failedBeaconIdentifiers = [NSMutableSet new];
        
        _permissionsHelper = [RadarPermissionsHelper new];
    }
    return self;
}

- (void)callCompletionHandlersWithStatus:(RadarStatus)status beacons:(NSArray<NSString *> *_Nullable)nearbyBeacons {
    @synchronized(self) {
        if (!self.completionHandlers.count) {
            return;
        }

        [[RadarLogger sharedInstance]
            logWithLevel:RadarLogLevelInfo
                 message:[NSString stringWithFormat:@"Calling completion handlers | self.completionHandlers.count = %lu", (unsigned long)self.completionHandlers.count]];

        for (RadarBeaconCompletionHandler completionHandler in self.completionHandlers) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeoutWithCompletionHandler:) object:completionHandler];

            completionHandler(status, nearbyBeacons);
        }

        [self.completionHandlers removeAllObjects];
    }
}


- (void)addCompletionHandler:(RadarBeaconCompletionHandler)completionHandler {
    if (!completionHandler) {
        return;
    }

    @synchronized(self) {
        [self.completionHandlers addObject:completionHandler];

        [self performSelector:@selector(timeoutWithCompletionHandler:) withObject:completionHandler afterDelay:5];
    }
}

- (void)cancelTimeouts {
    @synchronized(self) {
        for (RadarLocationCompletionHandler completionHandler in self.completionHandlers) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeoutWithCompletionHandler:) object:completionHandler];
        }
    }
}

- (void)timeoutWithCompletionHandler:(RadarBeaconCompletionHandler)completionHandler {
    @synchronized(self) {
        [self stopRanging];
    }
}

- (void)rangeBeacons:(NSArray<RadarBeacon *> *_Nonnull)beacons completionHandler:(RadarBeaconCompletionHandler)completionHandler {
    CLAuthorizationStatus authorizationStatus = [self.permissionsHelper locationAuthorizationStatus];
    if (!(authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse || authorizationStatus == kCLAuthorizationStatusAuthorizedAlways)) {
        if (self.delegate) {
            [self.delegate didFailWithStatus:RadarStatusErrorPermissions];
        }

        if (completionHandler) {
            completionHandler(RadarStatusErrorPermissions, nil);

            return;
        }
    }
    
    if (!CLLocationManager.isRangingAvailable) {
        completionHandler(RadarStatusErrorBluetooth, nil);
        
        return;
    }
    
    [self addCompletionHandler:completionHandler];
    
    if (self.started) {
        [[RadarLogger sharedInstance] logWithLevel:RadarLogLevelInfo message:@"Already ranging beacons"];
        
        return;
    }
    
    if (!beacons || !beacons.count) {
        [[RadarLogger sharedInstance] logWithLevel:RadarLogLevelInfo message:@"No beacons to range"];
        
        return;
    }
    
    self.beacons = beacons;
    self.started = YES;
    
    for (RadarBeacon *beacon in beacons) {
        [[RadarLogger sharedInstance]
            logWithLevel:RadarLogLevelInfo
                message:[NSString stringWithFormat:@"Starting ranging beacon | _id = %@; uuid = %@; major = %@; minor = %@", beacon._id, beacon.uuid, beacon.major, beacon.minor]];
        
        [self.locationManager startRangingBeaconsInRegion:[beacon region]];
    }
}

- (void)stopRanging {
    [[RadarLogger sharedInstance] logWithLevel:RadarLogLevelInfo message:[NSString stringWithFormat:@"Stopping ranging"]];
    
    [self cancelTimeouts];
    
    for (RadarBeacon *beacon in self.beacons) {
        [self.locationManager stopRangingBeaconsInRegion:[beacon region]];
    }
    
    [self callCompletionHandlersWithStatus:RadarStatusSuccess beacons:[self.nearbyBeaconIdentifers allObjects]];
    
    self.beacons = @[];
    self.started = NO;
    
    [self.nearbyBeaconIdentifers removeAllObjects];
    [self.failedBeaconIdentifiers removeAllObjects];
}

- (void)handleBeacons {
    if (self.nearbyBeaconIdentifers.count + self.failedBeaconIdentifiers.count == self.beacons.count) {
        [[RadarLogger sharedInstance] logWithLevel:RadarLogLevelInfo message:[NSString stringWithFormat:@"Finished ranging"]];
        
        [self stopRanging];
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    [[RadarLogger sharedInstance]
        logWithLevel:RadarLogLevelInfo
            message:[NSString stringWithFormat:@"Failed to monitor beacon | region.identifier = %@", region.identifier]];
    
    [self.failedBeaconIdentifiers addObject:region.identifier];
    
    [self handleBeacons];
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    [[RadarLogger sharedInstance]
        logWithLevel:RadarLogLevelInfo
            message:[NSString stringWithFormat:@"Failed to range beacon | region.identifier = %@", region.identifier]];
    
    [self.failedBeaconIdentifiers addObject:region.identifier];
    
    [self handleBeacons];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(nonnull NSArray<CLBeacon *> *)beacons inRegion:(nonnull CLBeaconRegion *)region {
    [[RadarLogger sharedInstance]
        logWithLevel:RadarLogLevelInfo
            message:[NSString stringWithFormat:@"Ranged beacon | region.identifier = %@", region.identifier]];
    
    [self.nearbyBeaconIdentifers addObject:region.identifier];
    
    [self handleBeacons];
}

@end