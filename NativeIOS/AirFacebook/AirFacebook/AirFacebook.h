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

#import <Foundation/Foundation.h>
#import "FBConnect.h"
#import "FBDialog.h"
#import "FlashRuntimeExtensions.h"
#import "AirFBRequest.h"
#import "AirFBDialog.h"

@interface AirFacebook : NSObject <FBSessionDelegate>
{
    Facebook *facebook;
    
}

- (void) extendAccessTokenIfNeeded;
- (void) initFacebookWithAppId:(NSString*)appId andAccessToken:(NSString*)accessToken andExpirationTimestamp:(NSString*)expirationTimestamp;
- (BOOL) handleOpenURL:(NSURL *)url;
- (void) requestWithGraphPath:(NSString*)path andCallback:(NSString*)callbackName;
- (void) requestWithGraphPath:(NSString*)path andParams:(NSMutableDictionary*)params andCallback:(NSString*)callbackName;
- (void) requestWithGraphPath:(NSString*)path andParams:(NSMutableDictionary*)params andHttpMethod:(NSString*)httpMethod andCallback:(NSString*)callbackName;


- (void) dialog:(NSString *)action andParams:(NSMutableDictionary *)params andCallback:(NSString*)callbackName;
- (void) login:(NSArray*)permissions;
- (void) logout;
@property (nonatomic, retain) Facebook *facebook;



@end

void AirFBContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
                        uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet);

void AirFBContextFinalizer(FREContext ctx);

void AirFBInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet );

FREObject initFacebook(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);

FREObject extendAccessTokenIfNeeded(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);

FREObject logout(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);

FREObject login(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);

FREObject handleOpenURL(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);

FREObject requestWithGraphPath(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);

FREObject openDialog(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);

FREObject deleteRequests(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);

FREObject postOGAction(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);

FREObject openFeedDialog(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);


