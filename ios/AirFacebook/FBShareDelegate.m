/**
 * Copyright 2017 FreshPlanet
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "FBShareDelegate.h"
#import "AirFacebook.h"

@implementation FBShareDelegate {
    NSString *callback;
}

- (id)initWithCallback:(NSString *)aCallback {
    
    if (self = [super init])
        callback = aCallback;
    
    return self;
}

- (BOOL)shareContent:(FBSDKShareLinkContent *)content
{
    UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    
    [FBSDKShareDialog showFromViewController:rootViewController
                        withContent:content delegate:self].mode = [[AirFacebook sharedInstance] defaultShareDialogMode];

    return YES;
}

-(void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    NSString *resultString = [AirFacebook jsonStringFromObject:results andPrettyPrint:NO];
    [AirFacebook log:@"SHARE_COMPLETE JSON: %@", resultString];
    [AirFacebook dispatchEvent:[NSString stringWithFormat:@"SHARE_SUCCESS_%@", callback] withMessage:resultString];
    [[AirFacebook sharedInstance] shareFinishedForCallback:callback];
}

-(void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    [AirFacebook log:@"SHARE_ERROR error: %@", [error description]];
    [AirFacebook dispatchEvent:[NSString stringWithFormat:@"SHARE_ERROR_%@", callback] withMessage:[error description]];
    [[AirFacebook sharedInstance] shareFinishedForCallback:callback];
}

-(void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    [AirFacebook log:@"SHARE_CANCEL"];
    [AirFacebook dispatchEvent:[NSString stringWithFormat:@"SHARE_CANCELLED_%@", callback] withMessage:@"OK"];
    [[AirFacebook sharedInstance] shareFinishedForCallback:callback];
}

@end
