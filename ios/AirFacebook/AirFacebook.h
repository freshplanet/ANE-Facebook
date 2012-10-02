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

#import "Facebook.h"
#import "FlashRuntimeExtensions.h"
#import "AirFBDialog.h"


@interface AirFacebook : NSObject

- (void)log:(NSString *)string;

+ (id)sharedInstance;

// @param appID Facebook application ID.
// @param urlSuffix Suffix used for your other apps using the same app id (i.e paid version). Can be set to null.
- (id)initWithAppID:(NSString *)appID urlSuffix:(NSString *)urlSuffix;

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error;

- (void)requestWithGraphPath:(NSString *)path callback:(NSString *)callbackName;
- (void)requestWithGraphPath:(NSString *)path parameters:(NSDictionary *)params callback:(NSString *)callbackName;
- (void)requestWithGraphPath:(NSString *)path parameters:(NSDictionary *)params httpMethod:(NSString *)httpMethod callback:(NSString *)callbackName;

- (void)dialog:(NSString *)action parameters:(NSMutableDictionary *)params callback:(NSString *)callbackName;

@property (nonatomic, readonly) Facebook *facebook;

@end


// C interface
DEFINE_ANE_FUNCTION(initFacebook);
DEFINE_ANE_FUNCTION(getAccessToken);
DEFINE_ANE_FUNCTION(getExpirationTimestamp);
DEFINE_ANE_FUNCTION(isSessionValid);
DEFINE_ANE_FUNCTION(login);
DEFINE_ANE_FUNCTION(logout);
DEFINE_ANE_FUNCTION(askForMorePermissions);
DEFINE_ANE_FUNCTION(extendAccessTokenIfNeeded);
DEFINE_ANE_FUNCTION(postOGAction);
DEFINE_ANE_FUNCTION(openDialog);
DEFINE_ANE_FUNCTION(openFeedDialog);
DEFINE_ANE_FUNCTION(deleteRequests);
DEFINE_ANE_FUNCTION(requestWithGraphPath);
DEFINE_ANE_FUNCTION(handleOpenURL);


// ANE Setup
void AirFBContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet);
void AirFBContextFinalizer(FREContext ctx);
void AirFBInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet );
void AirFBFinalizer(void *extData);