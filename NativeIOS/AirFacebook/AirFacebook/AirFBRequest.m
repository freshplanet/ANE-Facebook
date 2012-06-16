//////////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012 Freshplanet (http://freshplanet.com | opensource@freshplanet.com)
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//    http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//  
//////////////////////////////////////////////////////////////////////////////////////

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
    
    if ([self context] != nil && [self name] != nil)
    {
        FREDispatchStatusEventAsync([self context], (uint8_t*)[[self name] UTF8String], (uint8_t*)[dataString UTF8String]); 
    } 
    [dataString release];
}


- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    self = nil;
    [self release];
}


- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    self = nil;
    [self release];
}


@end
