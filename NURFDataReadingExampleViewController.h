//
//  NURFDataReadingExampleViewController.h
//  NURF
//
//  Created by Phil Meyers IV on 10/13/15.
//  Copyright © 2015 Northwestern University. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NURFduinoDeviceManager;
@protocol NURFTestServerServiceInterface;
@interface NURFDataReadingExampleViewController : UIViewController
#pragma mark - Dependencies
@property (nonatomic, readonly) NURFduinoDeviceManager *deviceManager;
@property (nonatomic, readonly) id<NURFTestServerServiceInterface> testServerService;
- (instancetype)initWithDeviceManager:(NURFduinoDeviceManager *)deviceManager
					testServerService:(id<NURFTestServerServiceInterface>)testServerService;


@end
