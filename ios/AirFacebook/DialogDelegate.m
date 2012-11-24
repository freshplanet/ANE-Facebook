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

#import "AirFacebook.h"
#import "DialogDelegate.h"

@implementation DialogDelegate

@synthesize callback = _callback;

- (void)dealloc
{
    [_callback release];
    [super dealloc];
}

- (void)dialogCompleteWithUrl:(NSURL *)url
{
    NSString *queryString = [url query];
    NSString *data = queryString ? [NSString stringWithFormat:@"{ \"params\" : \"%@\"}", queryString] : @"{ \"cancel\" : true}";
    [[AirFacebook sharedInstance] dialogDelegate:self finishedWithResult:data];
}

- (void) dialogDidNotCompleteWithUrl:(NSURL *)url
{
    NSString *data = [NSString stringWithFormat:@"{ \"cancel\" : true}"];
    [[AirFacebook sharedInstance] dialogDelegate:self finishedWithResult:data];
}

- (void)dialog:(FBDialog *)dialog didFailWithError:(NSError *)error
{
    NSString *data = [NSString stringWithFormat:@"{ \"error\" : \"%@\"}", [error description]];
    [[AirFacebook sharedInstance] dialogDelegate:self finishedWithResult:data];
}

@end
