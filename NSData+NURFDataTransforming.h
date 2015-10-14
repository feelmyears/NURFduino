//
//  NSData+NURFDataTransforming.h
//  NURF
//
//  Created by Phil Meyers IV on 10/13/15.
//  Copyright © 2015 Northwestern University. All rights reserved.
//

#import <Foundation/Foundation.h>
char data(NSData *data);
uint8_t dataByte(NSData *data);
int dataInt(NSData *data);
float dataFloat(NSData *data);

@interface NSData (NURFDataTransforming)

@end
