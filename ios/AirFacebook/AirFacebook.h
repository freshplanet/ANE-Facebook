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

#import "FBSession.h"
#import "FBSessionTokenCachingStrategy.h"
#import "FBAccessTokenData.h"
#import "FBRequest.h"
#import "FBDialogs.h"
#import "FBWebDialogs.h"
#import "FBSettings.h"
#import "FlashRuntimeExtensions.h"
#import "FBError.h"
#import "FBSBJSON.h" // used from SDK 3.2 fro portability over ios < 5.0
#import "NSError+FBError.h"

typedef void (^FBOpenSessionCompletionHandler)(FBSession *session, FBSessionState status, NSError *error);
typedef void (^FBReauthorizeSessionCompletionHandler)(FBSession *session, NSError *error);
typedef void (^FBRequestCompletionHandler)(FBRequestConnection *connection, id result, NSError *error);

@interface AirFacebook : NSObject

+ (id)sharedInstance;

+ (void)dispatchEvent:(NSString *)event withMessage:(NSString *)message;

- (id)initWithAppID:(NSString *)appID urlSchemeSuffix:(NSString *)urlSchemeSuffix;

+ (FBOpenSessionCompletionHandler)openSessionCompletionHandler;
+ (FBReauthorizeSessionCompletionHandler)reauthorizeSessionCompletionHandler;
+ (FBRequestCompletionHandler)requestCompletionHandlerWithCallback:(NSString *)callback;
+ (FBOSIntegratedShareDialogHandler)shareDialogHandlerWithCallback:(NSString *)callback;

+ (void)log:(NSString *)string, ...;

@property (nonatomic, readonly) NSString *appID;
@property (nonatomic, readonly) NSString *urlSchemeSuffix;

@end

// utils
NSArray* getFREArrayAsNSArray( FREObject array );

// C interface
DEFINE_ANE_FUNCTION(init);
DEFINE_ANE_FUNCTION(handleOpenURL);
DEFINE_ANE_FUNCTION(getAccessToken);
DEFINE_ANE_FUNCTION(getExpirationTimestamp);
DEFINE_ANE_FUNCTION(isSessionOpen);
DEFINE_ANE_FUNCTION(openSessionWithPermissions);
DEFINE_ANE_FUNCTION(reauthorizeSessionWithPermissions);
DEFINE_ANE_FUNCTION(closeSessionAndClearTokenInformation);
DEFINE_ANE_FUNCTION(requestWithGraphPath);
DEFINE_ANE_FUNCTION(dialog);
DEFINE_ANE_FUNCTION(publishInstall);

// ANE Setup
void AirFacebookContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet);
void AirFacebookContextFinalizer(FREContext ctx);
void AirFacebookInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet);
void AirFacebookFinalizer(void *extData);