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
//

#import "AirFBDialog.h"

@implementation AirFBDialog

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

- (void)dialogCompleteWithUrl:(NSURL *)url
{
    NSString* queryString = [url query];
    NSString *data;
    if (queryString == NULL)
    {
        // assume that it's a cancel.
        data = [NSString stringWithFormat:@"{ \"cancel\" : true}", [url query]];
    } else
    {
        data = [NSString stringWithFormat:@"{ \"params\" : \"%@\"}", [url query]];
    }
    FREDispatchStatusEventAsync([self context], (uint8_t*) [[self name] UTF8String], (uint8_t*)[data UTF8String]); 
}

/**
 * Called when the dialog is cancelled and is about to be dismissed.
 */
- (void) dialogDidNotCompleteWithUrl:(NSURL *)url
{
    NSString *data = [NSString stringWithFormat:@"{ \"cancel\" : true}"];
    FREDispatchStatusEventAsync([self context], (uint8_t*) [[self name] UTF8String], (uint8_t*)[data UTF8String]); 
}

/**
 * Called when dialog failed to load due to an error.
 */
- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error
{
    NSString *data = [NSString stringWithFormat:@"{ \"error\" : \"%@\"}", [error description]];
    FREDispatchStatusEventAsync([self context], (uint8_t*) [[self name] UTF8String], (uint8_t*)[data UTF8String]); 
}


@end
