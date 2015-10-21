//
//  NURFTestServerService.h
//  NURF
//
//  Created by Phil Meyers IV on 10/21/15.
//  Copyright © 2015 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol NURFTestServerServiceInterface;
@class AFHTTPRequestOperationManager;
@interface NURFTestServerService : NSObject<NURFTestServerServiceInterface>
#pragma mark - Dependencies
@property (nonatomic, readonly) AFHTTPRequestOperationManager *requestOperationManager;
- (instancetype)initWithRequestOperationManager:(AFHTTPRequestOperationManager *)requestOperationManager;
@end
