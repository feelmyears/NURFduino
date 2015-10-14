//
//  NURFduinoDeviceManager+DeviceEventHandler.m
//  NURF
//
//  Created by Phil Meyers IV on 10/13/15.
//  Copyright © 2015 Northwestern University. All rights reserved.
//

#import "NURFduinoDeviceManager+DeviceEventHandler.h"
#import "NURFduinoDeviceManagerDelegate.h"

@implementation NURFduinoDeviceManager (DeviceEventHandler)
- (void)deviceDidLoadService:(NURFduinoDevice *)device {
	if ([self.delegate respondsToSelector:@selector(deviceManager:didLoadServiceForDevice:)]) {
		[self.delegate deviceManager:self didLoadServiceForDevice:device];
	}
}

@end
