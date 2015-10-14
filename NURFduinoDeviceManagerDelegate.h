//
//  NURFduinoDeviceManagerDelegate.h
//  NURF
//
//  Created by Phil Meyers IV on 10/13/15.
//  Copyright © 2015 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NURFduinoDeviceManager;
@class NURFduinoDevice;

@protocol NURFduinoDeviceManagerDelegate <NSObject>
@required
- (void)deviceManager:(NURFduinoDeviceManager *)manager didDiscoverDevice:(NURFduinoDevice *)device;
@optional
- (void)deviceManager:(NURFduinoDeviceManager *)manager didUpdateDiscoveredDevices:(NSArray<NURFduinoDevice *> *)devices;
- (void)deviceManager:(NURFduinoDeviceManager *)manager didConnectToDevice:(NURFduinoDevice *)device;
- (void)deviceManager:(NURFduinoDeviceManager *)manager didDisconnectFromDevice:(NURFduinoDevice *)device;
- (void)deviceManager:(NURFduinoDeviceManager *)manager didLoadServiceForDevice:(NURFduinoDevice *)device;
@end
