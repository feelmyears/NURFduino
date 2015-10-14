//
//  NURFDataReadingExampleViewController.h
//  NURF
//
//  Created by Phil Meyers IV on 10/13/15.
//  Copyright © 2015 Northwestern University. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NURFduinoDeviceManager;
@interface NURFDataReadingExampleViewController : UIViewController
#pragma mark - Dependencies
@property (nonatomic, readonly) NURFduinoDeviceManager *deviceManager;
- (instancetype)initWithDeviceManager:(NURFduinoDeviceManager *)deviceManager;

@end
