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

#import "DialogDelegate.h"
#import "Facebook.h"
#import "FlashRuntimeExtensions.h"

typedef void (^FBOpenSessionCompletionHandler)(FBSession *session, FBSessionState status, NSError *error);
typedef void (^FBReauthorizeSessionCompletionHandler)(FBSession *session, NSError *error);
typedef void (^FBRequestCompletionHandler)(FBRequestConnection *connection, id result, NSError *error);

@interface AirFacebook : NSObject

+ (id)sharedInstance;

- (id)initWithAppID:(NSString *)appID urlSchemeSuffix:(NSString *)urlSchemeSuffix;

+ (FBOpenSessionCompletionHandler)openSessionCompletionHandler;
+ (FBReauthorizeSessionCompletionHandler)reauthorizeSessionCompletionHandler;
+ (FBRequestCompletionHandler)requestCompletionHandlerWithCallback:(NSString *)callback;
+ (FBShareDialogHandler)shareDialogHandlerWithCallback:(NSString *)callback;
- (DialogDelegate *)dialogDelegateWithCallback:(NSString *)callback;
- (void)dialogDelegate:(DialogDelegate *)delegate finishedWithResult:(NSString *)result;

+ (void)log:(NSString *)string;

@property (nonatomic, readonly) NSString *appID;
@property (nonatomic, readonly) NSString *urlSchemeSuffix;
@property (nonatomic, readonly) Facebook *facebook;

@end


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