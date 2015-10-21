//
//  NURFTestServerServiceInterface.h
//  NURF
//
//  Created by Phil Meyers IV on 10/21/15.
//  Copyright © 2015 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BFTask;

@protocol NURFTestServerServiceInterface <NSObject>
- (BFTask *)postDataToServer:(NSNumber *)data;
@end
