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

#import "FlashRuntimeExtensions.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "FPANEUtils.h"

typedef void (^FBOpenSessionCompletionHandler)(FBSDKLoginManagerLoginResult *result, NSError *error);

@interface AirFacebook : NSObject

+ (id)sharedInstance;

+ (void)dispatchEvent:(NSString *)event withMessage:(NSString*)message;
+ (void)log:(NSString*)string, ...;
+ (NSString*) jsonStringFromObject:(id)obj andPrettyPrint:(BOOL) prettyPrint;

//- (void)didFinishLaunching:(NSNotification *)notification;

- (void)shareFinishedForCallback:(NSString*)callback;
- (void)shareContent:(FBSDKShareLinkContent*)content andCallback:(NSString*)callback;

@property (nonatomic, getter=isNativeLogEnabled) BOOL nativeLogEnabled;
@property (nonatomic) FBSDKShareDialogMode defaultShareDialogMode;
@property (nonatomic) FBSDKDefaultAudience defaultAudience;
@property(nonatomic, assign) BOOL loginInProgress;

@end

void AirFacebookContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet);
void AirFacebookContextFinalizer(FREContext ctx);
void AirFacebookInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet);
void AirFacebookFinalizer(void *extData);
