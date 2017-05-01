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

#import "FBAppInviteDialogDelegate.h"
#import "AirFacebook.h"

@implementation FBAppInviteDialogDelegate {
    NSString* callback;
}

- (id)initWithCallback:(NSString*)aCallback {
    
    if (self = [super init])
        callback = aCallback;
    
    return self;
}

- (void)showAppInviteDialogWithContent:(FBSDKAppInviteContent*)content {
    
    [FBSDKAppInviteDialog showWithContent:content
                                 delegate:self];
}

- (void)appInviteDialog:(FBSDKAppInviteDialog*)appInviteDialog didCompleteWithResults:(NSDictionary*)results {
    
    NSString* resultString = [AirFacebook jsonStringFromObject:results andPrettyPrint:NO];
    [AirFacebook log:@"APPINVITE_COMPLETE JSON: %@", resultString];
    [AirFacebook dispatchEvent:[NSString stringWithFormat:@"APPINVITE_SUCCESS_%@", callback] withMessage:resultString];
    [[AirFacebook sharedInstance] shareFinishedForCallback:callback];
}

- (void)appInviteDialog:(FBSDKAppInviteDialog*)appInviteDialog didFailWithError:(NSError*)error {
    
    [AirFacebook log:@"APPINVITE_ERROR error: %@", [error description]];
    [AirFacebook dispatchEvent:[NSString stringWithFormat:@"APPINVITE_ERROR_%@", callback] withMessage:[error description]];
    [[AirFacebook sharedInstance] shareFinishedForCallback:callback];
}

@end
