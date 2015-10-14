//
//  NURFduinoDeviceManager+DeviceEventHandler.h
//  NURF
//
//  Created by Phil Meyers IV on 10/13/15.
//  Copyright © 2015 Northwestern University. All rights reserved.
//

#import "NURFduinoDeviceManager.h"

@interface NURFduinoDeviceManager (DeviceEventHandler)
- (void)deviceDidLoadService:(NURFduinoDevice *)device;
@end
