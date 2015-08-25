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

#import "FlashRuntimeExtensions.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "FPANEUtils.h"

typedef void (^FBOpenSessionCompletionHandler)(FBSDKLoginManagerLoginResult *result, NSError *error);

@interface AirFacebook : NSObject

+ (id)sharedInstance;

+ (void)dispatchEvent:(NSString *)event withMessage:(NSString *)message;
+ (void)log:(NSString *)string, ...;
+ (NSString*) jsonStringFromObject:(id)obj andPrettyPrint:(BOOL) prettyPrint;

//- (void)didFinishLaunching:(NSNotification *)notification;

- (void)shareFinishedForCallback:(NSString *)callback;
- (void)shareContent:(FBSDKShareLinkContent *)content usingShareApi:(BOOL)useShareApi andCallback:(NSString *)callback;

@property (nonatomic, getter=isNativeLogEnabled) BOOL nativeLogEnabled;
@property (nonatomic) FBSDKShareDialogMode defaultShareDialogMode;
@property (nonatomic) FBSDKDefaultAudience defaultAudience;
@property (nonatomic) FBSDKLoginBehavior loginBehavior;

@end

// C interface
DEFINE_ANE_FUNCTION(initFacebook);
DEFINE_ANE_FUNCTION(AirFacebookHandleOpenURL);
DEFINE_ANE_FUNCTION(getAccessToken);
DEFINE_ANE_FUNCTION(getProfile);
DEFINE_ANE_FUNCTION(logInWithPermissions);
DEFINE_ANE_FUNCTION(logOut);
DEFINE_ANE_FUNCTION(requestWithGraphPath);

// Settings
DEFINE_ANE_FUNCTION(setDefaultAudience);
DEFINE_ANE_FUNCTION(setLoginBehavior);
DEFINE_ANE_FUNCTION(setDefaultShareDialogMode);

// Sharing dialogs
DEFINE_ANE_FUNCTION(canPresentShareDialog);
DEFINE_ANE_FUNCTION(shareLinkDialog);
DEFINE_ANE_FUNCTION(appInviteDialog);
DEFINE_ANE_FUNCTION(gameRequestDialog);

// FB events
DEFINE_ANE_FUNCTION(activateApp);
DEFINE_ANE_FUNCTION(AirFacebookLogEvent);

// Debug
DEFINE_ANE_FUNCTION(nativeLog);
DEFINE_ANE_FUNCTION(setNativeLogEnabled);

// ANE Setup
void AirFacebookContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet);
void AirFacebookContextFinalizer(FREContext ctx);
void AirFacebookInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet);
void AirFacebookFinalizer(void *extData);
