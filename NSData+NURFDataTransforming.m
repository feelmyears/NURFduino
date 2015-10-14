//
//  NSData+NURFDataTransforming.m
//  NURF
//
//  Created by Phil Meyers IV on 10/13/15.
//  Copyright © 2015 Northwestern University. All rights reserved.
//

#import "NSData+NURFDataTransforming.h"

char data(NSData *data)
{
	return (char)dataByte(data);
}

uint8_t dataByte(NSData *data)
{
	uint8_t *p = (uint8_t*)[data bytes];
	NSUInteger len = [data length];
	return (len ? *p : 0);
}

int dataInt(NSData *data)
{
	uint8_t *p = (uint8_t*)[data bytes];
	NSUInteger len = [data length];
	return (sizeof(int) <= len ? *(int*)p : 0);
}

float dataFloat(NSData *data)
{
	uint8_t *p = (uint8_t*)[data bytes];
	NSUInteger len = [data length];
	return (sizeof(float) <= len ? *(float*)p : 0);
}


@implementation NSData (NURFDataTransforming)

@end
