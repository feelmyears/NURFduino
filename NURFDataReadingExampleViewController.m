//
//  NURFDataReadingExampleViewController.m
//  NURF
//
//  Created by Phil Meyers IV on 10/13/15.
//  Copyright © 2015 Northwestern University. All rights reserved.
//

#import "NURFDataReadingExampleViewController.h"
#import "NURFduinoDevice.h"
#import "NURFduinoDeviceManager.h"
#import "NURFduinoDeviceManagerDelegate.h"
#import "NURFduinoDeviceDelegate.h"

@interface NURFDataReadingExampleViewController()
<
NURFduinoDeviceManagerDelegate,
NURFduinoDeviceDelegate
>
@property (nonatomic, strong) NURFduinoDevice *device;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UILabel *outputLabel;
@end

@implementation NURFDataReadingExampleViewController
- (instancetype)initWithDeviceManager:(NURFduinoDeviceManager *)deviceManager {
	if (self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil]) {
		_deviceManager = deviceManager;
		_deviceManager.delegate = self;
		_actionButton.userInteractionEnabled = NO;
		_outputLabel.text = @"No devices found";
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self scanForDevices];
}

- (void)scanForDevices {
	[_deviceManager startScan];
}

- (void)requestDataFromDevice {
	unsigned char d = 1;
	[_device sendData:[NSData dataWithBytes:&d length:sizeof(d)]];
}

- (IBAction)handleActionButtonTap:(UIButton *)sender {
	[self requestDataFromDevice];
}

#pragma mark - NURFDeviceManagerDelegate
- (void)deviceManager:(NURFduinoDeviceManager *)manager didDiscoverDevice:(NURFduinoDevice *)device {
	_outputLabel.text = @"Device Found. Connecting...";
	[manager connectDevice:device];
}

- (void)deviceManager:(NURFduinoDeviceManager *)manager didUpdateDiscoveredDevices:(NSArray<NURFduinoDevice *> *)devices {
	
}

- (void)deviceManager:(NURFduinoDeviceManager *)manager didConnectToDevice:(NURFduinoDevice *)device {
	_device = device;
	_device.delegate = self;
}

- (void)deviceManager:(NURFduinoDeviceManager *)manager didDisconnectFromDevice:(NURFduinoDevice *)device {
	_outputLabel.text = @"Disconnected from device!";
	_actionButton.userInteractionEnabled = NO;
}

- (void)deviceManager:(NURFduinoDeviceManager *)manager didLoadServiceForDevice:(NURFduinoDevice *)device {
	_outputLabel.text = @"Connected to device!";
	_actionButton.userInteractionEnabled = YES;
}

#pragma mark - NURFDeviceDelegate
- (void)device:(NURFduinoDevice *)device didRecieveData:(NSData *)data {
	NSLog(@"Data: %@", data);
	int output;
	[data getBytes: &output length: sizeof(output)];
	_outputLabel.text = [NSString stringWithFormat:@"%d", output];
}

@end
