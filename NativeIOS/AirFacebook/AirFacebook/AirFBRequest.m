//
//  AirFBRequest.m
//  AirFacebook
//
//  Created by Thibaut Crenn on 3/29/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AirFBRequest.h"



@implementation AirFBRequest

@synthesize name;
@synthesize context;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithName:(NSString*)newName AndContext:(id*)newContext
{
    [self init];
    
    [self setContext:newContext];
    [self setName:newName];

    return self;
}

// raw response contains both error and success.
- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data
{
    NSString* dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if ([self context] != nil)
    {
        FREDispatchStatusEventAsync([self context], (uint8_t*)[[self name] UTF8String], (uint8_t*)[dataString UTF8String]); 
    } 
}


@end
