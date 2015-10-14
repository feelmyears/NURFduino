//
//  NURFduinoDeviceDelegate.h
//  NURF
//
//  Created by Phil Meyers IV on 10/13/15.
//  Copyright © 2015 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NURFduinoDevice;
@protocol NURFduinoDeviceDelegate <NSObject>
@optional
- (void)device:(NURFduinoDevice *)device didRecieveData:(NSData *)data;
@end
