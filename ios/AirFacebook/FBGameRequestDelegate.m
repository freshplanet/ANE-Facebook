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

#import "FBGameRequestDelegate.h"
#import "AirFacebook.h"

@implementation FBGameRequestDelegate {
    NSString* callback;
}

- (id)initWithCallback:(NSString*)aCallback {
    
    if (self = [super init])
        callback = aCallback;
    
    return self;
}

- (void)gameRequestWithContent:(FBSDKGameRequestContent*)content enableFrictionless:(BOOL)frictionless {
    
    FBSDKGameRequestDialog* dialog = [[FBSDKGameRequestDialog alloc] init];
    dialog.content = content;
    dialog.delegate = self;
    dialog.frictionlessRequestsEnabled = frictionless;
    
    [dialog show];
}

- (void)gameRequestDialog:(FBSDKGameRequestDialog*)gameRequestDialog didCompleteWithResults:(NSDictionary*)results {
    
    NSString* resultString = [AirFacebook jsonStringFromObject:results andPrettyPrint:NO];
    [AirFacebook log:@"REQUEST_COMPLETE JSON: %@", resultString];
    [AirFacebook dispatchEvent:callback withMessage:resultString];
    [[AirFacebook sharedInstance] shareFinishedForCallback:callback];
}

- (void)gameRequestDialog:(FBSDKGameRequestDialog*)gameRequestDialog didFailWithError:(NSError*)error {
    
    [AirFacebook log:@"REQUEST_ERROR error: %@", [error description]];
    [AirFacebook dispatchEvent:callback withMessage:[error description]];
    [[AirFacebook sharedInstance] shareFinishedForCallback:callback];
}

- (void)gameRequestDialogDidCancel:(FBSDKGameRequestDialog*)gameRequestDialog {
    
    [AirFacebook log:@"REQUEST_CANCEL"];
    [AirFacebook dispatchEvent:callback withMessage:@"OK"];
    [[AirFacebook sharedInstance] shareFinishedForCallback:callback];
}

@end
