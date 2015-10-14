//
//  NURFduinoDevice.h
//  NURF
//
//  Created by Phil Meyers IV on 10/13/15.
//  Copyright © 2015 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSData+NURFDataTransforming.h"

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import <CoreBluetooth/CoreBluetooth.h>
#elif TARGET_OS_MAC
#import <IOBluetooth/IOBluetooth.h>
#endif

@class NURFduinoDeviceManager;
@protocol NURFduinoDeviceDelegate;

extern NSString *const customUUID;

@interface NURFduinoDevice : NSObject <CBPeripheralDelegate>
@property (nonatomic, weak) id<NURFduinoDeviceDelegate> delegate;
@property (nonatomic, strong) NURFduinoDeviceManager *manager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSData *advertisementData;
@property (nonatomic, copy) NSDate *lastAdvertisementTime;
@property (nonatomic, copy) NSNumber *advertisementRSSI;
@property (nonatomic, assign) NSInteger advertisementPackets;
@property (nonatomic, assign, getter=isOutOfRange) BOOL outOfRange;

- (void)deviceConnected;
- (void)disconnect;
- (void)sendData:(NSData *)data;
@end
