//
//  NURFTestServerService.m
//  NURF
//
//  Created by Phil Meyers IV on 10/21/15.
//  Copyright © 2015 Northwestern University. All rights reserved.
//

#import "NURFTestServerService.h"
#import "Bolts.h"
#import "AFNetworking.h"
#import "NURFTestServerServiceInterface.h"

static NSString *const kNURFTestServerServiceBaseURL = @"http://murphy.wot.eecs.northwestern.edu/~pdinda/watch/watch.pl";
static NSString *const kNURFTestServerServiceParameterRequestKey = @"req";
static NSString *const kNURFTestServerServiceParameterRequestRecordDataKey = @"record-data";
static NSString *const kNURFTestServerServiceParameterDataKey = @"data";

@implementation NURFTestServerService
- (instancetype)initWithRequestOperationManager:(AFHTTPRequestOperationManager *)requestOperationManager {
	if (self = [super init]) {
		_requestOperationManager = requestOperationManager;
	}
	return self;
}

- (BFTask *)postDataToServer:(NSNumber *)data {
	NSDictionary *parameters = @{kNURFTestServerServiceParameterRequestKey : kNURFTestServerServiceParameterRequestRecordDataKey,
								 kNURFTestServerServiceParameterDataKey : data};

	return [self postToURL:kNURFTestServerServiceBaseURL withParameters:parameters];
}

- (BFTask *)postToURL:(NSString *)url withParameters:(NSDictionary *)parameters {
	BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
	[_requestOperationManager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		[completionSource setResult:responseObject];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[completionSource setError:error];
	}];
	return completionSource.task;
}


@end
