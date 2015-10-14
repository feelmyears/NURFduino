//
//  NURFduinoDevice.m
//  NURF
//
//  Created by Phil Meyers IV on 10/13/15.
//  Copyright © 2015 Northwestern University. All rights reserved.
//

#import "NURFduinoDevice.h"
#import "NURFduinoDeviceDelegate.h"
#import "NURFduinoDeviceManager.h"
#import "NURFduinoDeviceManager+DeviceEventHandler.h"

static const int kMaxDataSize = 12;
NSString *const customUUID = NULL;

static CBUUID *service_uuid;
static CBUUID *send_uuid;
static CBUUID *receive_uuid;
static CBUUID *disconnect_uuid;

// increment the 16-bit uuid inside a 128-bit uuid
static void incrementUuid16(CBUUID *uuid, unsigned char amount)
{
	NSData *data = uuid.data;
	unsigned char *bytes = (unsigned char *)[data bytes];
	unsigned char result = bytes[3] + amount;
	if (result < bytes[3])
		bytes[2]++;
	bytes[3] += amount;
}

@interface NURFduinoDevice()
@property (nonatomic, strong) CBCharacteristic *sendCharacteristic;
@property (nonatomic, strong) CBCharacteristic *disconnectCharacteristic;
@property (nonatomic) BOOL loadedService;
@end

@implementation NURFduinoDevice
- (instancetype)init {
	if (self = [super init]) {

	}
	return self;
}

- (void)deviceConnected {
	service_uuid = [CBUUID UUIDWithString:(customUUID ? customUUID : @"2220")];
	receive_uuid = [CBUUID UUIDWithString:(customUUID ? customUUID : @"2221")];

	if (customUUID) {
		incrementUuid16(receive_uuid, 1);
	}

	send_uuid = [CBUUID UUIDWithString:(customUUID ? customUUID : @"2222")];

	if (customUUID) {
		incrementUuid16(send_uuid, 2);
	}

	disconnect_uuid = [CBUUID UUIDWithString:(customUUID ? customUUID : @"2223")];

	if (customUUID) {
		incrementUuid16(disconnect_uuid, 3);
	}

	_peripheral.delegate = self;

	[_peripheral discoverServices:[NSArray arrayWithObject:service_uuid]];
}

#pragma mark - RFduino methods

- (void)sendData:(NSData *)data {
	if (!_loadedService) {
		@throw [NSException exceptionWithName:@"sendData" reason:@"please wait for ready callback" userInfo:nil];
	}

	if ([data length] > kMaxDataSize) {
		@throw [NSException exceptionWithName:@"sendData" reason:@"max data size exceeded" userInfo:nil];
	}

	[_peripheral writeValue:data forCharacteristic:_sendCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

- (void)disconnect {
	if (_loadedService) {
		// fix for iOS SDK 7.0 - at least one byte must now be transferred
		uint8_t flag = 1;
		NSData *data = [NSData dataWithBytes:(void*)&flag length:1];
		[_peripheral writeValue:data forCharacteristic:_disconnectCharacteristic type:CBCharacteristicWriteWithoutResponse];
	}

	[_manager disconnectDevice:self];
//	[_rfduinoManager disconnectRFduino:self];
}

#pragma mark - CBPeripheralDelegate methods

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
	for (CBService *service in peripheral.services) {
		if ([service.UUID isEqual:service_uuid]) {
			NSArray *characteristics = [NSArray arrayWithObjects:receive_uuid, send_uuid, disconnect_uuid, nil];
			[peripheral discoverCharacteristics:characteristics forService:service];
		}
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
	for (CBService *service in peripheral.services) {
		if ([service.UUID isEqual:service_uuid]) {
			for (CBCharacteristic *characteristic in service.characteristics) {
				if ([characteristic.UUID isEqual:receive_uuid]) {
					[peripheral setNotifyValue:YES forCharacteristic:characteristic];
				} else if ([characteristic.UUID isEqual:send_uuid]) {
					_sendCharacteristic = characteristic;
				} else if ([characteristic.UUID isEqual:disconnect_uuid]) {
					_disconnectCharacteristic = characteristic;
				}
			}

			_loadedService = true;
			[_manager deviceDidLoadService:self];
//			[_manager loadedServiceRFduino:self];
		}
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
	if ([characteristic.UUID isEqual:receive_uuid]) {
		if ([_delegate respondsToSelector:@selector(device:didRecieveData:)]) {
			[_delegate device:self didRecieveData:characteristic.value];
		}
	}
}

- (NSUInteger)hash {
	return _peripheral.hash;
}

- (BOOL)isEqual:(id)object {
	return ([object isKindOfClass:[self class]]
			&& [self.peripheral isEqual:((NURFduinoDevice *)object).peripheral]);
}

@end
