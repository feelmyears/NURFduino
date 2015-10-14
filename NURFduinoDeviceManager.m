//
//  NURFduinoDeviceManager.m
//  NURF
//
//  Created by Phil Meyers IV on 10/13/15.
//  Copyright © 2015 Northwestern University. All rights reserved.
//

#import "NURFduinoDeviceManager.h"
#import "NURFduinoDevice.h"
#import "NURFduinoDeviceManagerDelegate.h"

static CBUUID *serviceUUID;


typedef void (^NURFduinoDeviceManagerCancelBlock)();

@interface NURFduinoDeviceManager()
<
CBCentralManagerDelegate
>
@property (nonatomic, strong) NSTimer *rangeTimer;
@property (nonatomic) int rangeTimerCount;
@property (nonatomic) BOOL updatedDiscoveredDeviceFlag;
@property (nonatomic, copy) NURFduinoDeviceManagerCancelBlock cancelBlock;
@property (nonatomic, strong) NSMutableSet *devices;
@property (nonatomic, readwrite) BOOL scanning;
@property (nonatomic, strong) CBCentralManager *centralManager;
@end

@implementation NURFduinoDeviceManager
- (instancetype)init {
	if (self = [super init]) {
		serviceUUID = [CBUUID UUIDWithString:(customUUID ? customUUID : @"2220")];
		_devices = [NSMutableSet new];
		_centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
	}
	return self;
}

- (BOOL)isBluetoothLESupported {
	return _centralManager.state == CBCentralManagerStatePoweredOn;

	/*
	 if ([_centralManager state] == CBCentralManagerStatePoweredOn) {
		return YES;
	 }
	NSString *message;
	switch ([central state])
	{
		case CBCentralManagerStateUnsupported:
			message = @"This hardware doesn't support Bluetooth Low Energy.";
			break;
		case CBCentralManagerStateUnauthorized:
			message = @"This app is not authorized to use Bluetooth Low Energy.";
			break;
		case CBCentralManagerStatePoweredOff:
			message = @"Bluetooth is currently powered off.";
			break;
		case CBCentralManagerStateUnknown:
			// fall through
		default:
			message = @"Bluetooth state is unknown.";

	}
	 */
}

- (void)startRangeTimer {
	_rangeTimerCount = 0;
	_rangeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
												   target:self
												 selector:@selector(rangeTimerTick:)
												 userInfo:nil
												  repeats:YES];
}

- (void)stopRangeTimer {
	[_rangeTimer invalidate];
}

- (void)rangeTimerTick:(NSTimer *)timer {
	BOOL shouldUpdate = NO;
	_rangeTimerCount++;
	if (_rangeTimerCount % 60 == 0) {
		[_centralManager stopScan];
		NSDictionary *scanOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey : @(YES)};
		[_centralManager scanForPeripheralsWithServices:@[serviceUUID] options:scanOptions];
	}

	NSDate *currTime = [NSDate date];
	NSMutableArray *updatedDevices = [NSMutableArray new];
	for (NURFduinoDevice *device in _devices) {
		if (!device.isOutOfRange
			&& device.lastAdvertisementTime != nil
			&& [currTime timeIntervalSinceDate:device.lastAdvertisementTime] > 2) {
			device.outOfRange = YES;
			shouldUpdate = YES;
			[updatedDevices addObject:device];
		}
	}

	if (shouldUpdate && _updatedDiscoveredDeviceFlag) {
		[_delegate deviceManager:self didUpdateDiscoveredDevices:updatedDevices];
//		[_delegate didUpdateDiscoveredDevice:nil];
	}
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
	NURFduinoDevice *device = [self deviceForPeripheral:peripheral];
	if (device) {
		[device deviceConnected];
		if ([_delegate respondsToSelector:@selector(deviceManager:didConnectToDevice:)]) {
			[_delegate deviceManager:self didConnectToDevice:device];
		}
	}
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
	__weak __typeof__(self) WSELF = self;
	void (^block)(void) = ^{
		if ([WSELF.delegate respondsToSelector:@selector(deviceManager:didDisconnectFromDevice:)]) {
			NURFduinoDevice *disconnectedDevice = [WSELF deviceForPeripheral:peripheral];
			if (disconnectedDevice) {
				[WSELF.delegate deviceManager:WSELF didDisconnectFromDevice:disconnectedDevice];
			}
		}
	};

	if (error.code) {
		self.cancelBlock = block;
	} else {
		block();
	}

	if (peripheral) {
		peripheral = nil;
	}
}


- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
	 advertisementData:(NSDictionary *)advertisementData
				  RSSI:(NSNumber *)RSSI {

	BOOL added = NO;

	NURFduinoDevice *device = [self deviceForPeripheral:peripheral];
	if (!device) {
		device = [NURFduinoDevice new];
		device.manager = self;
		device.name = peripheral.name;
		device.peripheral = peripheral;

		added = YES;
		[_devices addObject:device];
	}

	device.advertisementData = nil;

	id manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey];
	if (manufacturerData) {
		const uint8_t *bytes = [manufacturerData bytes];
		NSUInteger len = [manufacturerData length];
		// skip manufacturer uuid
		NSData *data = [NSData dataWithBytes:bytes+2 length:len-2];
		device.advertisementData = data;
	}

	device.advertisementRSSI = RSSI;
	device.advertisementPackets++;
	device.lastAdvertisementTime = [NSDate date];
	device.outOfRange = false;

	if (added) {
		if ([_delegate respondsToSelector:@selector(deviceManager:didDiscoverDevice:)]) {
			[_delegate deviceManager:self didDiscoverDevice:device];
		}
//		[_delegate didDiscoverRFduino:rfduino];
	} else if (_updatedDiscoveredDeviceFlag) {
		if ([_delegate respondsToSelector:@selector(deviceManager:didUpdateDiscoveredDevices:)]) {
			[_delegate deviceManager:self didUpdateDiscoveredDevices:@[device]];
		}
//		[_delegate didUpdateDiscoveredRFduino:rfduino];
	}
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {

}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)aCentral {
	if ([self isBluetoothLESupported]) {
		[self startScan];
	}
}

- (NURFduinoDevice *)deviceForPeripheral:(CBPeripheral *)peripheral {
	for (NURFduinoDevice *device in _devices) {
		if ([peripheral isEqual:device.peripheral]) {
			return device;
		}
	}
	return nil;
}

#pragma mark - Rfduino methods

- (void)startScan {
	_scanning = true;

	NSDictionary *options = nil;

	_updatedDiscoveredDeviceFlag = [_delegate respondsToSelector:@selector(deviceManager:didUpdateDiscoveredDevices:)];

	if (_updatedDiscoveredDeviceFlag) {
		options = @{CBCentralManagerScanOptionAllowDuplicatesKey : @(YES)};
	}

	[_devices removeAllObjects];
	[_centralManager scanForPeripheralsWithServices:[NSArray arrayWithObject:serviceUUID] options:options];

	if (_updatedDiscoveredDeviceFlag) {
		[self startRangeTimer];
	}
}

- (void)stopScan {
	if (_updatedDiscoveredDeviceFlag) {
		[self stopRangeTimer];
	}

	[_centralManager stopScan];

	_scanning = false;
}

- (void)connectDevice:(NURFduinoDevice *)device {
	[_centralManager connectPeripheral:device.peripheral options:nil];
}

- (void)disconnectDevice:(NURFduinoDevice *)device {
	[_centralManager cancelPeripheralConnection:device.peripheral];
}

@end
