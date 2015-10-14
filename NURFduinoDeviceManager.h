//
//  NURFduinoDeviceManager.h
//  NURF
//
//  Created by Phil Meyers IV on 10/13/15.
//  Copyright © 2015 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import <CoreBluetooth/CoreBluetooth.h>
#elif TARGET_OS_MAC
#import <IOBluetooth/IOBluetooth.h>
#endif

@protocol NURFduinoDeviceManagerDelegate;
@class NURFduinoDevice;

@interface NURFduinoDeviceManager : NSObject
@property (nonatomic, weak) id<NURFduinoDeviceManagerDelegate> delegate;
@property (nonatomic, readonly) NSMutableSet *devices;
@property (nonatomic, readonly) BOOL scanning;

- (void)startScan;
- (void)stopScan;
- (void)connectDevice:(NURFduinoDevice *)device;
- (void)disconnectDevice:(NURFduinoDevice *)device;

@end
